Config                            = {}

Config.DrawDistance               = 100.0

Config.MaxInService               = -1
Config.EnablePlayerManagement     = true
Config.EnableSocietyOwnedVehicles = false

Config.Locale = 'fr'

Config.AuthorizedVehicles = {

	{
		model = 'jackal',
		label = 'Ocelot Jackal'
	}

}

Config.Zones = {

	VehicleSpawner = {
		Pos   = {x = 275.74, y = -344.84, z = 45.17},
		Size  = {x = 1.0, y = 1.0, z = 1.0},
		Color = {r = 255, g = 204, b = 255},
		Type  = 36, Rotate = true,
		Duty  = 0
	},

	VehicleSpawnPoint = {
		Pos     = {x = 285.40, y = -347.72, z = 44.95},
		Size    = {x = 1.5, y = 1.5, z = 1.0},
		Type    = -1, Rotate = false,
		Heading = 160.066711,
		Duty  = 0
	},

	VehicleDeleter = {
		Pos   = {x = 272.32, y = -339.14, z = 43.91},
		Size  = {x = 3.0, y = 3.0, z = 0.25},
		Color = {r = 255, g = 0, b = 0},
		Type  = 1, Rotate = false,
		Duty  = 0
	},

	AvocatActions = {
		Pos   = {x = 223.95, y = -438.80, z = 47.95},
		Size  = {x = 1.0, y = 1.0, z = 1.0},
		Color = {r = 255, g = 204, b = 255},
		Type  = 20, Rotate = true,
		Duty  = 0
	},

	Cloakroom = {
		Pos     = {x = 243.95, y = -413.87, z = 47.95},
		Size    = {x = 1.0, y = 1.0, z = 1.0},
		Color   = {r = 255, g = 204, b = 255},
		Type    = 21, Rotate = true,
		Duty  = 1
	}

}

