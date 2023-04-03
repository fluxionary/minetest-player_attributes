local s = player_attributes.settings

local hp = player_attributes.register_bounded_attribute("hp", {
	min = 0,
	base = s.default_hp_max or minetest.PLAYER_MAX_HP_DEFAULT,
	base_max = s.default_hp_max or minetest.PLAYER_MAX_HP_DEFAULT,
	get = function(self, player)
		return player:get_hp()
	end,
	set = function(self, player, value, reason)
		value = math.round(value)
		player:set_hp(value, reason)
		return player:get_hp()
	end,
	apply_max = function(self, player, value, reason)
		value = math.round(value)
		if self:get(player) > value then
			self:set(player, value, { reason = "set_hp", cause = reason })
		end
		local properties = player:get_properties()
		properties.hp_max = value
		player:set_properties(properties)
		return value
	end,
})

minetest.register_on_joinplayer(function(player)
	local hp_max = hp:get_max(player)
	local props = player:get_properties()
	if props.hp_max ~= hp_max then
		props.hp_max = hp_max
		player:set_properties(props)
	end
end)
