local s = player_attributes.settings

local breath = player_attributes.register_bounded_attribute("breath", {
	min = 0,
	base = s.default_breath_max or minetest.PLAYER_MAX_BREATH_DEFAULT,
	base_max = s.default_breath_max or minetest.PLAYER_MAX_BREATH_DEFAULT,
	get = function(self, player)
		return player:get_breath()
	end,
	set = function(self, player, value, reason)
		player:set_breath(value)
		return player:get_breath()
	end,
	apply_max = function(self, player, value, reason)
		if self:get(player) > value then
			self:set(player, value)
		end
		local properties = player:get_properties()
		properties.breath_max = value
		player:set_properties(properties)
		return value
	end,
})

minetest.register_on_joinplayer(function(player)
	local breath_max = breath:get_max(player)
	local props = player:get_properties()
	if props.breath_max ~= breath_max then
		props.breath_max = breath_max
		player:set_properties(props)
	end
end)
