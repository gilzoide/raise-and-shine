shader_type spatial;

render_mode unshaded;

uniform vec2 plane_size;
uniform vec2 map_size;
uniform float height_scale = 1;
uniform sampler2D height_map;
uniform sampler2D normal_map;

varying vec2 map_uv;
varying vec3 normal_rgb;


void vertex() {
	float y = float(INSTANCE_ID / int(map_size.x));
	float x = float(INSTANCE_ID % int(map_size.x));
	map_uv = vec2(x, y) / map_size;
	float height = texture(height_map, map_uv).r * height_scale;
	vec2 origin_scale = plane_size / map_size;
	vec2 half_size = map_size * 0.5;
	vec2 origin2d = (vec2(x, y) + 0.5 - half_size) * origin_scale;
	
//	normal_rgb = texture(normal_map, map_uv).rgb;
//	vec3 normal = normalize((normal_rgb - 0.5) * 2.0);
	
//	vec3 right = normalize(cross(normal, vec3(0, 1, 0)));
//	vec3 forward = normalize(cross(right, normal));
//	mat4 rotation = mat4(
//		vec4(right, 0),
//		vec4(forward, 0),
//		vec4(normal, 0),
//		vec4(0, 0, 0, 1)
//	);
	
//	VERTEX = (rotation * vec4(VERTEX, 1)).xyz + vec3(origin2d.x, height, origin2d.y);
	VERTEX += vec3(origin2d.x, height, origin2d.y);
}


void fragment() {
	ALBEDO = normal_rgb;
}
