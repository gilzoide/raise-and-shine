shader_type canvas_item;

void fragment() {
	NORMALMAP = texture(NORMAL_TEXTURE, UV).rgb;
}