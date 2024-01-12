extends Resource
class_name GameMaterialInfoList

##We're going to naively index into this based on the FGD index, so make sure the order matches whats in res://levels/entities/geo_ballistic_solid.tres
@export var game_material_infos:Array[GameMaterialInfo]
