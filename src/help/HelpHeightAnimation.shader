shader_type spatial;

render_mode unshaded;

uniform vec4 albedo: hint_color = vec4(0, 0, 0, 1);
uniform float selection_radius = 0.3;

uniform float height_scale = 64;
uniform float height: hint_range(0, 1) = 0;
uniform bool is_flat = true;
uniform float direction;
uniform vec2 control1 = vec2(0);
uniform vec2 control2 = vec2(1);

varying float is_selection;

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

void vertex() {
	vec2 adjusted_uv = (UV - 0.5 + selection_radius) / (2.0 * selection_radius);
	is_selection = float(adjusted_uv.x > 0.0 && adjusted_uv.x < 1.0 && adjusted_uv.y > 0.0 && adjusted_uv.y < 1.0);
	if(is_selection > 0.5) {
		float dirheight = is_flat ? 1.0 : clamp(directional_height((adjusted_uv - 0.5) * 2.0), 0, 1);
		VERTEX.y += height * dirheight * height_scale;
	}
}

void fragment() {
	vec3 selection_color = vec3(1) - albedo.rgb;
	ALBEDO = mix(albedo.rgb, selection_color, float(is_selection));
}