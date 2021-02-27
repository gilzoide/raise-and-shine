shader_type spatial;

uniform sampler2D albedo_map;
uniform sampler2D height_map;
uniform sampler2D normal_map;

void vertex() {
	float height = texture(height_map, UV).r;
	VERTEX.y += height;
}

void fragment() {
	NORMALMAP = texture(normal_map, UV).xyz;
	vec4 color = texture(albedo_map, UV) * COLOR;
	ALBEDO = color.rgb;
	ALPHA = color.a;
}