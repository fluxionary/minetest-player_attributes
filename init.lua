futil.check_version({ year = 2023, month = 11, day = 1 }) -- is_player

player_attributes = fmod.create()

player_attributes.dofile("util")
player_attributes.dofile("attribute")
player_attributes.dofile("bounded_attribute")
player_attributes.dofile("api")
player_attributes.dofile("builtin_attributes", "init")
