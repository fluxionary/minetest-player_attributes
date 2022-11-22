local f = string.format

local parse_json = minetest.parse_json
local write_json = minetest.write_json

local DefaultTable = futil.DefaultTable
local equals = futil.equals
local sum = futil.math.sum

local mod_storage = player_stats.mod_storage

-- cache values
local stats_by_player_name = DefaultTable(function()
	return {}
end)
local tmp_stat_values_by_player_name = DefaultTable(function()
	return DefaultTable(function()
		return {}
	end)
end)

local api = {}

api.registered_stats = {}
api.registered_on_stat_changes = {}

local function stat_key(player_name, stat_name)
	return f("%s:%s", player_name, stat_name)
end

local function get_stat_values(player_name, stat_name)
	local key = stat_key(player_name, stat_name)
	local serialized = mod_storage:get(key)
	if serialized then
		return parse_json(serialized)
	end
end

local function compose_stat(player_name, stat_name)
	local def = api.registered_stats[stat_name]
	local values_by_key = get_stat_values(player_name, stat_name)

	local values = { def.initial }
	if values_by_key then
		for _, value in pairs(values_by_key) do
			values[#values + 1] = value
		end
	end

	local tmp_values = tmp_stat_values_by_player_name[player_name][stat_name]
	for _, value in pairs(tmp_values) do
		values[#values + 1] = value
	end

	if #values > 0 then
		return def.compose(values)
	else
		return def.default
	end
end

local function set_stat_values(player_name, stat_name, values)
	local key = stat_key(player_name, stat_name)
	mod_storage:set_string(key, write_json(values))
	stats_by_player_name[player_name][stat_name] = compose_stat(player_name, stat_name)
end

function api.register_stat(name, def)
	def = table.copy(def or {})
	def.compose = def.compose or sum
	def.default = def.default or 0
	def.equals = def.equals or equals
	api.registered_stats[name] = def
end

minetest.register_on_joinplayer(function(player, last_login)
	local player_name = player:get_player_name()
	local stats = stats_by_player_name[player_name]
	for stat_name in pairs(api.registered_stats) do
		stats[stat_name] = compose_stat(player_name, stat_name)
	end
end)

function api.get_stat(player, stat_name)
	if minetest.is_player(player) then
		player = player:get_player_name()
	end
	return stats_by_player_name[player][stat_name] or api.registered_stats[stat_name].default
end

function api.register_on_stat_change(callback)
	table.insert(api.registered_on_stat_changes, callback)
end

function api.do_on_stat_change(player, stat_name, prev_value, current_value)
	if minetest.is_player(player) then
		player = player:get_player_name()
	end

	for _, callback in ipairs(api.registered_on_stat_changes) do
		callback(player, stat_name, prev_value, current_value)
	end
end

function api.set_stat_value(player, stat_name, key, value)
	if minetest.is_player(player) then
		player = player:get_player_name()
	end
	local prev_value = api.get_stat(player, stat_name)
	local stat_values = get_stat_values(player, stat_name)
	stat_values[key] = value
	set_stat_values(player, stat_name, stat_values)
	local current_value = api.get_stat(player, stat_name)
	if not api.registered_stats[stat_name].equals(prev_value, current_value) then
		api.do_on_stat_change(player, stat_name, prev_value, current_value)
	end
end

function api.set_temporary_stat_value(player, stat_name, key, value)
	if minetest.is_player(player) then
		player = player:get_player_name()
	end
	local prev_value = api.get_stat(player, stat_name)
	tmp_stat_values_by_player_name[player][stat_name][key] = value
	stats_by_player_name[player] = compose_stat(player, stat_name)
	local current_value = api.get_stat(player, stat_name)
	if not api.registered_stats[stat_name].equals(prev_value, current_value) then
		api.do_on_stat_change(player, stat_name, prev_value, current_value)
	end
end

player_stats.api = api
