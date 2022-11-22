# player_attributes

API for defining abstract, compositional player attributes which can be used for various things.

these are sort of like player_monoids, but with optional persistence, a unified means of accessing the values,
and without anything binding them to "real" quantities like player physics.

these attributes are intended to be affected by some mods (e.g. magic systems or hunger systems) and
trigger effects controlled by other mods (e.g. attributeus effects).

```lua
-- register a basic attribute
player_attributes.api.register_attribute("strength")

-- add some strength due to player level
player_attributes.api.set_value(player, "strength", "level", 5)

-- add some strength due to temporary effect
player_attributes.api.set_temp_value(player, "strength", "potion", 1)

-- get attribute
player_attributes.api.get_attribute(player, "strength") -- 6

-- remove strength due to temporary effect
player_attributes.api.set_temp_value(player, "strength", "potion", nil)

-- register a attribute w/ an initial value
player_attributes.api.register_attribute("intelligence", {
    initial = 10,
})

-- register a discrete attribute
player_attributes.api.register_attribute("flags", {
    default = {},
    compose = function(values)
        local all_flags = {}
        for _, flags in ipairs(values) do
            for flag in pairs(flags) do
                all_flags[flag] = true
            end
        end
        return all_flags
    end
})

-- set some flags
player_attributes.api.set_value(player, "flags", "something1", {happy = true, free = true})
player_attributes.api.set_value(player, "flags", "something2", {happy = true, slappy = true})

-- get flags
print(dump(player_attributes.api.get_attribute(player, "flags"))) --[[
{
    happy = true,
    free = true,
    slappy = true,
}
]]

player_attributes.api.set_value(player, "flags", "something1", nil)

-- get flags
print(dump(player_attributes.api.get_attribute(player, "flags"))) --[[
{
    happy = true,
    slappy = true,
}
]]
```

temporary attributes: managing these is still the responsibility of the registering mod, but they will not survive a
                 server restart, so that mods don't have to do a bunch of cleanup on initialization.
