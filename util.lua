player_attributes.util = {}

function player_attributes.util.sum_values(t, default)
	return futil.math.isum(futil.iterators.values(t), default or 0)
end
