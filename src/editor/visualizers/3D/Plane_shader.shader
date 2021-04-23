shader_type spatial;

render_mode cull_disabled, depth_draw_alpha_prepass;

// enum {
const int ALBEDO_FROM_ALBEDO = 0;
const int ALBEDO_FROM_HEIGHT = 1;
const int ALBEDO_FROM_NORMAL = 2;
// }

uniform sampler2D albedo_map : hint_albedo;
uniform sampler2D height_map;
uniform sampler2D normal_map : hint_normal;
uniform bool use_albedo = true;
uniform bool use_height = true;
uniform bool use_normal = true;
uniform bool use_alpha = true;
uniform bool invert_normal_y = false;
uniform int albedo_source = 0;
uniform float height_scale = 0.2;

void vertex() {
	float height = texture(height_map, UV).r;
	VERTEX.y += float(use_height) * height * height_scale;
}

void fragment() {
	float height = texture(height_map, UV).r;
	vec3 normal_rgb = texture(normal_map, UV).xyz;
	vec4 texel = texture(albedo_map, UV);
	texel.a = mix(1, texel.a, float(use_alpha));
	
	vec4 color = float(albedo_source == ALBEDO_FROM_ALBEDO) * texel
		+ float(albedo_source == ALBEDO_FROM_HEIGHT) * vec4(height, height, height, 1)
		+ float(albedo_source == ALBEDO_FROM_NORMAL) * vec4(normal_rgb, 1);
	
	normal_rgb.y = mix(normal_rgb.y, 1.0 - normal_rgb.y, float(invert_normal_y));
	NORMALMAP = mix(NORMALMAP, normal_rgb, float(use_normal));
	ALBEDO = mix(vec3(1), color.rgb, float(use_albedo));
	ALPHA = color.a;
}