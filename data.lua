SPECIALIZATIONS = require "specializations-data"

local GlobalMarket = util.table.deepcopy(data.raw.market['market'])
GlobalMarket.name = "global-market"
GlobalMarket.icon_size = 64
GlobalMarket.allow_access_to_all_forces = false
GlobalMarket.minable = {mining_time = 2, result = "global-market"}
GlobalMarket.max_health = 600
GlobalMarket.resistances = {
    {type = "fire", percent = 90}, {type = "impact", percent = 60}
}

local buyBox = util.table.deepcopy(data.raw.container['steel-chest'])
buyBox.name = "buy-box"
buyBox.icon = "__m-multiplayertrading__/graphics/icons/buy-box.png"
buyBox.icon_size = 32
buyBox.picture.filename = "__m-multiplayertrading__/graphics/entity/buy-box.png"
buyBox.picture = {
    layers = {
        {
            filename = "__m-multiplayertrading__/graphics/entity/buy-box.png",
            priority = "extra-high",
            width = 34,
            height = 40,
            shift = util.by_pixel(0, -3),
            hr_version = {
                filename = "__m-multiplayertrading__/graphics/entity/hr-buy-box.png",
                priority = "extra-high",
                width = 68,
                height = 79,
                shift = util.by_pixel(0, -3),
                scale = 0.5
            }
        }, {
            filename = "__base__/graphics/entity/compilatron-chest/compilatron-chest-shadow.png",
            priority = "extra-high",
            width = 57,
            height = 21,
            shift = util.by_pixel(12, 6),
            draw_as_shadow = true,
            hr_version = {
                filename = "__base__/graphics/entity/compilatron-chest/hr-compilatron-chest-shadow.png",
                priority = "extra-high",
                width = 114,
                height = 41,
                shift = util.by_pixel(12, 6),
                draw_as_shadow = true,
                scale = 0.5
            }
        }
    }
}
local buyBoxItem = util.table.deepcopy(data.raw.item['steel-chest'])
buyBoxItem.name = "buy-box"
buyBoxItem.icon = "__m-multiplayertrading__/graphics/icons/buy-box.png"
buyBoxItem.icon_size = 32
buyBoxItem.place_result = "buy-box"
buyBoxItem.order = "a[items]-c[steel-chest]-z[buy-box]"
local sellBox = util.table.deepcopy(data.raw.container['steel-chest'])
sellBox.name = "sell-box"
sellBox.icon = "__m-multiplayertrading__/graphics/icons/sell-box.png"
sellBox.icon_size = 32
sellBox.picture = {
    layers = {
        {
            filename = "__m-multiplayertrading__/graphics/entity/sell-box.png",
            priority = "extra-high",
            width = 34,
            height = 40,
            shift = util.by_pixel(0, -3),
            hr_version = {
                filename = "__m-multiplayertrading__/graphics/entity/hr-sell-box.png",
                priority = "extra-high",
                width = 68,
                height = 79,
                shift = util.by_pixel(0, -3),
                scale = 0.5
            }
        }, {
            filename = "__base__/graphics/entity/compilatron-chest/compilatron-chest-shadow.png",
            priority = "extra-high",
            width = 57,
            height = 21,
            shift = util.by_pixel(12, 6),
            draw_as_shadow = true,
            hr_version = {
                filename = "__base__/graphics/entity/compilatron-chest/hr-compilatron-chest-shadow.png",
                priority = "extra-high",
                width = 114,
                height = 41,
                shift = util.by_pixel(12, 6),
                draw_as_shadow = true,
                scale = 0.5
            }
        }
    }
}
sellBox.picture.filename =
    "__m-multiplayertrading__/graphics/entity/sell-box.png"
sellBox.inventory_size = 1
local sellBoxItem = util.table.deepcopy(data.raw.item['steel-chest'])
sellBoxItem.name = "sell-box"
sellBoxItem.icon = "__m-multiplayertrading__/graphics/icons/sell-box.png"
sellBoxItem.icon_size = 32
sellBoxItem.place_result = "sell-box"
sellBoxItem.order = "a[items]-c[steel-chest]-z[sell-box]"

local creditMint = util.table.deepcopy(data.raw.radar['radar'])
creditMint.name = "credit-mint"
creditMint.energy_usage = settings.startup['credit-mint-energy-usage'].value

