local SPECIALIZATIONS = require("specializations-data")


local function GetLastStatForSpecialization(spec, force)
    local id = force.name .. "/" .. spec.name
	local output_stats = storage.output_stat
	local output_stat = output_stats[id]
    if output_stat then
		return output_stat
	end

	output_stat = {
		sum = 0,
		rate = 0
	}
	output_stats[id] = output_stat
	return output_stat
end

local function GetCurrentStatSumForSpecialization(spec, force)
    local output_sum = 0
    if spec.requirement.fluid then
		for _, surface in pairs(game.surfaces) do
			output_sum = output_sum + force.get_fluid_production_statistics(surface).get_input_count(spec.requirement.name)
		end
    else
		for _, surface in pairs(game.surfaces) do
			output_sum = output_sum + force.get_item_production_statistics(surface).get_input_count(spec.requirement.name)
		end
    end
    return output_sum
end

local function GetSpecializationItemSprite(spec)
    local sprite
    if spec.requirement.fluid then
        sprite = "fluid/"..spec.requirement.name
    else
        sprite = "item/"..spec.requirement.name
    end
    return sprite
end

local function GetSpecializationItemNameLocale(spec)
    local locale
    if spec.requirement.fluid then
        locale = "fluid-name." .. spec.requirement.name
    else
        locale = "item-name." .. spec.requirement.name
    end
    return locale
end

-- TODO: optimize
function UpdateSpecializations()
    local specializations = storage.specializations
    for _, player in pairs(game.players) do -- TODO: change to game.connected_players (don't forget about other events)
        local gui = player.gui.left['specialization-gui']
        if gui then
            gui.destroy()
            SpecializationGUI(player)
        end
    end

    for force_name, force in pairs(game.forces) do
        local recipes = force.recipes
        for _, spec in pairs(SPECIALIZATIONS) do
            local spec_name = spec.name
            if specializations[spec_name] == nil then
                local current_sum = GetCurrentStatSumForSpecialization(spec, force)
                local last_stat = GetLastStatForSpecialization(spec, force)
                local production_rate = (current_sum - last_stat.sum)
                last_stat.sum = current_sum
                last_stat.rate = production_rate
                if production_rate >= spec.requirement.production then
                    specializations[spec_name] = force_name
                    recipes[spec_name].enabled = true
                    local item_name = {GetSpecializationItemNameLocale(spec)}
                    force.print({
                        "message.specialization-unlock",
                        item_name
                    })
                    game.print({
                        "message.specialization-notice",
                        force_name,
                        item_name
                    })
                end
            end
        end
    end
end

local HORIZONTAL_FLOW = {type = "flow"}
local VERTICAL_FLOW   = {type = "flow", direction = "vertical"}
function SpecializationGUI( player )
    local leftGUI = player.gui.left
    if leftGUI['specialization-gui'] then
        leftGUI['specialization-gui'].destroy()
        return
    end

    local frame = leftGUI.add{type = "frame", name = "specialization-gui", caption = "Specializations"}
    local flow = frame.add(VERTICAL_FLOW)
    local specializations = storage.specializations
    for _, spec in pairs(SPECIALIZATIONS) do
        local row = flow.add(HORIZONTAL_FLOW)
        local force_name = specializations[spec.name]

        local sprite = GetSpecializationItemSprite(spec)
        local tooltip = GetSpecializationItemNameLocale(spec)
        row.add{type = "sprite", sprite = sprite, tooltip = {tooltip}}

        local style = "bold_label"
        if force_name == nil then
            style = "bold_label"
            local requirement = row.add(VERTICAL_FLOW)
            local production = spec.requirement.production
            local caption = "Available (produce " .. tostring(production) .. "/min to unlock)"
            requirement.add{type = "label", caption = caption, style = style}
            local stat = GetLastStatForSpecialization(spec, player.force)
            local progress = stat.rate / production
            requirement.add{type = "progressbar", name = "progress", value = progress}
        else
            if force_name == player.force.name then
                style = "bold_green_label"
            else
                style = "bold_red_label"
            end
            row.add{type = "label", caption = force_name, style = style}
        end
    end
end
