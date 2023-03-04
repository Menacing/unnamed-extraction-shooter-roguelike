shader_type particles;

render_mode keep_data,disable_force,disable_velocity;

uniform float height = 1;

void process() {
	vec3 a = (EMISSION_TRANSFORM*vec4(0,-height,0,1)).xyz;
	vec3 b = (EMISSION_TRANSFORM*vec4(0,height,0,1)).xyz;
	
	if(CUSTOM.w == LIFETIME){
		CUSTOM.z = LIFETIME;
		CUSTOM.w = 0.0;
	}
	
	if(CUSTOM.w == 0.0){
		TRANSFORM[0].xyz = b;
		TRANSFORM[1].xyz = a;
		TRANSFORM[2].xyz = a;
		TRANSFORM[3].xyz = b;
	}
	if(CUSTOM.w == 1.0){
		TRANSFORM[0].xyz = b;
		TRANSFORM[1].xyz = a;
	}
	
	CUSTOM.w++;
}