local electricTradingStation = {
    type = "electric-energy-interface",
    name = "electric-trading-station",
    icon = "__base__/graphics/icons/accumulator.png",
    icon_size = 64,
    icon_mipmaps = 4,
    flags = {"placeable-neutral", "player-creation"},
    minable = {
        hardness = 0.2,
        mining_time = 0.5,
        result = "electric-trading-station"
    },
    max_health = 100,
    corpse = "accumulator-remnants",
    dying_explosion = "accumulator-explosion",
    collision_box = {{-0.9, -0.9}, {0.9, 0.9}},
    selection_box = {{-1, -1}, {1, 1}},
    drawing_box = {{-1, -1.5}, {1, 1}},
    energy_source = {
        type = "electric",
        buffer_capacity = "6MJ",
        usage_priority = "tertiary",
        input_flow_limit = "6MW",
        output_flow_limit = "6MW"
    },
    picture = data.raw['electric-energy-interface']['electric-energy-interface']
        .picture,
    order = "z"
}

data:extend{
    GlobalMarket, sellBoxItem, buyBoxItem, sellBox, buyBox, creditMint,
    electricTradingStation, {
        type = "custom-input",
        name = "sellbox-gui-open",
        key_sequence = "mouse-button-1"
    },
	{type = "custom-input", name = "specialization-gui", key_sequence = "J"},
    {type = "custom-input", name = "sellbox-gui-close",  key_sequence = "E"},
	{
        type = "recipe",
        name = "credit-mint",
        ingredients = {
			{type = "item", name = "electronic-circuit", amount = 50},
			{type = "item", name = "iron-gear-wheel",    amount = 50}
		},
        energy_required = 30,
        results = {{type = "item", name = "credit-mint", amount = 1}}
    }, {
        type = "recipe",
        name = "sell-box",
        ingredients = {
			{type = "item", name = "steel-chest",        amount = 1},
			{type = "item", name = "electronic-circuit", amount = 2}
		},
        energy_required = 1,
        results = {{type = "item", name = "sell-box", amount = 1}}
    }, {
        type = "recipe",
        name = "buy-box",
        ingredients = {
			{type = "item", name = "steel-chest",        amount = 1},
			{type = "item", name = "electronic-circuit", amount = 2}
		},
        energy_required = 1,
        results = {{type = "item", name = "buy-box", amount = 1}}
    }, {
        type = "recipe",
        name = "electric-trading-station",
        ingredients = {
			{type = "item", name = "substation",         amount = 1},
			{type = "item", name = "electronic-circuit", amount = 2}
		},
        energy_required = 5,
        results = {{type = "item", name = "electric-trading-station", amount = 1}}
    }, {
        type = "recipe",
        name = "global-market",
        ingredients = {
            {type = "item", name = "steel-chest",        amount = 9},
			{type = "item", name = "electronic-circuit", amount = 20},
            {type = "item", name = "advanced-circuit",   amount = 5}
        },
        energy_required = 10,
        results = {{type = "item", name = "global-market", amount = 1}}
    }, {
        type = "item",
        name = "credit-mint",
        place_result = "credit-mint",
        subgroup = "extraction-machine",
        stack_size = 1,
        icon = "__base__/graphics/icons/coin.png",
        icon_size = 64
    }, {
        type = "item",
        name = "electric-trading-station",
        place_result = "electric-trading-station",
        subgroup = "energy-pipe-distribution",
        stack_size = 100,
        icon = "__base__/graphics/icons/substation.png",
        icon_size = 64
    }, {
        type = "item",
        name = "global-market",
        place_result = "global-market",
        subgroup = "extraction-machine",
        stack_size = 1,
        icons = {
            {icon = "__base__/graphics/icons/infinity-chest.png"},
            {icon = "__base__/graphics/icons/satellite.png"}
        },
        icon_size = 64
    }
}

if settings.startup['specializations'].value then
    for _, spec in ipairs(SPECIALIZATIONS) do
        local recipe = {
            type = "recipe",
            name = spec.name,
            ingredients = spec.recipe.ingredients,
            energy_required = spec.recipe.energy_required,
            enabled = false,
            category = spec.recipe.category,
            subgroup = spec.recipe.subgroup,
            icon = spec.recipe.icon
        }
        if spec.recipe.result then
            recipe.result = spec.recipe.result
        else
            recipe.results = spec.recipe.results
        end
        if spec.recipe.icon then recipe.icon_size = 32 end
        data:extend{recipe}
    end
end
