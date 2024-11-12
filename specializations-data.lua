return {
    {
        name = "iron-gear-wheel-specialization",
        requirement = {
            name = "iron-gear-wheel",
            production = 500
        },
        recipe = {
            ingredients = {{type = "item", name = "iron-plate", amount = 1}},
            energy_required = 0.5,
            disables = {"iron-gear-wheel"},
            results = {{type = "item", name = "iron-gear-wheel", amount = 1}}
        }
    },
    {
        name = "electronic-circuit-specialization",
        requirement = {
            name = "electronic-circuit",
            production = 350
        },
        recipe = {
            ingredients = {
				{type = "item", name = "copper-cable", amount = 1},
				{type = "item", name = "iron-plate",   amount = 1}
			},
            energy_required = 0.4,
            results = {{type = "item", name = "electronic-circuit", amount = 1}}
        }
    },
    {
        name = "advanced-circuit-specialization",
        requirement = {
            name = "advanced-circuit",
            production = 200
        },
        recipe = {
            ingredients = {
				{type = "item", name = "copper-cable",       amount = 2},
				{type = "item", name = "electronic-circuit", amount = 1},
				{type = "item", name = "plastic-bar",        amount = 1}
			},
            energy_required = 5,
            results = {{type = "item", name = "advanced-circuit", amount = 1}}
        }
    },
    {
        name = "processing-unit-specialization",
        requirement = {
            name = "processing-unit",
            production = 65
        },
        recipe = {
            category = "crafting-with-fluid",
            ingredients = {
				{type = "item", name = "advanced-circuit",   amount = 1},
				{type = "item", name = "electronic-circuit", amount = 15},
				{type = "fluid", name = "sulfuric-acid",     amount = 3}
			},
            energy_required = 9,
            results = {{type = "item", name = "processing-unit", amount = 1}}
        }
    },
    {
        name = "piercing-rounds-magazine-specialization",
        requirement = {
            name = "piercing-rounds-magazine",
            production = 80
        },
        recipe = {
            ingredients = {
				{type = "item", name = "copper-plate",     amount = 3},
				{type = "item", name = "firearm-magazine", amount = 1},
				{type = "item", name = "steel-plate",      amount = 1}
			},
            energy_required = 2,
            results = {{type = "item", name = "piercing-rounds-magazine", amount = 1}}
        }
    },
    {
        name = "uranium-rounds-magazine-specialization",
        requirement = {
            name = "uranium-rounds-magazine",
            production = 40
        },
        recipe = {
            ingredients = {
				{type = "item", name = "piercing-rounds-magazine", amount = 1},
				{type = "item", name = "uranium-238", amount = 1}
			},
            energy_required = 7,
            results = {{type = "item", name = "uranium-rounds-magazine", amount = 1}}
        }
    },
    {
        name = "explosives-specialization",
        requirement = {
            name = "explosives",
            production = 250
        },
        recipe = {
            category = "crafting-with-fluid",
            ingredients = {
				{type = "item", name = "coal",   amount = 1},
				{type = "item", name = "sulfur", amount = 1},
				{type="fluid", name="water",     amount = 5}
			},
            energy_required = 4,
            results = {{type = "item", name = "explosives", amount = 3}},
        }
    },
    {
        name = "speed-module-specialization",
        requirement = {
            name = "speed-module",
            production = 20
        },
        recipe = {
            ingredients = {
				{type = "item", name = "electronic-circuit", amount = 3},
				{type = "item", name = "advanced-circuit", amount = 3}
			},
            energy_required = 13,
            results = {{type = "item", name = "speed-module", amount = 1}},
        }
    },
    {
        name = "efficiency-module-specialization",
        requirement = {
            name = "efficiency-module",
            production = 20
        },
        recipe = {
            ingredients = {
				{type = "item", name = "electronic-circuit", amount = 3},
				{type = "item", name = "advanced-circuit", amount = 3}
			},
            energy_required = 13,
            results = {{type = "item", name = "efficiency-module", amount = 1}},
        }
    },
    {
        name = "productivity-module-specialization",
        requirement = {
            name = "productivity-module",
            production = 20
        },
        recipe = {
            ingredients = {
				{type = "item", name = "electronic-circuit", amount = 3},
				{type = "item", name = "advanced-circuit",   amount = 3}
			},
            energy_required = 13,
            results = {{type = "item", name = "productivity-module", amount = 1}},
        }
    },
    {
        name = "oil-specialization",
        disable_override = "advanced-oil-processing",
        requirement = {
            fluid = true,
            name = "petroleum-gas",
            production = 4000
        },
        recipe = {
            ingredients =
            {
                {type="fluid", name="water", amount=50},
                {type="fluid", name="crude-oil", amount=100}
            },
            energy_required = 4,
            icon = "__base__/graphics/icons/fluid/advanced-oil-processing.png",
            subgroup = "fluid-recipes",
            category = "oil-processing",
            results =
            {
                {type="fluid", name="heavy-oil", amount=20},
                {type="fluid", name="light-oil", amount=55},
                {type="fluid", name="petroleum-gas", amount=70}
            },
        }
    },
    {
        name = "plastic-bar-specialization",
        requirement = {
            name = "plastic-bar",
            production = 450
        },
        recipe = {
            category = "crafting-with-fluid",
            ingredients = {
				{type = "item",  name = "coal",          amount = 1},
				{type = "fluid", name = "petroleum-gas", amount = 15}
			},
            energy_required = 0.75,
            results = {{type = "item", name = "plastic-bar", amount = 2}},
        }
    },
    {
        name = "solar-panel-specialization",
        requirement = {
            name = "solar-panel",
            production = 150
        },
        recipe = {
            ingredients = {
				{type = "item",  name = "copper-plate",       amount = 4},
				{type = "item",  name = "steel-plate",        amount = 4},
				{type = "item",  name = "electronic-circuit", amount = 10}
			},
            energy_required = 8,
            results = {{type = "item", name = "solar-panel", amount = 1}}
        }
    },
}
