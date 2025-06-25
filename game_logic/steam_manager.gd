extends Node

func _ready() -> void:
	initialize_steam()


func initialize_steam() -> void:
	var initialize_response: Dictionary = Steam.steamInitEx()
	print("Did Steam initialize?: %s " % initialize_response)
	
	#var app_installed_depots: Array = Steam.getInstalledDepots( 480 )
	#var app_languages: String = Steam.getAvailableGameLanguages()
	#var app_owner: int = Steam.getAppOwner()
	#var build_id: int = Steam.getAppBuildId()
	#var game_language: String = Steam.getCurrentGameLanguage()
	#var install_dir: Dictionary = Steam.getAppInstallDir( 480 )
	#var is_on_steam_deck: bool = Steam.isSteamRunningOnSteamDeck()
	#var is_on_vr: bool = Steam.isSteamRunningInVR()
	#var is_online: bool = Steam.loggedOn()
	#var is_owned: bool = Steam.isSubscribed()
	#var launch_command_line: String = Steam.getLaunchCommandLine()
	#var steam_id: int = Steam.getSteamID()
	#var steam_username: String = Steam.getPersonaName()
	#var ui_language: String = Steam.getSteamUILanguage()
	
	pass
