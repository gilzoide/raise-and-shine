shader_type spatial;

render_mode unshaded;

uniform vec4 albedo: hint_color = vec4(0, 0, 0, 1);
uniform float selection_radius = 0.3;

uniform float height_scale = 64;
uniform float height: hint_range(0, 1) = 0;

varying vec2 adjusted_uv;
varying float is_selection;

void vertex() {
	adjusted_uv = (UV - 0.5 + selection_radius) / (2.0 * selection_radius);
	is_selection = float(adjusted_uv.x > 0.0 && adjusted_uv.x < 1.0 && adjusted_uv.y > 0.0 && adjusted_uv.y < 1.0);
	VERTEX.y += float(is_selection) * height * height_scale;
}

void fragment() {
	vec3 selection_color = vec3(1) - albedo.rgb;
	ALBEDO = mix(albedo.rgb, selection_color, float(is_selection));
}