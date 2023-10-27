shader_type spatial;
render_mode blend_mix, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D lens_texture : source_color;
uniform vec4 lens_color : source_color = vec4(0.0, 0.0, 0.0, .2);

uniform sampler2D retical_texture : source_color, repeat_disable;
uniform vec4 retical_color : source_color = vec4(1.0);
uniform float retical_size : hint_range(0.0, 100.0) = 0.0;
uniform bool flicker = false;
uniform float flicker_rate: hint_range(0, 60) = 60.0;
uniform float depth : hint_range(0.0, 100.0) = 10.0;
uniform float offset_x = 0.0;
uniform float offset_y = 0.0;
uniform float emission_strength: hint_range(0, 16) = .2;

varying vec2 offset;
varying vec2 lens_dir;

void vertex() {
	vec3 world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 view_dir = CAMERA_POSITION_WORLD - world_position;
	offset = VERTEX.xy - vec2(offset_x, offset_y);
	lens_dir = (inverse(MODEL_MATRIX) * vec4(view_dir, 0.0)).xz;
}

void fragment() {
	vec4 color = texture(lens_texture, UV) * lens_color;
	
	vec2 offset_uv = offset;
	offset_uv -= (lens_dir * depth);
	offset_uv /= (retical_size * depth);
	offset_uv += vec2(0.5);
	
	float retical_a = texture(retical_texture, offset_uv).a;
	float square_wave = max(0.1, sign(sin(TIME * flicker_rate * 2.0 * PI)));
	
	if (flicker) {
		retical_a *= square_wave;
	}

	color.rgb += retical_a * retical_color.rgb * retical_color.a;
	color.a += retical_a * retical_color.a;
	
	ALBEDO = color.rgb;
	ALPHA = color.a;
	EMISSION = retical_color.rgb * retical_a * emission_strength;
}