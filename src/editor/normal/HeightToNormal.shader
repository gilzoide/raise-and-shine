shader_type canvas_item;

uniform float bump_scale = 1;

void fragment() {
	vec2 uv_offset = TEXTURE_PIXEL_SIZE;
	float here = texture(TEXTURE, UV).r;
	float above = texture(TEXTURE, UV + vec2(0, uv_offset.y)).r;
	float right = texture(TEXTURE, UV + vec2(uv_offset.x, 0)).r;
	vec3 up = vec3(0, 1, (here - above) * bump_scale);
	vec3 across = vec3(1, 0, (right - here) * bump_scale);
	vec3 normal = normalize(cross(across, up));
	
	COLOR.rgb = normal * 0.5 + 0.5;
}