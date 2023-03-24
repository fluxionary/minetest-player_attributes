local sum_values = player_attributes.util.sum_values

player_attributes.register_bounded_attribute("breath", {
	min = 0,
	base = minetest.PLAYER_MAX_BREATH_DEFAULT,
	base_max = minetest.PLAYER_MAX_BREATH_DEFAULT,
	get = function(self, player)
		return player:get_breath()
	end,
	set = function(self, player, value, reason)
		player:set_breath(value)
		return player:get_breath()
	end,
	apply_max = function(self, player, value, reason)
		local properties = player:get_properties()
		properties.breath_max = value
		player:set_properties(properties)
		return value
	end,
	fold_max = function(self, values)
		return sum_values(values, self.base_max)
	end,
})
