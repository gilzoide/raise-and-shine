shader_type spatial;

uniform sampler2D albedo_map;
uniform sampler2D height_map;
uniform sampler2D normal_map;
uniform bool use_albedo = true;
uniform bool use_height = true;
uniform bool use_normal = true;

void vertex() {
	float height = float(use_height) * texture(height_map, UV).r;
	VERTEX.y += height;
}

void fragment() {
	NORMALMAP = float(use_normal) * texture(normal_map, UV).xyz;
	vec4 color = mix(vec4(1), texture(albedo_map, UV), float(use_albedo)) * COLOR;
	ALBEDO = color.rgb;
	ALPHA = color.a;
}