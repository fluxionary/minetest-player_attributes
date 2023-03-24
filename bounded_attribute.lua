local f = string.format

local sum_values = player_attributes.util.sum_values

local BoundedAttribute = futil.class1()

function BoundedAttribute:_init(name, def)
	self.name = name
	self.description = def.description or name
	local value_key = f("player_attributes:%s", name)

	def.cast = def.cast or tonumber

	self._registered_on_changes = {}

	self.get = def.get
		or function(self_, player)
			return futil.math.bound(
				self_:get_min(player),
				def.cast(player:get_meta():get(value_key)) or self_.base,
				self_:get_max(player)
			)
		end

	self.set = def.set
		or function(self_, player, value)
			local old_value = self_:get(player)
			value = math.max(self_:get_min(player), math.min(value), self_:get_max(player))
			for i = 1, #self_._registered_on_changes do
				value = self_._registered_on_changes[i](self_, player, value, old_value) or value
			end
			player:get_meta():set_string(value_key, tostring(value))
			return value
		end

	if def.min then
		self._min = def.min
	else
		self._registered_on_min_changes = { def.apply_min }

		def.fold_min = def.fold_min or function(self_, values)
			return sum_values(values, def.base_min)
		end

		local monoid_def = {
			fold = function(t)
				return def.fold_min(self, t)
			end,
			on_change = function(old_total, new_total, player)
				for _, callback in ipairs(self._registered_on_min_changes) do
					callback(self, player, new_total, old_total)
				end
			end,
		}

		self._min_monoid = persistent_monoids.make_monoid(f("player_attribute_min:%s", name), monoid_def)
	end

	if def.max then
		self._max = def.max
	else
		self._registered_on_max_changes = { def.apply_max }

		def.fold_max = def.fold_max or function(self_, values)
			return sum_values(values, def.base_max)
		end

		local monoid_def = {
			fold = function(t)
				return def.fold_max(self, t)
			end,
			on_change = function(old_total, new_total, player)
				for _, callback in ipairs(self._registered_on_max_changes) do
					callback(self, player, new_total, old_total)
				end
			end,
		}

		self._max_monoid = persistent_monoids.make_monoid(f("player_attribute_max:%s", name), monoid_def)
	end
end

function BoundedAttribute:register_on_min_change(callback)
	if self._registered_on_min_changes then
		table.insert(self._registered_on_min_changes, callback)
	end
end

function BoundedAttribute:get_min(player, key)
	if self._min then
		if key then
			return
		else
			return self._min
		end
	end
	return self._min_monoid:value(player, key)
end

function BoundedAttribute:add_min(player, key, value)
	if self._min then
		return self._min
	end
	return self._min_monoid:add_change(player, value, key)
end

-- will be lost when server restarts
function BoundedAttribute:add_min_ephemeral(player, key, value)
	if self._min then
		return self._min
	end
	return self._min_monoid:add_ephemeral_change(player, value, key)
end

function BoundedAttribute:clear_min(player, key)
	if self._min then
		return self._min
	end
	return self._min_monoid:del_change(player, key)
end

function BoundedAttribute:register_on_max_change(callback)
	if self._registered_on_max_changes then
		table.insert(self._registered_on_max_changes, callback)
	end
end

function BoundedAttribute:get_max(player, key)
	if self._max then
		if key then
			return
		else
			return self._max
		end
	end
	return self._max_monoid:value(player, key)
end

function BoundedAttribute:add_max(player, key, value)
	if self._max then
		return self._max
	end
	return self._max_monoid:add_change(player, value, key)
end

-- will be lost when server restarts
function BoundedAttribute:add_max_ephemeral(player, key, value)
	if self._max then
		return self._max
	end
	return self._max_monoid:add_ephemeral_change(player, value, key)
end

function BoundedAttribute:clear_max(player, key)
	if self._max then
		return self._max
	end
	return self._max_monoid:del_change(player, key)
end

player_attributes.BoundedAttribute = BoundedAttribute
