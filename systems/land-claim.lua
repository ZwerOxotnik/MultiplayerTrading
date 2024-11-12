local call = remote.call
local Area = Area
local RAISE_DESTROY = {raise_destroy = true}

---@return LuaForce?
local function GetClaimedLand(entity)
    local entity_prototypes = prototypes.entity
    local find_entities_filtered = entity.surface.find_entities_filtered
    local is_electric_pole = false
    local supply_area_distance
    if entity.type == "electric-pole" then
        is_electric_pole = true
        supply_area_distance = entity.prototype.get_supply_area_distance(entity.quality)
    end
    local filter = {
        area = 0,
        name = ""
    }
    local entity_force = entity.force
    for i=1, #POLES do
        local poleName = POLES[i]
        local prototype = entity_prototypes[poleName]
        local radius
        if is_electric_pole then
            radius = prototype.get_supply_area_distance() + supply_area_distance
        else
            radius = prototype.get_supply_area_distance()
        end
        filter.area = Area(entity.position, radius)
        filter.name = poleName
        local near_poles = find_entities_filtered(filter)
        if #near_poles > 0 then
            for j=1, #near_poles do
                local pole_force = near_poles[j].force
                if pole_force ~= entity_force then
                    return pole_force
                end
            end
            return entity_force
        end
    end
end

local function GetClaimCost(entity)
    local supply_area = entity.prototype.get_supply_area_distance(entity.quality)
    local cost = supply_area * supply_area * land_claim_cost
    return cost
end

local function GetClaimTransferableCost(entity)
    if entity.type == "electric-pole" then
        local supply_area = entity.prototype.get_supply_area_distance(entity.quality)
        local cost = supply_area * supply_area * land_claim_cost
        return cost, CanTransferCredits(entity, cost)
    end
    return false
end

function ClaimPoleBuilt(entity)
    local cost = GetClaimCost(entity)
    if cost then
        call("EasyAPI", "deposit_force_money", entity.force, -cost)
    end
end

function ClaimPoleRemoved(entity)
	local force = entity.force
    local cost = GetClaimCost(entity)
    if cost and call("EasyAPI", "get_force_money", force.index) then
        AddCredits(force, cost)
    end
end

---@param entity LuaEntity
---@param player? LuaPlayer
---@return boolean
function DestroyInvalidEntities(entity, player) -- TODO: refactor!
    local instigatingForce = entity.force
    if instigatingForce then
        -- Check if land is claimed.
        local claimedLand = GetClaimedLand(entity)
        local cost, is_affordable = GetClaimTransferableCost(entity)
        local noBuildDueToEnemyLand = (
            claimedLand and claimedLand ~= instigatingForce
            and not claimedLand.get_friend(instigatingForce)
            and not PLACE_ENEMY_TERRITORY_ITEMS[entity.name]
        )
        local noBuildDueToNoMansLand = (claimedLand == nil and not PLACE_NOMANSLAND_ITEMS[entity.name])
        local noBuildDueToExpense = (cost and not is_affordable)
        if player then
            if noBuildDueToExpense then
                player.print{"message.cannot-claim"}
            end
            if noBuildDueToEnemyLand then
                player.print{"message.no-build-opponent-land"}
            end
            if noBuildDueToNoMansLand then
                player.print{"message.no-mans-land-restriction"}
            end
        end
        -- Don't allow build if invalid build spot.
        if noBuildDueToEnemyLand or noBuildDueToNoMansLand or noBuildDueToExpense then
            if player then
                player.mine_entity(entity, true)
                -- dirty fix
                if cost then
                    local money = call("EasyAPI", "get_force_money", instigatingForce.index)
                    if money then
                        AddCredits(instigatingForce, -cost)
                    end
                end
            else
                entity.destroy(RAISE_DESTROY)
            end
            return false
        end
        return true
    end
end
