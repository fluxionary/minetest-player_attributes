# player_attributes

an API for defining abstract player attributes.

these are sort of like player_monoids, but with persistence and a unified means of accessing the values.

these attributes are intended to be affected by some mods (e.g. magic systems or hunger systems) and
trigger effects controlled by other mods (e.g. player effects).

### attributes

these represent intrinsic values of a player, which may be affected by multiple things from multiple mods.

```lua
-- simpled attribute whose value is managed by a persistent monoid
local strength = player_attributes.register_attribute("strength", {
    base = 10, -- strength starts @ 10
    fold = function(self, values)
        return player_attributes.util.sum_values(values, self.base)
    end,
})

strength = player_attributes.get_attribute("strength")  -- alternate means of getting access

strength.register_on_change(function(player, new_value, old_value)
    print("this could be a callback that updates something when the value changes")
end)

local player = minetest.get_player_by_name("flux")

if xp_redo.get_level(player) > 10 then
    strength:add(player, "xp_redo:level", 1) -- overrides any previous value of "xp_redo:level"
end
```

### bounded attributes

these represent values which are ephemeral (they change a lot), but where the *maximum* the value is an intrinsic
controlled as the above attribute system (technically the minimum too, but it's probably most likely always going to
be set to the constant 0).

```lua
-- attribute whose maximum is managed by a monoid
local stamina = player_attributes.register_bounded_attribute("stamina", {
    min = 0, -- set minimum to a constant 0
    base = 40, -- initial value of the attribute
    base_max = 40, -- base value of the maximum
    fold_max = function(self, values)
        return player_attributes.util.sum_values(values, self.base_max)
    end,
})

stamina:register_on_change(function(self, player, value, old_value)
    -- callback for things that are interested in when stamina changes
end)

stamina:register_on_max_change(function(self, player, new_max, old_max)
end)

local player = minetest.get_player_by_name("flux")

print(stamina:get(player))  -- starts at 120
print(stamina:get_max(player))  -- 120, unless it is changed
print(stamina:get_min(player))  -- 0

if xp_redo.get_level(player) > 50 then
    stamina:add_max(player, "xp_redo:level", 20)  -- add stamina because of high level
end

stamina:add_max_ephemeral(player, "ate healthy food", 20)  -- player ate good food, gets a temporary boost.
stamina:clear_max(player, "ate healthy food")  -- remove the buff after a while

stamina:set(player, stamina:get(player) - 20, "exhaustion") -- change the actual attribute value

```

### builtin attributes

two bounded attributes are defined for builtin player values - hp and breath. there are already ways to access and
change these values and their maximum, but player_attributes provides an API for accessing and modifying them,
with callbacks, and monoids for the maximum values.

```lua
local hp = player_attributes.get_bounded_attribute("hp")
local breath = player_attributes.get_bounded_attribute("breath")

local player = minetest.get_player_by_name("flux")

hp:add_max(player, "mymod:reason", 1)
```
