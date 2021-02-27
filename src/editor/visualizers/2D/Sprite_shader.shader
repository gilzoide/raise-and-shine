shader_type canvas_item;

uniform bool use_normal = true;

void fragment() {
	NORMALMAP = float(use_normal) * texture(NORMAL_TEXTURE, UV).rgb;
}