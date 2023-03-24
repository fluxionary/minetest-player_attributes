# player_attributes

API for defining abstract player attributes which can be used for various things.

these are sort of like player_monoids, but with persistence and a unified means of accessing the values.

these attributes are intended to be affected by some mods (e.g. magic systems or hunger systems) and
trigger effects controlled by other mods (e.g. player effects).

```lua
local flux = minetest.get_player_by_name("flux")

-- simpled attribute whose value is managed by a persistent monoid
local strength = player_attributes.register_attribute("strength", {
    base = 10,
    fold = function(self, values)
        return player_attributes.util.sum_values(values, self.base)
    end,
})

strength = player_attributes.get_attribute("strength")  -- alternate means of getting access

strength.register_on_change(function(player, new_value, old_value)
    print("something")
end)

strength:add(flux, "xp_redo:level", 1) -- overrides any previous value of "xp_redo:level"

-- attribute whose maximum is managed by a monoid
local stamina = player_attributes.register_bounded_attribute("stamina", {
    min = 0,
    base = 120,
    base_max = 120,
    fold_max = function(self, values)
        return player_attributes.util.sum_values(values, self.base_max)
    end,
})

print(stamina:get(flux))
print(stamina:get_max(flux))
print(stamina:get_min(flux))

stamina:set(flux, stamina:get(flux) - 20, "exhaustion")

```
