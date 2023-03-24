```lua

-- register a basic attribute
player_attributes.register_attribute("strength")

-- register a attribute w/ an initial value
player_attributes.register_attribute("intelligence", {
    initial = 10,
})

-- add some strength due to player level
if xp_redo.get_xp > 1000 then
    player_attributes.set_value(player, "strength", "xp_redo:level", 5)
end

-- add some strength due to temporary effect
player_attributes.set_tmp_value(player, "strength", "potions:strength", 1)

-- get attribute
player_attributes.get_attribute(player, "strength") -- 6

-- remove strength due to temporary effect
player_attributes.set_tmp_value(player, "strength", "potions:strength", nil)

-- register a discrete attribute
player_attributes.register_attribute("flags", {
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
player_attributes.set_value(player, "flags", "something1", {happy = true, free = true})
player_attributes.set_value(player, "flags", "something2", {happy = true, slappy = true})

-- get flags
print(dump(player_attributes.get_attribute(player, "flags"))) --[[{
    happy = true,
    free = true,
    slappy = true,
}]]

player_attributes.set_value(player, "flags", "something1", nil)

-- get flags
print(dump(player_attributes.get_attribute(player, "flags"))) --[[{
    happy = true,
    slappy = true,
}]]
```
