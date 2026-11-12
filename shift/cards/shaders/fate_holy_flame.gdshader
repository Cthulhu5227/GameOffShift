shader_type canvas_item;
#include "card_common.gdshaderinc"

// Holy flame rising outward from the fate circle's rim.
// Used by AuraEffect; FatePentagon sets rect_size, ring_radius and tweens intensity.

uniform vec2 rect_size = vec2(400.0, 400.0);
uniform float ring_radius = 124.0;
uniform vec4 core_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 gold_color : source_color = vec4(1.0, 0.97, 0.85, 1.0);
uniform vec4 tip_color : source_color = vec4(1.0, 0.88, 0.6, 1.0);
uniform float flame_height = 30.0;
uniform float speed = 0.9;

void fragment() {
	vec2 p = (UV - 0.5) * rect_size;  // pixels from the circle's centre
	float d = length(p) - ring_radius; // distance outside the rim
	if (d < 0.0) {
		discard;
	}
	vec2 dir = normalize(p);

	// Pull the noise inward over time so the flames flow outward. Using p (not the
	// angle) keeps it seamless all the way round.
	float n = fbm(p * 0.045 - dir * TIME * speed * 1.5);
	float heat = clamp(1.0 - d / (flame_height * (0.3 + n)), 0.0, 1.0);
	float halo = exp(-d / 8.0) * (0.75 + 0.25 * sin(TIME * 1.5));

	vec3 col = mix(tip_color.rgb, gold_color.rgb, smoothstep(0.0, 0.35, heat));
	col = mix(col, core_color.rgb, smoothstep(0.3, 0.8, max(heat, halo)));
	float alpha = clamp(smoothstep(0.0, 0.4, heat) + halo * 0.6, 0.0, 1.0);

	// Fade before the rect's edge so nothing looks cut off.
	float to_edge = rect_size.x * 0.5 - length(p);
	alpha *= smoothstep(0.0, 12.0, to_edge) * intensity;
	COLOR = vec4(col, alpha);
}
