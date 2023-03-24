local sum_values = player_attributes.util.sum_values

player_attributes.register_bounded_attribute("hp", {
	min = 0,
	base = minetest.PLAYER_MAX_HP_DEFAULT,
	base_max = minetest.PLAYER_MAX_HP_DEFAULT,
	get = function(self, player)
		return player:get_hp()
	end,
	set = function(self, player, value, reason)
		player:set_hp(value, reason)
		return player:get_hp()
	end,
	apply_max = function(self, player, value, reason)
		local properties = player:get_properties()
		properties.hp_max = value
		player:set_properties(properties)
		return value
	end,
	fold_max = function(self, values)
		return sum_values(values, self.base_max)
	end,
})
