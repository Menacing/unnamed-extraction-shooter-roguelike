shader_type spatial;
render_mode blend_add,cull_disabled,unshaded;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,repeat_enable;


void vertex() {
	 // Transform the vertex position to world space
    vec4 vertex_world_position = MODEL_MATRIX * vec4(VERTEX, 1.0);

    // Compute the vector from the vertex to the camera
    vec3 to_camera_vector = CAMERA_POSITION_WORLD - vertex_world_position.xyz;
	vec3 to_camera_minus_z = vec3(to_camera_vector.x, to_camera_vector.y, 0.0);

	//(represents right direction)
	vec4 ax = vec4(normalize(cross(MODEL_MATRIX[0].xyz, to_camera_vector)), 0.0);
	//(represents up direction)
	vec4 ay = vec4(normalize(cross(MODEL_MATRIX[2].xyz, to_camera_vector)), 0.0);
	//(represents forward direction)
	vec4 az = vec4(normalize(MODEL_MATRIX[2].xyz), 0.0);
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(ax, ay, az, MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA = albedo_tex.a * albedo.a;
}