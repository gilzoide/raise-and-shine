shader_type canvas_item;

render_mode unshaded;

void fragment() {
	vec4 texel = texture(TEXTURE, UV);
	vec3 rgb = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0).rgb * texel.rgb * texel.a;
	COLOR = vec4(clamp(rgb, 0.0, 1.0), 1.0);
}