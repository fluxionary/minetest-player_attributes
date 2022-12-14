local f = string.format

local parse_json = minetest.parse_json
local write_json = minetest.write_json

local DefaultTable = futil.DefaultTable
local equals = futil.equals
local sum = futil.math.sum

local mod_storage = player_attributes.mod_storage

-- cache values
local attributes_by_player_name = DefaultTable(function()
	return {}
end)
local tmp_attribute_values_by_player_name = DefaultTable(function()
	return DefaultTable(function()
		return {}
	end)
end)

local api = {}

api.registered_attributes = {}
api.registered_on_attribute_changes = {}

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
	local def = api.registered_attributes[attribute_name]
	local values_by_key = get_attribute_values(player_name, attribute_name)

	local values = { def.initial }
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

function api.register_attribute(name, def)
	def = table.copy(def or {})
	def.compose = def.compose or sum
	def.default = def.default or 0
	def.equals = def.equals or equals
	api.registered_attributes[name] = def
end

minetest.register_on_joinplayer(function(player, last_login)
	local player_name = player:get_player_name()
	local attributes = attributes_by_player_name[player_name]
	for attribute_name in pairs(api.registered_attributes) do
		attributes[attribute_name] = compose_attribute(player_name, attribute_name)
	end
end)

function api.get_attribute(player, attribute_name)
	if minetest.is_player(player) then
		player = player:get_player_name()
	end
	return attributes_by_player_name[player][attribute_name] or api.registered_attributes[attribute_name].default
end

function api.register_on_attribute_change(callback)
	table.insert(api.registered_on_attribute_changes, callback)
end

function api.do_on_attribute_change(player, attribute_name, prev_value, current_value)
	if minetest.is_player(player) then
		player = player:get_player_name()
	end

	for _, callback in ipairs(api.registered_on_attribute_changes) do
		callback(player, attribute_name, prev_value, current_value)
	end
end

function api.set_value(player, attribute_name, key, value)
	if minetest.is_player(player) then
		player = player:get_player_name()
	end
	local prev_value = api.get_attribute(player, attribute_name)
	local attribute_values = get_attribute_values(player, attribute_name)
	attribute_values[key] = value
	set_attribute_values(player, attribute_name, attribute_values)
	local current_value = api.get_attribute(player, attribute_name)
	if not api.registered_attributes[attribute_name].equals(prev_value, current_value) then
		api.do_on_attribute_change(player, attribute_name, prev_value, current_value)
	end
end

function api.set_temp_value(player, attribute_name, key, value)
	if minetest.is_player(player) then
		player = player:get_player_name()
	end
	local prev_value = api.get_attribute(player, attribute_name)
	tmp_attribute_values_by_player_name[player][attribute_name][key] = value
	attributes_by_player_name[player] = compose_attribute(player, attribute_name)
	local current_value = api.get_attribute(player, attribute_name)
	if not api.registered_attributes[attribute_name].equals(prev_value, current_value) then
		api.do_on_attribute_change(player, attribute_name, prev_value, current_value)
	end
end

player_attributes.api = api
