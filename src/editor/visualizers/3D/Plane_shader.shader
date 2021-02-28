shader_type spatial;

render_mode cull_disabled;

// enum {
const int ALBEDO_FROM_ALBEDO = 0;
const int ALBEDO_FROM_HEIGHT = 1;
const int ALBEDO_FROM_NORMAL = 2;
// }

uniform sampler2D albedo_map;
uniform sampler2D height_map;
uniform sampler2D normal_map;
uniform bool use_albedo = true;
uniform bool use_height = true;
uniform bool use_normal = true;
uniform int albedo_source = 0;

varying float height;

void vertex() {
	height = texture(height_map, UV).r;
	VERTEX.y += float(use_height) * height;
}

void fragment() {
	vec3 normal = texture(normal_map, UV).xyz;
	vec4 texel = texture(albedo_map, UV);
	
	vec4 sources[3];
	sources[ALBEDO_FROM_ALBEDO] = texel;
	sources[ALBEDO_FROM_HEIGHT] = vec4(height, height, height, 1);
	sources[ALBEDO_FROM_NORMAL] = vec4(normal, 1);
	
	vec4 color = sources[albedo_source] * COLOR;
	NORMALMAP = float(use_normal) * normal;
	ALBEDO = mix(vec3(1), color.rgb, float(use_albedo));
	ALPHA = color.a;
}