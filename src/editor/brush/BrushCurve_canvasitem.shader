shader_type canvas_item;

uniform bool is_flat = true;
uniform float direction;
uniform vec2 control1 = vec2(0);
uniform vec2 control2 = vec2(1);
uniform bool is_inverted = false;

vec2 interpolate_bezier(vec2 start, vec2 c1, vec2 c2, vec2 end, float t) {
	float omt = (1.0 - t);
	float omt2 = omt * omt;
	float omt3 = omt2 * omt;
	float t2 = t * t;
	float t3 = t2 * t;
	return start * omt3
			+ c1 * omt2 * t * 3.0
			+ c2 * omt * t2 * 3.0
			+ end * t3;
}

float directional_height(vec2 uv) {
	float t;
	if(isnan(direction)) {
		t = length(uv);
	}
	else {
		float angle = atan(uv.y, uv.x);
		float delta_factor = -cos(direction - angle);
		t = delta_factor * length(uv) * 0.5 + 0.5;
	}
	return interpolate_bezier(vec2(0), control1, control2, vec2(1), 1.0 - clamp(t, 0, 1)).y;
}

void fragment() {
	float height = is_flat ? 1.0 : clamp(directional_height((UV - 0.5) * 2.0), 0, 1);
	vec4 texel = texture(TEXTURE, UV);
	float grayscale = dot(texel.rgb, vec3(0.3, 0.59, 0.11));
	grayscale = mix(grayscale, 1.0 - grayscale, float(is_inverted));
	COLOR *= vec4(vec3(grayscale), texel.a * height);
}