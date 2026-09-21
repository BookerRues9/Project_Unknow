shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D albedo_texture : source_color, filter_nearest;

// Selector de espacio para el mapeo triplanar desde el inspector
// 0 = Espacio Local (Malla), 1 = Espacio Global (Mundo - perfecto para laberintos/pisos continuos)
uniform int uv1_projection_mode : hint_enum("Local Space", "World Space") = 0;

// Controles de escala y repetición
uniform vec2 uv1_scale = vec2(1.0, 1.0);
uniform vec2 uv1_offset = vec2(0.0, 0.0);
uniform bool enable_repeat = true; // Interruptor para activar/desactivar la repetición de textura

// Control de pixelado de textura
uniform float texture_pixelation : hint_range(4.0, 256.0) = 32.0;

// Cantidad de colores para la paleta retro
uniform int color_levels : hint_range(2, 32) = 16;             

varying vec3 vertex_position;
varying vec3 vertex_normal;
varying vec3 world_position;

void vertex() {
	vertex_normal = NORMAL;
	vertex_position = VERTEX;
	
	// Calculamos también la posición en el mundo por si el modo es "World Space"
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Elegimos la fuente de coordenadas según la opción del inspector
	vec3 sample_pos = (uv1_projection_mode == 0) ? vertex_position : world_position;

	// Mapeo Triplanar automático basado en las normales de las caras
	vec3 normal = abs(vertex_normal);
	vec2 uv_x = sample_pos.zy * uv1_scale + uv1_offset;
	vec2 uv_y = sample_pos.xz * uv1_scale + uv1_offset;
	vec2 uv_z = sample_pos.xy * uv1_scale + uv1_offset;

	// Si el modo repeat está desactivado, limitamos las UVs entre 0.0 y 1.0 para que la textura se estire completa
	if (!enable_repeat) {
		uv_x = clamp(uv_x, 0.0, 1.0);
		uv_y = clamp(uv_y, 0.0, 1.0);
		uv_z = clamp(uv_z, 0.0, 1.0);
	} else {
		// Si está activado, permitimos que se repita en mosaico
		uv_x = mod(uv_x, 1.0);
		uv_y = mod(uv_y, 1.0);
		uv_z = mod(uv_z, 1.0);
	}

	// EFECTO PIXELADO DE TEXTURA (Cuantización de UVs)
	uv_x = floor(uv_x * texture_pixelation) / texture_pixelation;
	uv_y = floor(uv_y * texture_pixelation) / texture_pixelation;
	uv_z = floor(uv_z * texture_pixelation) / texture_pixelation;

	vec4 col_x = texture(albedo_texture, uv_x);
	vec4 col_y = texture(albedo_texture, uv_y);
	vec4 col_z = texture(albedo_texture, uv_z);
	
	vec4 tex_color = col_x * normal.x + col_y * normal.y + col_z * normal.z;

	// Reducción de colores estilo PS1
	vec3 quantized = floor(tex_color.rgb * float(color_levels)) / float(color_levels);
	
	ALBEDO = quantized;
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;
}