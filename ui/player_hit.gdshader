/*
	グリッチ トランジション シェーダー by あるる（きのもと 結衣） @arlez80
	Glitch Transition Shader by Yui Kinomoto @arlez80

	MIT License
*/

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float shake_power = 0.03;
uniform float shake_block_size = 30.5;
uniform float fade : hint_range( 0.0, 1.0 ) = 0.01;
uniform vec2 direction_r = vec2( 1.0, 0.0 );
uniform vec2 direction_g = vec2( 0.4, 1.0 );
uniform vec2 direction_b = vec2( -0.7, -0.3 );

float random( float seed )
{
	return fract( 543.2543 * sin( dot( vec2( seed, seed ), vec2( 3525.46, -54.3415 ) ) ) );
}

void fragment( )
{
	vec2 fixed_uv = SCREEN_UV;
	fixed_uv.x += (
		random(
			( trunc( SCREEN_UV.y * shake_block_size ) / shake_block_size )
		+	TIME
		) - 0.5
	) * shake_power * ( fade * 12.0 );

	COLOR = vec4(
		textureLod( SCREEN_TEXTURE, fixed_uv + normalize( direction_r ) * fade, 0.0 ).r
	,	textureLod( SCREEN_TEXTURE, fixed_uv + normalize( direction_g ) * fade, 0.0 ).g
	,	textureLod( SCREEN_TEXTURE, fixed_uv + normalize( direction_b ) * fade, 0.0 ).b
	,	0.0
	) * ( 1.0 - fade );
	COLOR.a = 1.0;
}