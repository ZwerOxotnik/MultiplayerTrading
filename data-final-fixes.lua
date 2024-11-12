local function copy(thing)
    if type(thing) == 'table' then
        local result = {}
        for key, value in pairs(thing) do
            result[key] = copy(value)
        end
        return result
    else
        return thing
    end
end

if settings.startup['land-claim'].value then
    local electric_poles = data.raw['electric-pole']
    local poles = {"small-electric-pole", "medium-electric-pole", "big-electric-pole", "substation"}
    for _, pole_name in ipairs(poles) do
        local prototype = electric_poles[pole_name]
        if prototype then
            if prototype.supply_area_distance < 20 then
                prototype.supply_area_distance = prototype.supply_area_distance * 2
            end
            if prototype.maximum_wire_distance < 20 then
                prototype.maximum_wire_distance = prototype.maximum_wire_distance * 2
            end
        end
    end
end

-- This is kinda a dirty way to fix bugs
local allow_early_bird_research = true
if mods["space-exploration"] or mods["Krastorio2"] or mods["angelsrefining"] or mods["bobplates"] then
    allow_early_bird_research = false
end

if allow_early_bird_research and settings.startup['early-bird-research'].value then
    -- Find non-upgrade tech where no other tech uses it as a prerequisite.
	local technologies = data.raw.technology
    local function is_tech_valid_for_early_bird( tech )
        for _, other_technology in pairs(technologies) do
            if other_technology.prerequisites then
                for _, prerequisite in ipairs(other_technology.prerequisites) do
                    if prerequisite == tech.name then
                        return false
                    end
                end
            end
        end
        return true
    end
    local valid_tech = {}
    for tech_name, technology in pairs(technologies) do
        if not technology.upgrade and technology.unit and technology.unit.count and is_tech_valid_for_early_bird(technology) then
            table.insert(valid_tech, tech_name)
        end
    end
    local earlybird_tech = {}
    for _, tech_name in ipairs(valid_tech) do
        local technology = technologies[tech_name]
        for i=1, 4 do
            local expensive_tech = copy(technology)
            local multiplier = math.pow(settings.startup['early-bird-multiplier'].value, i)
            expensive_tech.unit.count = expensive_tech.unit.count * multiplier
            expensive_tech.name = tech_name .. "-mpt-" .. tostring(i)
            expensive_tech.localised_name =  {"technology-name.early-bird", {"technology-name." .. tech_name}, tostring(multiplier)}
            expensive_tech.localised_description = {"technology-description." .. tech_name}
            expensive_tech.enabled = false
            table.insert(earlybird_tech, expensive_tech)
        end
    end
    data:extend(earlybird_tech)
end
