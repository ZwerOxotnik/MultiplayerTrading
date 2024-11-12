--[[
    Multiplayer Trading by Luke Perkin.
    Some concepts taken from Teamwork mod (credit to DragoNFly1) and Diplomacy mod (credit to ZwerOxotnik).
]]
-- Modfied by ZwerOxotnik

function Area(position, radius)
    local x = position.x
    local y = position.y
    return {
        {x - radius, y - radius},
        {x + radius, y + radius}
    }
end
local Area = Area

require "systems/land-claim"
require "systems/specializations"
require "systems/electric-trading-station"


--#region Constants
local tostring = tostring
local max = math.max
local call = remote.call
local START_ITEMS = {name = "small-electric-pole", count = 10}
local IS_LAND_CLAIM = settings.startup['land-claim'].value
---#endregion


--#region Storage data
local __electric_trading_stations
local __credit_mints
local __sell_boxes
local __orders
local __open_order
local __early_bird_tech
local __specializations
---#endregion


--#region global settings
local minting_speed = settings.global['credit-mint-speed'].value
local mint_money_per_cycle = settings.global['mint-money-per-cycle'].value
land_claim_cost = settings.global['land-claim-cost'].value
--#endregion


PLACE_NOMANSLAND_ITEMS = {
    ['locomotive'] = true,
    ['cargo-wagon'] = true,
    ['fluid-wagon'] = true,
    ['artillery-wagon'] = true,
    ['tank'] = true,
    ['car'] = true,
    ['player'] = true,
    ['transport-belt'] = true,
    ['fast-transport-belt'] = true,
    ['express-transport-belt'] = true,
    ['pipe'] = true,
    ['straight-rail'] = true,
    ['curved-rail'] = true,
    ['small-electric-pole'] = true,
    ['medium-electric-pole'] = true,
    ['big-electric-pole'] = true,
    ['substation'] = true,
    ['sell-box'] = true,
    ['buy-box'] = true,
}

PLACE_ENEMY_TERRITORY_ITEMS = {
    ['sell-box'] = true,
    ['buy-box'] = true,
}

POLES = {
    'small-electric-pole',
    'medium-electric-pole',
    'big-electric-pole',
    'substation'
}


local function clear_invalid_entities()
    for unit_number, entity in pairs(__sell_boxes) do
        if not entity.valid then
            __sell_boxes[unit_number] = nil
            __orders[unit_number] = nil
        end
    end
    for unit_number, data in pairs(__credit_mints) do
        if not data.entity.valid then -- TODO: check, is data.entity has weird characters?
            __credit_mints[unit_number] = nil
        end
    end
    for unit_number, data in pairs(__electric_trading_stations) do
        if not data.entity.valid then -- TODO: check, is data.entity has weird characters?
            __electric_trading_stations[unit_number] = nil
        end
    end
    for unit_number, data in pairs(__orders) do
        if not data.entity.valid then -- TODO: check, is data.entity has weird characters?
            __orders[unit_number] = nil
        end
    end
end

local function link_data()
    __credit_mints = storage.credit_mints
    __electric_trading_stations = storage.electric_trading_stations
    __sell_boxes = storage.sell_boxes
    __orders = storage.orders
    __open_order = storage.open_order
    __early_bird_tech = storage.early_bird_tech
    __specializations = storage.specializations
end

local function CheckGlobalData()
    storage.sell_boxes   = storage.sell_boxes or {}
    storage.orders       = storage.orders or {}
    storage.credit_mints = storage.credit_mints or {}
    storage.open_order   = storage.open_order or {}
    storage.output_stat  = storage.output_stat or {}
    storage.specializations = storage.specializations or {}
    storage.early_bird_tech = storage.early_bird_tech or {}
    storage.electric_trading_stations = storage.electric_trading_stations or {}

    link_data()

    clear_invalid_entities()
    for player_index in pairs(__open_order) do
        if game.get_player(player_index) == nil then
            __open_order[player_index] = nil
        end
    end
end

local function on_force_created(event)
    for name, technology in pairs(event.force.technologies) do
        if string.find(name, "-mpt-") ~= nil then
            technology.enabled = false
        end
    end
end

