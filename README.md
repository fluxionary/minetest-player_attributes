# player_stats

API for defining player stats which affect player physics and other things

```lua
-- register a basic stat
player_stats.api.register_stat("strength")

-- add some strength due to player level
player_stats.api.set_stat_value(player, "strength", "level", 5)

-- add some strength due to temporary effect
player_stats.api.set_stat_value(player, "strength", "potion", 1)

-- get stat
player_stats.api.get_stat(player, "strength") -- 6

-- remove strength due to temporary effect
player_stats.api.set_stat_value(player, "strength", "potion", nil)

-- register a stat w/ an initial value
player_stats.api.register_stat("intelligence", {
    initial = 10,
})

-- register a discrete stat
player_stats.api.register_stat("flags", {
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
player_stats.api.set_stat_value(player, "flags", "something1", {happy = true, free = true})
player_stats.api.set_stat_value(player, "flags", "something2", {happy = true, slappy = true})

-- get flags
print(dump(player_stats.api.get_stat(player, "flags"))) --[[
{
    happy = true,
    free = true,
    slappy = true,
}
]]

player_stats.api.set_stat_value(player, "flags", "something1", nil)

-- get flags
print(dump(player_stats.api.get_stat(player, "flags"))) --[[
{
    happy = true,
    slappy = true,
}
]]
```

temporary stats: managing these is still the responsibility of the registering mod, but they will not survive a
                 server restart, so that mods don't have to do a bunch of cleanup on initialization.
