shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform sampler2D mult : hint_default_white;
uniform sampler2D squig : hint_default_white;
uniform sampler2D overlay : hint_default_white;

uniform float squiginv : hint_range(0.0, 1.0) = 0.5;

const float HorizonalBlur = 0.0004;
const float VerticalBlur  = 0.0002;
const float ColorBlur     = 0.0015;

vec4 blur(sampler2D image, vec2 uv, float size1, float size2, vec2 screen_pixel_size){
	vec2 tc0 = uv + vec2(        0.0,   size2 * 4.0) * screen_pixel_size;
	vec2 tc1 = uv + vec2( size1       ,  -size2 * 3.0) * screen_pixel_size;
	vec2 tc2 = uv + vec2( size1 * 2.0,  -size2 * 2.0) * screen_pixel_size;
	vec2 tc3 = uv + vec2( size1 * 3.0,   size2       ) * screen_pixel_size;
	vec2 tc4 = uv + vec2( size1 * 4.0,           0.0) * screen_pixel_size;
	vec2 tc5 = uv + vec2(-size1       ,  -size2 * 4.0) * screen_pixel_size;
	vec2 tc6 = uv + vec2(-size1 * 2.0,   size2 * 2.0) * screen_pixel_size;
	vec2 tc7 = uv + vec2(-size1 * 3.0,  -size2       ) * screen_pixel_size;
	vec2 tc8 = uv + vec2(-size1 * 4.0,           0.0) * screen_pixel_size;

	vec4 col0 = texture(image, tc0);
	vec4 col1 = texture(image, tc1);
	vec4 col2 = texture(image, tc2);
	vec4 col3 = texture(image, tc3);
	vec4 col4 = texture(image, tc4);
	vec4 col5 = texture(image, tc5);
	vec4 col6 = texture(image, tc6);
	vec4 col7 = texture(image, tc7);
	vec4 col8 = texture(image, tc8);

	return (col0 + col1 + col2 + col3 + col4 + col5 + col6 + col7 + col8) / 9.0;
}

vec4 multfunc(vec4 img1, vec4 img2) {
	if(img1.r > 0.5) { img1.r = 1.0 - ((1.0 - img1.r) * (1.0 - img2.r) * 2.0); } else { img1.r = img1.r * img2.r * 2.0; }
	if(img1.g > 0.5) { img1.g = 1.0 - ((1.0 - img1.g) * (1.0 - img2.g) * 2.0); } else { img1.g = img1.g * img2.g * 2.0; }
	if(img1.b > 0.5) { img1.b = 1.0 - ((1.0 - img1.b) * (1.0 - img2.b) * 2.0); } else { img1.b = img1.b * img2.b * 2.0; }
	return img1;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 ps = SCREEN_PIXEL_SIZE;
	
	// Usamos una onda sinusoidal pura para que la oscilación de la distorsión sea fluidísima a 60 FPS
	float dynamic_squiginv = squiginv * sin(TIME * 90.0);
	
	vec4 col = blur(SCREEN_TEXTURE, uv, HorizonalBlur, VerticalBlur, ps) * texture(mult, uv) * 2.0;
	uv += vec2(((texture(squig, uv * 0.46875).g - 0.5) * dynamic_squiginv) * (col.g - col.r) * 0.005, 0.0);
	
	col = blur(SCREEN_TEXTURE, uv, HorizonalBlur, VerticalBlur, ps);
	vec4 blr = blur(SCREEN_TEXTURE, uv, ColorBlur, VerticalBlur, ps);
	
	vec4 final_col = multfunc((blr + (col.r + col.g + col.b - blr.r - blr.g - blr.b) / 3.0) * texture(mult, uv) * 2.0, texture(overlay, uv * 0.46875));
	COLOR = final_col;
}