local function on_init()
    CheckGlobalData()
    for _, force in pairs(game.forces) do
        on_force_created({force=force})
    end
    for _, player in pairs(game.players) do
        player.insert(START_ITEMS)
    end
end

local function on_load()
    link_data()
end

local function on_player_removed(event)
    __open_order[event.player_index] = nil
end

local function fix_force_recipes(event)
  local force = event.force
  local recipes = force.recipes
  local force_name = force.name
  for spec_name, _force_name in pairs(__specializations)  do
    if _force_name == force_name then
      recipes[spec_name].enabled = true
    end
  end
end

local function on_research_finished(event)
    local research = event.research
    local tech_cost_multiplier = settings.startup['early-bird-multiplier'].value
    local base_tech_name = string.gsub(research.name, "%-mpt%-[0-9]+", "")
    if research.force.technologies[base_tech_name .. "-mpt-1"] == nil then
        return
    end
    __early_bird_tech[research.force.name .. "/" .. base_tech_name] = true
    for _, force in pairs(game.forces) do
        local force_tech_state_id = force.name .. "/" .. base_tech_name
        local tech = force.technologies[research.name]
        if not tech.researched then
            local progress = tech.saved_progress
            if string.find(research.name, "-mpt-") ~= nil then
                -- Another force has researched the 2nd, 3rd or 4th version of this tech.
                local tier_index = string.find(research.name, "[0-9]$")
                local tier = tonumber(string.sub( research.name, tier_index ))
                if tier < 4 then
                    local next_tech_name =  base_tech_name .. "-mpt-" .. tostring(tier + 1)
					local tech2 = force.technologies[next_tech_name]
                    if progress then
                        progress = progress / math.pow(tech_cost_multiplier, tier + 1)
                        tech2.saved_progress = progress
                    end
                    if not __early_bird_tech[force_tech_state_id] then
                        tech2.enabled = true
                    end
                    tech.enabled = false
                end
            else
                -- Another force has researched this tech for the 1st time.
                local next_tech_name = research.name .. "-mpt-1"
				local tech2 = force.technologies[next_tech_name]
                if progress then
                    progress = progress / tech_cost_multiplier
                    tech2.saved_progress = progress
                end
                tech2.enabled = true
                tech.enabled = false
            end
        end
    end
end

local special_builds = {
    ["sell-box"] = function(entity)
        entity.operable = false
        __sell_boxes[entity.unit_number] = entity
    end,
    ["buy-box"] = function(entity)
        entity.operable = false
        __sell_boxes[entity.unit_number] = entity
    end,
    ["credit-mint"] = function(entity)
        __credit_mints[entity.unit_number] = {
            ['entity'] = entity,
            ['progress'] = 0
        }
    end,
    ["electric-trading-station"] = function(entity)
        __electric_trading_stations[entity.unit_number] = {
            ['entity'] = entity,
            sell_price = 1,
            buy_bid = 1
        }
    end,
}
local function HandleEntityBuild(entity)
    local f = special_builds[entity.name]
    if f then
        f(entity)
    end
end

local function HandleEntityMined(event)
    local entity = event.entity
    local entity_name = entity.name
    if entity.type == "electric-pole" then
        ClaimPoleRemoved(entity)
        return
    elseif entity_name == "credit-mint" then
        __credit_mints[entity.unit_number] = nil
    elseif entity_name == "electric-trading-station" then
        __electric_trading_stations[entity.unit_number] = nil
    else -- "buy-box", "sell-box"
        local unit_number = entity.unit_number
        __sell_boxes[unit_number] = nil
        __orders[unit_number] = nil
    end
end

local function HandleEntityDied(event)
    local entity = event.entity
    local entity_name = entity.name
    if entity_name == "credit-mint" then
        __credit_mints[entity.unit_number] = nil
    elseif entity_name == "electric-trading-station" then
        __electric_trading_stations[entity.unit_number] = nil
    else -- "buy-box", "sell-box"
        local unit_number = entity.unit_number
        __sell_boxes[unit_number] = nil
        __orders[unit_number] = nil
    end
end

