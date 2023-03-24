local f = string.format

local Attribute = futil.class1()

function Attribute:_init(name, def)
	self.name = name
	self.description = def.description or name

	self._registered_on_changes = { def.apply }

	local monoid_def = {
		fold = function(t)
			return def.fold(self, t)
		end,
		on_change = function(old_total, new_total, player)
			for _, callback in ipairs(self._registered_on_changes) do
				callback(self, player, new_total, old_total)
			end
		end,
	}

	self._monoid = persistent_monoids.make_monoid(f("attribute:%s", name), monoid_def)
end

function Attribute:register_on_change(callback)
	table.insert(self._registered_on_changes, callback)
end

function Attribute:get(player, key)
	return self._monoid:value(player, key)
end

function Attribute:add(player, key, value)
	return self._monoid:add_change(player, value, key)
end

-- will be lost when server restarts
function Attribute:add_ephemeral(player, key, value)
	return self._monoid:add_ephemeral_change(player, value, key)
end

function Attribute:clear(player, key)
	return self._monoid:del_change(player, key)
end

player_attributes.Attribute = Attribute
