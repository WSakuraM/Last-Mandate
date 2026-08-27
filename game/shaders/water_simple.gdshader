shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, specular_schlick_ggx;

uniform vec4 color_shallow : source_color = vec4(0.52, 0.78, 0.80, 0.82);
uniform vec4 color_deep : source_color = vec4(0.22, 0.46, 0.54, 0.88);
uniform float speed : hint_range(0.2, 3.0) = 1.15;

void fragment() {
	float w = 0.5
		+ 0.28 * sin(UV.x * 14.0 + TIME * speed * 1.4)
		+ 0.22 * sin(UV.y * 11.0 - TIME * speed * 1.05)
		+ 0.12 * sin((UV.x + UV.y) * 7.0 + TIME * speed * 0.7);
	ALBEDO = mix(color_deep.rgb, color_shallow.rgb, clamp(w, 0.0, 1.0));
	ALPHA = mix(color_deep.a, color_shallow.a, 0.5);
	ROUGHNESS = 0.18;
	METALLIC = 0.08;
	EMISSION = ALBEDO * 0.08;
}
