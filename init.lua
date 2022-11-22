assert(
	type(futil.version) == "number" and futil.version >= os.time({ year = 2022, month = 11, day = 22 }),
	"please update futil https://content.minetest.net/packages/rheo/futil/"
)

local f = string.format

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

player_attributes = {
	author = "flux",
	license = "AGPL_v3",
	version = os.time({ year = 2022, month = 11, day = 22 }),
	fork = "flux",

	modname = modname,
	modpath = modpath,
	S = S,
	mod_storage = minetest.get_mod_storage(),

	has = {},

	log = function(level, messagefmt, ...)
		return minetest.log(level, f("[%s] %s", modname, f(messagefmt, ...)))
	end,

	dofile = function(...)
		return dofile(table.concat({ modpath, ... }, DIR_DELIM) .. ".lua")
	end,
}

player_attributes.dofile("api")

player_attributes.mod_storage = nil
