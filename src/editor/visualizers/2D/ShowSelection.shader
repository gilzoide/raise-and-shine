shader_type canvas_item;

uniform sampler2D selection_map;
uniform float selection_pixel_width = 0.5;

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
	vec4 texel = texture(TEXTURE, UV);
	vec2 uv_offset = TEXTURE_PIXEL_SIZE * selection_pixel_width;
	bool this_is_not_selection = texture(selection_map, UV).r < 0.5;
	bool this_is_border = this_is_not_selection && is_any_neighbour_selection(selection_map, UV, uv_offset);
	vec4 selection_color = vec4(vec3(1) - texel.rgb, 1);
	vec4 color = mix(texel, selection_color, float(this_is_border));
	COLOR = color;
}