-- TODO: OPTIMIZE!
local function check_boxes()
    for unit_number, sell_box in pairs(__sell_boxes) do
        local sell_order = __orders[unit_number]
        if sell_order then -- it seems wrong
            local sell_order_name = sell_order.name
            if sell_order_name then
                local item_count = sell_box.get_item_count(sell_order_name)
                if item_count > 0 then
                    local buy_boxes = sell_box.surface.find_entities_filtered{
                        area = Area(sell_box.position, 3),
                        name = "buy-box"
                    }
                    for i = 1, #buy_boxes do -- it seems overcomplex
                        local buy_box = buy_boxes[i]
                        if buy_box.force ~= sell_box.force then
                            local buy_order = __orders[buy_box.unit_number]
                            if buy_order and buy_order.name == sell_order_name and buy_order.value >= sell_order.value then
                                Transaction(sell_box, buy_box, buy_order, 1)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function check_credit_mints()
    local forces_money = call("EasyAPI", "get_forces_money")
    local forces_money_copy = {}
    for force_index, value in pairs(forces_money) do
        forces_money_copy[force_index] = value
    end

    -- TODO: optimize
    for _, credit_mint in pairs(__credit_mints) do
        local entity = credit_mint.entity
        local energy = entity.energy / entity.electric_buffer_size
        local progress = credit_mint.progress + (energy * minting_speed)
        if progress >= 0.10 then
            credit_mint.progress = 0
            local force_index = entity.force.index
            forces_money_copy[force_index] = forces_money_copy[force_index] + mint_money_per_cycle
        else
            credit_mint.progress = progress
        end
    end

    local forces = game.forces
    for force_index, value in pairs(forces_money_copy) do
        if forces_money[force_index] ~= value then
            call("EasyAPI", "set_force_money", forces[force_index], value)
        end
    end
end

function CanTransferItemStack(source_inventory, destination_inventory, item_stack)
    return source_inventory.get_item_count(item_stack.name) >= item_stack.count
        and destination_inventory.can_insert(item_stack)
end

function CanTransferCredits(control, amount)
    local force_credits = call("EasyAPI", "get_force_money", control.force.index)
    if force_credits and force_credits >= amount then
        return true
    end
    return false
end

function AddCredits(force, amount)
	call("EasyAPI", "deposit_force_money", force, amount) -- I don't recommend to change it in some cases, change events.

	-- force.item_production_statistics.on_flow("coin", amount) -- TODO: recheck
end

function TransferCredits(buy_force, sell_force, amount)
    AddCredits(buy_force, -amount)
    AddCredits(sell_force, amount)
end

---@return table
function Transaction(source_inventory, destination_inventory, order, count)
    if order and source_inventory and destination_inventory and count > 0 then
        local order_name = order.name
        local item_stack = {name = order_name, count = count}
        local cost = order.value * item_stack.count
        local source_has_items = source_inventory.get_item_count(order_name) > 0 -- TODO: change
        local can_xfer_stack = CanTransferItemStack(source_inventory, destination_inventory, item_stack)
        local can_xfer_credits = CanTransferCredits(destination_inventory, cost)
        if can_xfer_stack and can_xfer_credits then
            source_inventory.remove_item(item_stack)
            destination_inventory.insert(item_stack)
            TransferCredits(destination_inventory.force, source_inventory.force, cost)
            return {success = true}
        else
            return {
                success = false,
                ['no_items_in_source'] = not source_has_items,
                ['no_xfer_stack'] = (not can_xfer_stack) and source_has_items,
                ['no_xfer_credits'] = not can_xfer_credits
            }
        end
    end
    return {success = false}
end

