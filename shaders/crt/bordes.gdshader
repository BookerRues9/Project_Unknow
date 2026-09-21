shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float distortion : hint_range(0.0, 1.0) = 0.2;
uniform bool distort = true;
uniform bool border = true;

vec2 radialDistortion(vec2 coord) {
	vec2 cc = coord - 0.5;
	float dist = dot(cc, cc) * distortion;
	return (coord + cc * (1.0 + dist) * dist);
}

float corner(vec2 coord, vec2 screen_size) {
	vec2 overscan = vec2(0.99, 0.99);
	vec2 aspect = vec2(screen_size.x / screen_size.x, screen_size.y / screen_size.x);
	vec2 ccoord = (coord - vec2(0.5)) * overscan + vec2(0.5);
	ccoord = min(ccoord, vec2(1.0) - ccoord) * aspect;
	vec2 cdist = vec2(0.03);
	ccoord = (cdist - min(ccoord, cdist));
	float dist = sqrt(dot(ccoord, ccoord));
	return clamp((cdist.x - dist) * 80.0, 0.0, 1.0);
}

void fragment() {
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 uv = SCREEN_UV;
	
	if (distort) {
		uv = radialDistortion(uv);
	}
	
	// Si la distorsión saca la UV fuera de la pantalla, pintamos negro usando un else
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		// Rejilla de píxeles estilo CRT
		vec2 snapped_uv = (floor(uv * screen_size) + vec2(0.5)) / screen_size;
		vec4 col = texture(SCREEN_TEXTURE, snapped_uv);
		
		float input_gamma = 2.4;
		float output_gamma = 2.8;
		col.rgb = pow(abs(col.rgb), vec3(input_gamma));
		
		if (border) {
			float cval = corner(uv, screen_size);
			col.rgb = pow(abs(col.rgb), vec3(1.0 / (2.0 * input_gamma - output_gamma))) * vec3(cval);
		} else {
			col.rgb = pow(abs(col.rgb), vec3(1.0 / (2.0 * input_gamma - output_gamma)));
		}
		
		COLOR = vec4(col.rgb, 1.0);
	}
}