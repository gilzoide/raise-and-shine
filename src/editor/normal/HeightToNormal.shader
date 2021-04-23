shader_type canvas_item;

uniform float bump_scale = 1;
uniform bool invert_y = false;

void fragment() {
	vec2 uv_offset = TEXTURE_PIXEL_SIZE;

	// Ref: https://github.com/Scrawk/Terrain-Topology-Algorithms/blob/afe65384254462073f41984c4c8e7e029275d830/Assets/TerrainTopology/Scripts/CreateTopolgy.cs#L162
	float z1 = texture(TEXTURE, UV + vec2(- 1, + 1) * uv_offset).r;
	float z2 = texture(TEXTURE, UV + vec2(+ 0, + 1) * uv_offset).r;
	float z3 = texture(TEXTURE, UV + vec2(+ 1, + 1) * uv_offset).r;
	float z4 = texture(TEXTURE, UV + vec2(- 1, + 0) * uv_offset).r;
	float z6 = texture(TEXTURE, UV + vec2(+ 1, + 0) * uv_offset).r;
	float z7 = texture(TEXTURE, UV + vec2(- 1, - 1) * uv_offset).r;
	float z8 = texture(TEXTURE, UV + vec2(+ 0, - 1) * uv_offset).r;
	float z9 = texture(TEXTURE, UV + vec2(+ 1, - 1) * uv_offset).r;

	float zx = (z3 + z6 + z9 - z1 - z4 - z7) / 6.0f * bump_scale;
	float zy = (z1 + z2 + z3 - z7 - z8 - z9) / 6.0f * bump_scale;
	vec3 normal = normalize(vec3(-zx, zy, 1.0));
	normal.y = mix(normal.y, -normal.y, float(invert_y));
	
	COLOR.rgb = normal * 0.5 + 0.5;
}
