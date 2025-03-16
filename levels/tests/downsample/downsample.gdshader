shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform int pixel_size : hint_range(1, 64) = 4; // Pixel size


void fragment() {
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;

    //Pixel coordinates in screen space
    vec2 pixel_coords = floor(FRAGCOORD.xy / float(pixel_size)) * float(pixel_size);
    // Convert pixel coordinates to UVs for screen texture
    vec2 uv = pixel_coords / screen_size;
    // Get color from texture screen

	vec4 col = vec4(0.0);
    col += 0.37487566 * texture(SCREEN_TEXTURE, uv + vec2(-0.75777156, -0.75777156) / screen_size.xy);
    col += 0.37487566 * texture(SCREEN_TEXTURE, uv + vec2(0.75777156, -0.75777156) / screen_size.xy);
    col += 0.37487566 * texture(SCREEN_TEXTURE, uv + vec2(0.75777156, 0.75777156) / screen_size.xy);
    col += 0.37487566 * texture(SCREEN_TEXTURE, uv + vec2(-0.75777156, 0.75777156) / screen_size.xy);

    col += -0.12487566 * texture(SCREEN_TEXTURE, uv + vec2(-2.90709914, 0.0) / screen_size.xy);
    col += -0.12487566 * texture(SCREEN_TEXTURE, uv + vec2(2.90709914, 0.0) / screen_size.xy);
    col += -0.12487566 * texture(SCREEN_TEXTURE, uv + vec2(0.0, -2.90709914) / screen_size.xy);
    col += -0.12487566 * texture(SCREEN_TEXTURE, uv + vec2(0.0, 2.90709914) / screen_size.xy);
    COLOR = col;
	//Base color
    //COLOR = texture(SCREEN_TEXTURE, uv);
}
