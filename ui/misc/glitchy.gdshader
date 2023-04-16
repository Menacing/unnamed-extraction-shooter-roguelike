shader_type canvas_item;

uniform vec2 resolution = vec2(64.0, 64.0);
uniform float noise : hint_range(0.0, 1.0) = 0.2;
uniform float distort : hint_range(0.0, 1.0) = 0.06;
uniform float offset : hint_range(0.0, 1.0) = 0.0;

vec2 random(vec2 uv){
    uv = vec2(dot(uv, vec2(127.1,311.7)), dot(uv, vec2(269.5,183.3)));
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float between(float lower, float upper, float value) {
	return step(lower, value) * step(value, upper);
}

void fragment()
{
	vec2 uv = UV;
	// Distort
	float oy = offset / 10.;
	float dist = distort * clamp(offset / 2., 0.25, 0.75);
	uv.x += dist * between(0.7, 0.8, fract(offset + TIME/4.)) * between(0.4, 0.41 + oy, uv.y);
	uv.x -= dist * between(0.1, 0.15, fract(offset + TIME/3.)) * between(0.7, 0.71 + oy, uv.y);
	uv.x += dist * between(0.15, 0.25, fract(offset + TIME/3.)) * between(0.6, 0.61 + oy, uv.y);
	uv.x += dist * between(0.5, 0.55, fract(offset + TIME/7.)) * between(0.5, 0.73 - oy, uv.y);
	// Add noise
	vec4 pxl = texture(TEXTURE, uv);
	pxl.rgb += clamp(random((ceil(UV * resolution) / resolution) + trunc(fract(TIME) * 4.)).x, 0.0, 1.0) * noise;
	// Shade
	COLOR = pxl;
}