shader_type spatial;

// enum {
const int ALBEDO_FROM_ALBEDO = 0;
const int ALBEDO_FROM_HEIGHT = 1;
const int ALBEDO_FROM_NORMAL = 2;
// }

uniform sampler2D albedo_map;
uniform sampler2D height_map;
uniform sampler2D normal_map;
uniform sampler2D selection_map;
uniform bool use_albedo = true;
uniform bool use_height = true;
uniform bool use_normal = true;
uniform bool use_alpha = true;
uniform int albedo_source = 0;
uniform float selection_pixel_width = 0.5;
uniform vec2 TEXTURE_PIXEL_SIZE;
uniform float height_scale = 0.5;

varying float height;

void vertex() {
	height = texture(height_map, UV).r;
	VERTEX.y += float(use_height) * height * height_scale;
}

bool is_any_neighbour_selection(sampler2D tex, vec2 uv, vec2 uv_offset) {
	return 0.0 
		// diagonals
		+ texture(tex, uv + vec2(-1, -1) * uv_offset).r
		+ texture(tex, uv + vec2(-1, 1) * uv_offset).r
		+ texture(tex, uv + vec2(1, -1) * uv_offset).r
		+ texture(tex, uv + vec2(1, 1) * uv_offset).r
		// sides
		+ texture(tex, uv + vec2(-1, 0) * uv_offset).r
		+ texture(tex, uv + vec2(0, -1) * uv_offset).r
		+ texture(tex, uv + vec2(0, 1) * uv_offset).r
		+ texture(tex, uv + vec2(1, 0) * uv_offset).r
		> 0.5;
}

void fragment() {
	vec3 normal = texture(normal_map, UV).xyz;
	vec4 texel = texture(albedo_map, UV);
	texel.a = mix(1, texel.a, float(use_alpha));
	
	vec4 color = float(albedo_source == ALBEDO_FROM_ALBEDO) * texel
		+ float(albedo_source == ALBEDO_FROM_HEIGHT) * vec4(height, height, height, 1)
		+ float(albedo_source == ALBEDO_FROM_NORMAL) * vec4(normal, 1);
	
	vec2 uv_offset = TEXTURE_PIXEL_SIZE * selection_pixel_width;
	bool this_is_not_selection = texture(selection_map, UV).r < 0.5;
	bool this_is_border = this_is_not_selection && is_any_neighbour_selection(selection_map, UV, uv_offset);
	vec3 selection_color = vec3(1) - color.rgb;
	color = mix(color, vec4(selection_color, 1), float(this_is_border));
	
	NORMALMAP = mix(NORMALMAP, normal, float(use_normal));
	ALBEDO = mix(vec3(1), color.rgb, float(use_albedo));
	ALPHA = color.a;
	EMISSION = selection_color * float(this_is_border);
}