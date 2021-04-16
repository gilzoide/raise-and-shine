shader_type canvas_item;

render_mode unshaded;

void fragment() {
	vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	COLOR = vec4(vec3(1.0) - color.rgb, 1.0);
}