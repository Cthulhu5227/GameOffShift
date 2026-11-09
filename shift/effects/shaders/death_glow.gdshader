shader_type canvas_item;
#include "card_common.gdshaderinc"

// Death: cold smoke drifting off the card, a thin bone-white rim,
// and a bright "scythe" sweep that circles the card.

uniform vec4 smoke_color : source_color = vec4(0.38, 0.32, 0.45, 1.0);
uniform vec4 bone_color : source_color = vec4(0.92, 0.9, 0.82, 1.0);
uniform float smoke_reach = 35.0; // pixels
uniform float sweep_speed = 0.35; // turns per second

void fragment() {
	vec2 p = card_pos(UV);
	float d = card_dist(p);
	if (d < 0.0) {
		discard;
	}

	// Smoke: slow noise that sways sideways and rises.
	float n = fbm(vec2(p.x * 0.035 + sin(TIME * 0.4) * 0.6, p.y * 0.035 + TIME * 0.5));
	float smoke = smoothstep(0.35, 0.8, n) * exp(-d / smoke_reach);

	// Thin pale rim hugging the edge.
	float rim = exp(-d / 2.0);

	// Scythe sweep: a sawtooth by angle. pow() gives a long fading tail,
	// and the smoothstep softens the blade's front edge.
	float angle = atan(p.y, p.x);
	float sweep = fract(angle / TAU + TIME * sweep_speed);
	float blade = pow(sweep, 14.0) * smoothstep(1.0, 0.97, sweep) * exp(-d / 10.0);

	float light = clamp(rim + blade, 0.0, 1.0);
	vec3 col = mix(smoke_color.rgb, bone_color.rgb, light);
	float alpha = clamp(smoke * 0.9 + light, 0.0, 1.0) * edge_fade(p) * intensity;
	COLOR = vec4(col, alpha);
}
