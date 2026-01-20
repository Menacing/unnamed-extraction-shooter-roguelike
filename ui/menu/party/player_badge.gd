extends Control

@onready var player_avatar_texture_rect: TextureRect = %PlayerAvatarTextureRect
@onready var player_username_label: Label = %PlayerUsernameLabel

var steam_id:int = 0:
	get:
		return steam_id
	set(value):
		steam_id = value
		_update_displayed_player()

func _ready() -> void:
	Steam.avatar_loaded.connect(_on_loaded_avatar)
	
	if steam_id != 0:
		_update_displayed_player()
		

func _update_displayed_player():
	Steam.getPlayerAvatar(2,steam_id)
	player_username_label.text = Steam.getFriendPersonaName(steam_id)

func _on_loaded_avatar(user_id: int, avatar_size: int, avatar_buffer: PackedByteArray) -> void:
	print("Avatar for user: %s" % user_id)
	print("Size: %s" % avatar_size)

	# Create the image and texture for loading
	var avatar_image: Image = Image.create_from_data(avatar_size, avatar_size, false, Image.FORMAT_RGBA8, avatar_buffer)

	# Optionally resize the image if it is too large
	if avatar_size > 128:
		avatar_image.resize(128, 128, Image.INTERPOLATE_LANCZOS)

	# Apply the image to a texture
	var avatar_texture: ImageTexture = ImageTexture.create_from_image(avatar_image)

	# Set the texture to a Sprite, TextureRect, etc.
	player_avatar_texture_rect.set_texture(avatar_texture)


func _on_button_pressed() -> void:
	
	pass # Replace with function body.