function SellboxGUIOpen(player, entity)
    local player_index = player.index
    if entity and entity.valid and __open_order[player_index] == nil then
        local same_force = (entity.force == player.force)
        if entity.name == "sell-box" then
            local unit_number = entity.unit_number
            local frame = player.gui.center.add{type = "frame", direction = "vertical", name = "sell-box-gui", caption = "Sell Box"}
            local row1 = frame.add{type = "flow", direction = "horizontal"}
            local item_picker = row1.add{type = "choose-elem-button", elem_type = "item", name = "sell-box-item"}
            local item_value
            if same_force then
                item_value = row1.add{type = "textfield", text = "1", name = "sell-box-value"}
            else
                item_value = row1.add{type = "label", caption = "price: ", name = "sell-box-value"}
                item_picker.locked = true
            end
            local order = __orders[unit_number]
            if not order then
                __orders[unit_number] = {
                    type = "sell",
                    ['entity'] = entity,
                    value = 1
                }
                order = __orders[unit_number]
            end
            item_picker.elem_value = order.name
            __open_order[player_index] = order
            if same_force then
                item_value.text = tostring(order.value)
            else
                item_value.caption = "price: " .. tostring(order.value)
                local row2 = frame.add{type = "flow", direction = "horizontal"}
                row2.add{type = "button", caption = "Buy 1", name = "buy-button-1"}
                row2.add{type = "button", caption = "Buy Max", name = "buy-button-all"}
            end
        elseif entity.name == "buy-box" then
            local unit_number = entity.unit_number
            local frame = player.gui.center.add{type = "frame", direction = "vertical", name = "buy-box-gui", caption = "Buy Box"}
            local row1 = frame.add{type = "flow", direction = "horizontal"}
            local item_picker = row1.add{type = "choose-elem-button", elem_type = "item", name = "buy-box-item"}
            local item_value
            if same_force then
                item_value = row1.add{type = "textfield", text = "1", name = "buy-box-value"}
            else
                item_value = row1.add{type = "label", caption = "price: ", name = "sell-box-value"}
                item_picker.locked = true
            end
            local order = __orders[unit_number]
            if not order then
                order = {
                    type = "buy",
                    ['entity'] = entity,
                    value = 1
                }
                __orders[unit_number] = order
            end
            item_picker.elem_value = order.name
            __open_order[player_index] = order
            if same_force then
                item_value.text = tostring(order.value)
            else
                item_value.caption = "price: " .. tostring(order.value)
                local row2 = frame.add{type = "flow", direction = "horizontal"}
                row2.add{type = "button", caption = "Sell 1", name = "sell-button-1"}
                row2.add{type = "button", caption = "Sell Max", name = "sell-button-all"}
            end
        end
    end
end

function SellOrBuyGUIClose(event)
    local player = game.get_player(event.player_index)
    local gui = player.gui.center
    if gui['sell-box-gui'] then
        __open_order[player.index] = nil
        gui['sell-box-gui'].destroy()
    end
    if gui['buy-box-gui'] then
        __open_order[player.index] = nil
        gui['buy-box-gui'].destroy()
    end
end

local function on_gui_text_changed(event)
    local player = game.get_player(event.player_index)
    local element = event.element
    if element.parent.name == "ets-gui" then -- TODO: check
        ElectricTradingStationTextChanged(event)
    end

    local element_name = element.name
    if element_name == "buy-box-value" then
        __orders[__open_order[player.index].entity.unit_number].value = max(tonumber(element.text) or 1, 1)
    elseif element_name == "sell-box-value" then
        __orders[__open_order[player.index].entity.unit_number].value = max(tonumber(element.text) or 1, 1)
    end
end

local function on_gui_elem_changed(event)
    local player = game.get_player(event.player_index)

    local element = event.element
    local element_name = element.name
    if element_name == "buy-box-item" then
        __orders[__open_order[player.index].entity.unit_number].name = element.elem_value
    elseif element_name == "sell-box-item" then
        __orders[__open_order[player.index].entity.unit_number].name = element.elem_value
    end
end

local function on_gui_click(event)
    local player = game.get_player(event.player_index)
    local element = event.element
    local order = __open_order[player.index]
    if order == nil then return end
    local order_name = order.name
    if order_name == nil then return end

    local result = nil
    local element_name = element.name
    if element_name == "buy-button-1" then
        result = Transaction(order.entity, player, order, 1)
    elseif element_name == "buy-button-all" then
        local max_count = order.entity.get_item_count(order_name)
        result = Transaction(order.entity, player, order, max_count)
    elseif element_name == "sell-button-1" then
        result = Transaction(player, order.entity, order, 1)
    elseif element_name == "sell-button-all" then
        local entity = order.entity
        local max_count = entity.get_item_count(order_name)
        local count = prototypes.item[order_name].stack_size - max_count
        count = math.min( player.get_item_count(order_name), count )
        result = Transaction(player, entity, order, count)
    end
    if result and not result.success then
        if result.no_items_in_source then
            player.print{"message.none-available"}
        end
        if result.no_xfer_credits then
            player.print{"message.no-credits"}
        end
        if result.no_xfer_stack then
            player.print{"message.no-room"}
        end
    end
