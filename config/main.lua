canine = {}
canine = setmetatable(canine, {})

canine.OpenMenuIdentifierRestriction = false
canine.LicenseIdentifiers = {
	""
}
canine.SteamIdentifiers = {
	""
}

-- Restricts the dog to getting into certain vehicles
canine.VehicleRestriction = false
canine.VehiclesList = {
}

canine.SearchType = "Random"
canine.OpenDoorsOnSearch = true

-- Language --
canine.LanguageChoice = "English"
canine.Languages = {
	["English"] = {
		follow = "Come",
		stop = "Heel",
		attack = "Bite",
		enter = "In",
		exit = "Out"
	}
}
