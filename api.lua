player_attributes.registered_attributes = {}

function player_attributes.get_attribute(name)
	return player_attributes.registered_attributes[name]
end

function player_attributes.register_attribute(name, def)
	player_attributes.registered_attributes[name] = player_attributes.Attribute(name, def)
end

player_attributes.registered_bounded_attributes = {}

function player_attributes.get_bounded_attribute(name)
	return player_attributes.registered_bounded_attributes[name]
end

function player_attributes.register_bounded_attribute(name, def)
	player_attributes.registered_attributes[name] = player_attributes.BoundedAttribute(name, def)
end