end

local SETTINS = {
    ["mint-money-per-cycle"] = function(value)
        mint_money_per_cycle = value
    end,
    ["credit-mint-speed"] = function(value)
        minting_speed = value
    end,
    ["land-claim-cost"] = function(value)
        land_claim_cost = value
    end,
}
local function on_runtime_mod_setting_changed(event)
    if event.setting_type ~= "runtime-global" then return end

    local f = SETTINS[event.setting]
    if f then f(settings.global[event.setting].value) end
end

local function on_configuration_changed(event)
    CheckGlobalData()

    for force_name, force in pairs(game.forces) do
        local recipes = force.recipes
        for spec_name, _force_name in pairs(__specializations) do
            if _force_name == force_name then
                recipes[spec_name].enabled = true
            end
        end
    end


    local mod_changes = event.mod_changes["m-multiplayertrading"]
    if not (mod_changes and mod_changes.old_version) then return end

    local version = tonumber(string.gmatch(mod_changes.old_version, "%d+.%d+")())
  if version < 0.7 then
        -- Check unit numbers
        for _unit_number, entity in pairs(__sell_boxes) do
            local unit_number = entity.unit_number
            if _unit_number ~= unit_number then
                __sell_boxes[unit_number] = __sell_boxes[_unit_number]
                __sell_boxes[_unit_number] = nil
                if __orders[_unit_number] then
                    __orders[unit_number] = {
                        value = __orders[_unit_number].value,
                        name = __orders[_unit_number].name
                    }
                    __orders[_unit_number] = nil
                end
            end
        end
        for _unit_number, data in pairs(__credit_mints) do
            local unit_number = data.entity.unit_number
            if _unit_number ~= unit_number then -- TODO: check, is data.entity has weird characters?
                __credit_mints[unit_number] = {
                    ['entity'] = __credit_mints[_unit_number].entity,
                    ['progress'] = __credit_mints[_unit_number].progress
                }
                __credit_mints[_unit_number] = nil
            end
        end
    end
  if version < 0.8 then
        for _unit_number, data in pairs(__electric_trading_stations) do
            local unit_number = data.entity.unit_number
            if _unit_number ~= unit_number then -- TODO: check, is data.entity has weird characters?
                __electric_trading_stations[unit_number] = {
                    ['entity'] = __electric_trading_stations[_unit_number].entity,
                    sell_price = __electric_trading_stations[_unit_number].sell_price,
                    buy_bid = __electric_trading_stations[_unit_number].buy_bid
                }
                __electric_trading_stations[_unit_number] = nil
            end
        end
    end
    if version < 0.9 then
        for force_name, value in pairs(storage.credits) do
            local force = game.forces[force_name]
            if game.forces[force_name] then
                call("EasyAPI", "set_force_money", force, value)
            end
        end
        storage.credits = nil
        for _, player in pairs(game.players) do
            local credits_element = player.gui.top.credits
            if credits_element then
                credits_element.destroy()
            end
        end
    end
end


script.on_init(on_init)
script.on_load(on_load)
script.on_configuration_changed(on_configuration_changed)


script.on_event(defines.events.on_built_entity, function(event)
    local entity = event.entity
    if IS_LAND_CLAIM then -- TODO: refactor
        local is_electric_pole = false
        if entity.type == "electric-pole" then
            is_electric_pole = true
        end
        local player = game.get_player(event.player_index)
		local is_check = true
		if player.valid and player.controller_type == defines.controllers.editor then
			is_check = false
		end
		if is_check then
			local can_build = DestroyInvalidEntities(entity, player)
			if can_build then
				if is_electric_pole then
					ClaimPoleBuilt(entity)
					DisallowElectricityTheft(entity, player.force)
					return
				end
			else
				return
			end
		end
    end

    HandleEntityBuild(entity)
end)
script.on_event(defines.events.on_robot_built_entity, function(event)
    local entity = event.entity
    if IS_LAND_CLAIM then -- TODO: refactor
        local is_electric_pole = false
        if entity.type == "electric-pole" then
            is_electric_pole = true
        end
        local can_build = DestroyInvalidEntities(entity)
        if can_build then
            if is_electric_pole then
				ClaimPoleBuilt(entity)
                DisallowElectricityTheft(entity, event.robot.force)
            end
            return
        else
            return
        end
    end

    HandleEntityBuild(entity)
end)


