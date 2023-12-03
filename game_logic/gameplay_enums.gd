extends Node

enum ItemType {
	GUN,
	BACKPACK,
	MATERIAL,
	ARMOR,
	OPTIC,
	GRIP,
	MAG,
	STOCK,
	MUZZLE,
	FOREGRIP,
	LASER,
	AMMO
}

enum AmmoType {
	HEAVY_INTERMEDIATE_CARTRIDGE,
	FAST_INTERMEDIATE_CARTRIDGE,
	MODERN_RIFLE_CARTRIDGE,
	LIGHT_PISTOL_CARTRIDGE,
	HEAVY_PISTOL_CARTRIDGE,
	OLD_RIFLE_CARTRIDGE,
	SHOTGUN_SHELL,
	ENERGY_CELL
}

enum CartridgeType {
	FULL_METAL_JACKET,
	HOLLOW_POINT,
	ARMOR_PIERCING
}

func get_ammo_map() -> Dictionary:
	return _ammo_map.duplicate(true)

var _ammo_map = {
	HEAVY_INTERMEDIATE_CARTRIDGE = {
		HOLLOW_POINT = {"max" = 200, "current" = 0 },
		FULL_METAL_JACKET = {"max" = 200, "current" = 0 },
		ARMOR_PIERCING = {"max" = 200, "current" = 0 }
	},
	FAST_INTERMEDIATE_CARTRIDGE = {
		HOLLOW_POINT = {"max" = 200, "current" = 0 },
		FULL_METAL_JACKET = {"max" = 200, "current" = 0 },
		ARMOR_PIERCING = {"max" = 200, "current" = 0 }
	},
	MODERN_RIFLE_CARTRIDGE = {
		HOLLOW_POINT = {"max" = 200, "current" = 0 },
		FULL_METAL_JACKET = {"max" = 200, "current" = 0 },
		ARMOR_PIERCING = {"max" = 200, "current" = 0 }
	},
	LIGHT_PISTOL_CARTRIDGE = {
		HOLLOW_POINT = {"max" = 200, "current" = 0 },
		FULL_METAL_JACKET = {"max" = 200, "current" = 0 },
		ARMOR_PIERCING = {"max" = 200, "current" = 0 }
	},
	HEAVY_PISTOL_CARTRIDGE = {
		HOLLOW_POINT = {"max" = 200, "current" = 0 },
		FULL_METAL_JACKET = {"max" = 200, "current" = 0 },
		ARMOR_PIERCING = {"max" = 200, "current" = 0 }
	},
	OLD_RIFLE_CARTRIDGE = {
		HOLLOW_POINT = {"max" = 200, "current" = 0 },
		FULL_METAL_JACKET = {"max" = 200, "current" = 0 },
		ARMOR_PIERCING = {"max" = 200, "current" = 0 }
	}
}
