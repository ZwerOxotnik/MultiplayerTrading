local tostring = tostring
local tonumber = tonumber
local Area = Area
local max = math.max
local floor = math.floor
local abs = math.abs

local function BalanceEnergy(source, destination)
    local from_energy = source.energy
    local to_energy = from_energy
    local energy_sum = source.energy + to_energy
    local balanced_energy = energy_sum / 2.0
    local source_diff = balanced_energy - from_energy
    local dest_diff = balanced_energy - to_energy

    local ets = storage.electric_trading_stations
    local source_mod_data = ets[source.unit_number]
    local destination_mod_data = ets[destination.unit_number]
    local source_price = source_mod_data.sell_price
    local dest_price = destination_mod_data.sell_price
    local source_bid = source_mod_data.buy_bid
    local dest_bid = destination_mod_data.buy_bid

    local source_cost = source_diff * 0.000001
    local dest_cost = dest_diff * 0.000001

    source.power_usage = 0
    source.power_production = 0
    destination.power_usage = 0
    destination.power_production = 0

    if (source_cost > 0 and source_bid < dest_price) then
        -- No trade if source is buying but bid is lower than dest's price.
        return
    else
        source_cost = source_cost * source_bid
        dest_cost = dest_cost * source_bid
    end
    if (dest_cost > 0 and dest_bid < source_price) then
        -- No trade if dest is buying but bid is lower than source's price.
        return
    else
        source_cost = source_cost * dest_bid
        dest_cost = dest_cost * dest_bid
    end

    if (source_cost > 0 and not CanTransferCredits(source, source_cost)) then
        local signal = {type="item", name="accumulator"}
        local message = "Cannot afford to buy power. " .. floor(source_cost) .. " short."
        for _, player in pairs(source.force.connected_players) do
            player.add_custom_alert(source, signal, message, true)
        end
        return
    end

    if (dest_cost > 0 and not CanTransferCredits(destination, dest_cost)) then
        local signal = {type="item", name="accumulator"}
        local message = "Cannot afford to buy power. " .. floor(dest_cost) .. " short."
        for _, player in pairs(destination.force.connected_players) do
            player.add_custom_alert(destination, signal, message, true)
        end
        return
    end

    -- Trade succesful
    AddCredits(source.force, -source_cost)
    AddCredits(destination.force, -dest_cost)
    local diff = abs(source_diff) / 60.0
    if source_diff < 0 then
        source.power_usage = diff
        source.power_production = 0
    elseif source_diff > 0 then
        source.power_usage = 0
        source.power_production = diff
    else
        source.power_usage = 0
        source.power_production = 0
    end

    if dest_diff < 0 then
        destination.power_usage = diff
        destination.power_production = 0
    elseif dest_diff > 0 then
        destination.power_usage = 0
        destination.power_production = diff
    else
        destination.power_usage = 0
        destination.power_production = 0
    end
end

function UpdateElectricTradingStations(stations)
    local filter = {
        area = 0,
        name = "electric-trading-station"
    }
    for _, electric_trading_station in pairs(stations) do
        local source = electric_trading_station.entity
        filter.area = Area(source.position, 3)
        local adjacent = source.surface.find_entities_filtered(filter)
        local highest_bidder = nil
        local highest_bid = 0
        for i=1, #adjacent do
			local dest = adjacent[i]
            if dest.force ~= source.force then
				-- TODO: recheck
                local dest_bid = stations[dest.unit_number].buy_bid
                if dest_bid > highest_bid then
                    if not (dest.energy >= 6000000) then
                        highest_bid = dest_bid
                        highest_bidder = dest
                    end
                end
            end
        end
        if highest_bidder then
            BalanceEnergy(source, highest_bidder)
        end
    end
end

function DisallowElectricityTheft(entity, instigatingForce)
    if instigatingForce then
		local neighbours = entity.get_wire_connectors()[defines.wire_connector_id.pole_copper]
		for _, connection in pairs(neighbours.real_connections) do
			local target = connection.target
			local neighbour_force = target.owner.force
            if instigatingForce ~= neighbour_force and not instigatingForce.get_friend(neighbour_force) then
                target.disconnect_all()
            end
        end
    end
end

function ElectricTradingStationGUIOpen(event)
    local player = game.get_player(event.player_index)
    if player.gui.center['ets-gui'] then return end
    local entity = player.selected
    local frame = player.gui.center.add{type = "frame", direction = "vertical", name = "ets-gui", caption = "Electric Trading Station"}
    frame.add{type = "label", caption = "Sell Price per MW"}
    if entity.force == player.force then
        local sell = frame.add{type = "textfield", name = "sell"}
        sell.text = tostring(storage.electric_trading_stations[entity.unit_number].sell_price)
    else
        local sell = frame.add{type = "label", name = "sell"}
        sell.caption = tostring(storage.electric_trading_stations[entity.unit_number].sell_price)
    end
    frame.add{type = "label", caption = "Buy bid per MW"}
    if entity.force == player.force then
        local buy = frame.add{type = "textfield", name = "buy"}
        buy.text = tostring(storage.electric_trading_stations[entity.unit_number].buy_bid)
    else
        local buy = frame.add{type = "label", name = "buy"}
        buy.caption = tostring(storage.electric_trading_stations[entity.unit_number].buy_bid)
    end
    if storage.open_electric_trading_station == nil then
        storage.open_electric_trading_station = {}
    end
    storage.open_electric_trading_station[player.index] = entity.unit_number
end

function ElectricTradingStationGUIClose(event)
    local player = game.get_player(event.player_index)
    local ets_gui = player.gui.center['ets-gui']
    if ets_gui then
        ets_gui.destroy()
    end
end

function ElectricTradingStationTextChanged(event)
    local player = game.get_player(event.player_index)
    local ets_unit_number = storage.open_electric_trading_station[player.index]
    if ets_unit_number == nil then return end
    local textfield = event.element
    if textfield.name == "sell" then
        storage.electric_trading_stations[ets_unit_number].sell_price = max(tonumber(textfield.text) or 1, 1)
    end
    if textfield.name == "buy" then
        storage.electric_trading_stations[ets_unit_number].buy_bid = max(tonumber(textfield.text) or 1, 0)
    end
end
