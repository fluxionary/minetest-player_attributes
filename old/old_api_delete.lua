local private_state = ...
local mod_storage = private_state.mod_storage

local f = string.format

local parse_json = minetest.parse_json
local write_json = minetest.write_json

local DefaultTable = futil.DefaultTable
local equals = futil.equals
local sum = futil.math.sum

-- cache values
local attributes_by_player_name = DefaultTable(function()
	return {}
end)

local tmp_attribute_values_by_player_name = DefaultTable(function()
	return DefaultTable(function()
		return {}
	end)
end)

player_attributes.registered_attributes = {}
player_attributes.registered_on_attribute_changes = DefaultTable(function()
	return {}
end)

local function attribute_key(player_name, attribute_name)
	return f("%s:%s", player_name, attribute_name)
end

local function get_attribute_values(player_name, attribute_name)
	local key = attribute_key(player_name, attribute_name)
	local serialized = mod_storage:get(key)
	if serialized then
		return parse_json(serialized)
	end
end

local function compose_attribute(player_name, attribute_name)
	local def = player_attributes.registered_attributes[attribute_name]

	local values = { def.initial }
	local values_by_key = get_attribute_values(player_name, attribute_name)

	if values_by_key then
		for _, value in pairs(values_by_key) do
			values[#values + 1] = value
		end
	end

	local tmp_values = tmp_attribute_values_by_player_name[player_name][attribute_name]
	for _, value in pairs(tmp_values) do
		values[#values + 1] = value
	end

	if #values > 0 then
		return def.compose(values)
	else
		return def.default
	end
end

local function set_attribute_values(player_name, attribute_name, values)
	local key = attribute_key(player_name, attribute_name)
	mod_storage:set_string(key, write_json(values))
	attributes_by_player_name[player_name][attribute_name] = compose_attribute(player_name, attribute_name)
end

minetest.register_on_joinplayer(function(player, last_login)
	local player_name = player:get_player_name()
	local attributes = attributes_by_player_name[player_name]
	for attribute_name in pairs(player_attributes.registered_attributes) do
		attributes[attribute_name] = compose_attribute(player_name, attribute_name)
	end
end)

function player_attributes.register_attribute(name, def)
	def = table.copy(def or {})
	def.compose = def.compose or sum
	def.default = def.default or 0
	def.equals = def.equals or equals
	player_attributes.registered_attributes[name] = def
end

local function get_name(player_or_name)
	if type(player_or_name) == "string" then
		return player_or_name
	elseif futil.is_player(player_or_name) then
		return player_or_name:get_player_name()
	end
end

function player_attributes.get_attribute(player_or_name, attribute_name)
	local name = get_name(player_or_name)
	if not name then
		return
	end
	return attributes_by_player_name[name][attribute_name]
		or player_attributes.registered_attributes[attribute_name].default
end

function player_attributes.register_on_attribute_change(attribute_name, callback)
	table.insert(player_attributes.registered_on_attribute_changes[attribute_name], callback)
end

function player_attributes.do_on_attribute_change(player_or_name, attribute_name, prev_value, current_value)
	local name = get_name(player_or_name)
	if not name then
		return
	end

	for _, callback in ipairs(player_attributes.registered_on_attribute_changes[name]) do
		callback(name, prev_value, current_value)
	end
end

function player_attributes.set_value(player_or_name, attribute_name, key, value)
	local name = get_name(player_or_name)
	if not name then
		return
	end
	local prev_value = player_attributes.get_attribute(name, attribute_name)
	local attribute_values = get_attribute_values(name, attribute_name)
	attribute_values[key] = value
	set_attribute_values(name, attribute_name, attribute_values)
	local current_value = player_attributes.get_attribute(name, attribute_name)
	local attribute_def = player_attributes.registered_attributes[attribute_name]
	if not attribute_def.equals(prev_value, current_value) then
		player_attributes.do_on_attribute_change(name, attribute_name, prev_value, current_value)
	end
end

function player_attributes.set_tmp_value(player_or_name, attribute_name, key, value)
	local name = get_name(player_or_name)
	if not name then
		return
	end
	local prev_value = player_attributes.get_attribute(name, attribute_name)
	tmp_attribute_values_by_player_name[name][attribute_name][key] = value
	attributes_by_player_name[name] = compose_attribute(name, attribute_name)
	local current_value = player_attributes.get_attribute(name, attribute_name)
	local attribute_def = player_attributes.registered_attributes[attribute_name]
	if not attribute_def.equals(prev_value, current_value) then
		player_attributes.do_on_attribute_change(name, attribute_name, prev_value, current_value)
	end
end
