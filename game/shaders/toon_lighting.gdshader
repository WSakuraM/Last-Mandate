shader_type spatial;

uniform vec4 albedo_color : source_color = vec4(0.5, 0.4, 0.35, 1.0);
uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform bool use_texture = false;
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform float shadow_threshold : hint_range(-1.0, 1.0) = 0.2;
uniform vec4 shadow_color : source_color = vec4(0.2, 0.15, 0.12, 1.0);
uniform float steps : hint_range(2.0, 6.0) = 3.0;
uniform float wind_strength : hint_range(0.0, 0.4) = 0.0;
uniform float wind_speed : hint_range(0.2, 3.0) = 1.25;

void vertex() {
	if (wind_strength > 0.001) {
		float h = max(VERTEX.y, 0.0);
		float sway = sin(TIME * wind_speed + VERTEX.x * 0.85 + VERTEX.z * 0.55) * wind_strength;
		VERTEX.x += sway * (h * 0.45 + 0.12);
		VERTEX.z += sway * 0.35 * (h * 0.3 + 0.08);
	}
}

void fragment() {
	vec2 tiled = UV * uv_scale;
	vec3 base = albedo_color.rgb;
	if (use_texture) {
		base *= texture(albedo_tex, tiled).rgb;
	}
	ALBEDO = base;
	ROUGHNESS = 0.92;
}

void light() {
	float ndotl = dot(NORMAL, LIGHT);
	float ramp = clamp(ndotl * 0.5 + 0.5, 0.0, 1.0);
	float toon = floor(ramp * steps + 0.5) / steps;
	toon = mix(ramp, toon, 0.4);
	DIFFUSE_LIGHT += mix(shadow_color.rgb, ALBEDO, toon) * ATTENUATION * LIGHT_COLOR;
}
