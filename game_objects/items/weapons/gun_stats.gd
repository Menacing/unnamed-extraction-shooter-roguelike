extends Resource
class_name GunStats
@export var weapon_category_name:String
@export var magazine_size: int
@export var rpm: int
@export var base_recoil: Vector2 
@export var recoil_variability: Vector2
@export var fire_modes:Array
@export var ads_accel:float
@export var ads_fov:float
@export var moa:float
@export var turn_speed:float
@export var ammo_type:AmmoType
## Total time in seconds a full reload should take
@export var reload_time_Sec:float
## Thresholds at which the reload will restart at if interrupted for some reason. 
## Should be an ordered list from largest to smallest all smaller than reload_time_sec
@export var reload_thresholds:Array[float]
