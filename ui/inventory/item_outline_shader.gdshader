shader_type spatial;
render_mode cull_front, depth_prepass_alpha, depth_draw_opaque, unshaded;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float distance_falloff : hint_range(0, 5) = 1;
uniform float smoothing_cutoff : hint_range(0, 1) = 0.1;
uniform float smoothing_max : hint_range(0, 1) = 0.1;

void vertex() {
	// remember to rotate the quad 180d around Y
	
	// uncomment to use full screen
	//POSITION = vec4(VERTEX, 1.0) * vec4(-1.0, -1.0, 1.0, 1.0);
}

float abs_diff(float depth_a, float depth_b){
	return abs(abs(depth_a)-abs(depth_b));
}

float linear_depth(in sampler2D depth_texture, in vec2 screen_uv, in mat4 inv_projection_matrix){
	// get raw depth, this is not a linear value in godot 4.0 vulkan rendering
	float raw_depth = texture(depth_texture, screen_uv)[0];
    
	vec3 normalized_device_coordinates = vec3(screen_uv * 2.0 - 1.0, raw_depth);
	
	//convert NDC to view space via the inverse projection matrix
    vec4 view_space = inv_projection_matrix * vec4(normalized_device_coordinates, 1.0);	
    
	//linearize the depth
	view_space.xyz /= view_space.w;	
	
	// camera view points in the negative Z direction, so all depths are negative
	// we invert the sign here to get positive depth values
	return -view_space.z;
}

void fragment() {
	// set color to outline color for whole screen
	// non-outline fragments will be set to transparent
	ALBEDO = outline_color.rgb;
	
	float d = linear_depth(DEPTH_TEXTURE, SCREEN_UV, INV_PROJECTION_MATRIX);
	
	// calculate the offset size of a single pixel
	vec2 screen_size = vec2(textureSize(SCREEN_TEXTURE, 1));
	
	vec2 pixel_size = (distance_falloff / d) / vec2(screen_size.x, screen_size.y);

	float du = linear_depth(DEPTH_TEXTURE, SCREEN_UV+vec2(0.0, pixel_size.y), INV_PROJECTION_MATRIX);
	float dd = linear_depth(DEPTH_TEXTURE, SCREEN_UV+vec2(0.0, -pixel_size.y), INV_PROJECTION_MATRIX);
	float dr = linear_depth(DEPTH_TEXTURE, SCREEN_UV+vec2(pixel_size.x, 0.0), INV_PROJECTION_MATRIX);
	float dl = linear_depth(DEPTH_TEXTURE, SCREEN_UV+vec2(-pixel_size.x, 0.0), INV_PROJECTION_MATRIX);

	// combine all the abs differences in depth of neighbors
	ALPHA = 
		abs_diff(d, du) +
		abs_diff(d, dl) +
		abs_diff(d, dd) +
		abs_diff(d, dr) 
	;
	
	ALPHA = smoothstep(smoothing_cutoff, max(smoothing_cutoff, smoothing_max), ALPHA);
	
	// apply the alpha from the outline color as well
	ALPHA *= outline_color.a;
	
	// clamp the outline color to remove artifacts
	ALPHA = clamp(ALPHA, 0.0, 1.0);
}