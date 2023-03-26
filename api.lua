player_attributes.registered_attributes = {}

function player_attributes.get_attribute(name)
	return player_attributes.registered_attributes[name]
end

function player_attributes.register_attribute(name, def)
	if player_attributes.registered_attributes[name] then
		error("already an attribute named " .. name)
	end
	local attribute = player_attributes.Attribute(name, def)
	player_attributes.registered_attributes[name] = attribute
	return attribute
end

player_attributes.registered_bounded_attributes = {}

function player_attributes.get_bounded_attribute(name)
	return player_attributes.registered_bounded_attributes[name]
end

function player_attributes.register_bounded_attribute(name, def)
	if player_attributes.registered_bounded_attributes[name] then
		error("already a bounded attribute named " .. name)
	end
	local attribute = player_attributes.BoundedAttribute(name, def)
	player_attributes.registered_bounded_attributes[name] = attribute
	return attribute
end