if IS_LAND_CLAIM then
    script.on_event(
        defines.events.on_player_mined_entity,
        HandleEntityMined,
        {
            {filter = "type", type = "electric-pole", mode = "or"},
            {filter = "name", name = "sell-box", mode = "or"},
            {filter = "name", name = "buy-box", mode = "or"},
            {filter = "name", name = "credit-mint", mode = "or"},
            {filter = "name", name = "electric-trading-station", mode = "or"}
        }
    )
end

do
    local filters = {
        {filter = "name", name = "sell-box", mode = "or"},
        {filter = "name", name = "buy-box", mode = "or"},
        {filter = "name", name = "credit-mint", mode = "or"},
        {filter = "name", name = "electric-trading-station", mode = "or"}
    }
    script.on_event(
        defines.events.on_entity_died,
        HandleEntityDied,
        filters
    )
    script.on_event(
        defines.events.on_robot_mined_entity,
        HandleEntityDied,
        filters
    )
    script.on_event(
        defines.events.script_raised_destroy,
        HandleEntityDied,
        filters
    )
    if not IS_LAND_CLAIM then
        script.on_event(
            defines.events.on_player_mined_entity,
            HandleEntityDied,
            filters
        )
    end
end

do
    local function on_player_created(event)
        game.get_player(event.player_index).insert(START_ITEMS)
    end
    script.on_event(defines.events.on_player_created, function(event)
        pcall(on_player_created, event)
    end)
end

script.on_event("sellbox-gui-open", function(event)
    local player = game.get_player(event.player_index)
    if not (player and player.valid) then return end
    local entity = player.selected
    if not (entity and entity.valid) then return end

    local entity_name = entity.name
    if entity and (entity_name == "sell-box" or entity_name == "buy-box") then
        SellOrBuyGUIClose(event)
        SellboxGUIOpen(player, entity)
    elseif entity and entity_name == "electric-trading-station" then
        ElectricTradingStationGUIClose(event)
        ElectricTradingStationGUIOpen(event)
    else
        SellOrBuyGUIClose(event)
        ElectricTradingStationGUIClose(event)
    end
end)

script.on_event("sellbox-gui-close", function(event)
    SellOrBuyGUIClose(event)
    ElectricTradingStationGUIClose(event)
end)

if settings.startup['specializations'].value then
    script.on_event("specialization-gui", function(event)
        pcall(SpecializationGUI, game.get_player(event.player_index))
    end)
end

script.on_event(defines.events.on_surface_deleted, clear_invalid_entities)
script.on_event(defines.events.on_surface_cleared, clear_invalid_entities)
script.on_event(defines.events.on_chunk_deleted, clear_invalid_entities)
script.on_event(defines.events.on_player_removed, on_player_removed)
script.on_event(defines.events.on_force_reset, function(event)
    pcall(fix_force_recipes, event)
end)
script.on_event(defines.events.on_technology_effects_reset, function(event)
    pcall(fix_force_recipes, event)
end)
script.on_event(defines.events.on_gui_text_changed, function(event)
    pcall(on_gui_text_changed, event)
end)
script.on_event(defines.events.on_gui_elem_changed, function(event)
    pcall(on_gui_elem_changed, event)
end)
script.on_event(defines.events.on_gui_click, function(event)
    pcall(on_gui_click, event)
end)
script.on_event(defines.events.on_force_created, on_force_created)
script.on_event(defines.events.on_runtime_mod_setting_changed, on_runtime_mod_setting_changed)
if settings.startup['early-bird-research'].value then
    script.on_event(defines.events.on_research_finished, on_research_finished)
end

remote.add_interface("multiplayer-trading", {})

script.on_nth_tick(60, function()
    UpdateElectricTradingStations(__electric_trading_stations)
end)

script.on_nth_tick(15, check_boxes)
script.on_nth_tick(900, check_credit_mints)

if settings.startup['specializations'].value == true then
    script.on_nth_tick(3600, UpdateSpecializations)
end
