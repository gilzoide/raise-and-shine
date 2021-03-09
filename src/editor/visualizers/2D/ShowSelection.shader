shader_type canvas_item;

uniform sampler2D selection_map;
uniform vec2 selection_texture_pixel_size;
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
	vec2 uv_offset = selection_texture_pixel_size * selection_pixel_width;
	bool this_is_selection = texture(selection_map, UV).r > 0.5;
	bool this_is_border = (!this_is_selection) && is_any_neighbour_selection(selection_map, UV, uv_offset);
	vec4 selection_color = vec4(vec3(1) - texel.rgb, 1);
	float selection_factor = float(this_is_selection) * 0.2 + float(this_is_border);
	vec4 color = mix(texel, selection_color, selection_factor);
	COLOR = color;
}
