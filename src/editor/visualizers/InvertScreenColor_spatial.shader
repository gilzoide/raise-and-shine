shader_type spatial;

render_mode unshaded;

void fragment() {
	vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	ALBEDO = vec3(1) - color.rgb;
}