shader_type canvas_item;
#include "card_common.gdshaderinc"

// The High Priestess: a calm, sacred white-and-gold flame rising from the card's edges.
// Slower and wispier than the Devil's hellfire, with a soft halo underneath.

uniform vec4 core_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);   // pure white, at the edge
uniform vec4 gold_color : source_color = vec4(1.0, 0.97, 0.85, 1.0); // warm white
uniform vec4 tip_color : source_color = vec4(1.0, 0.88, 0.6, 1.0);   // pale gold flame tips
uniform float flame_height = 34.0; // pixels
uniform float speed = 0.9;
uniform float halo_falloff = 10.0; // pixels
uniform vec4 ray_color : source_color = vec4(1.0, 0.99, 0.94, 1.0);
uniform float ray_count = 9.0;      // how many beams in the curtain
uniform float ray_length = 45.0;    // how far the beams reach past the card (pixels)
uniform float ray_strength = 0.7;
uniform float ray_spread = 1.9;     // radians either side of straight down the curtain covers

void fragment() {
	vec2 p = card_pos(UV);
	float d = card_dist(p);
	if (d < 0.0) {
		discard;
	}

	// Two noise layers scrolling upward at different rates, warped sideways a little,
	// so the tongues sway gently instead of flickering.
	float warp = noise(vec2(p.y * 0.03 + TIME * speed * 0.5, p.x * 0.02)) - 0.5;
	float n = fbm(vec2(p.x * 0.05 + warp * 1.5, p.y * 0.035 + TIME * speed));
	n = mix(n, fbm(vec2(p.x * 0.09, p.y * 0.06 + TIME * speed * 1.7)), 0.35);

	// Flames reach further above the card than below it.
	float top = clamp(-p.y / (card_size.y * 0.5), -1.0, 1.0); // +1 at the top edge
	float height = flame_height * (1.0 + 0.5 * top);

	// heat: 1 at the card edge, 0 where the flame ends. Noise makes the tongues.
	float heat = clamp(1.0 - d / (height * (0.3 + n)), 0.0, 1.0);

	// Soft, gently breathing halo so the card always reads as glowing, not just burning.
	float halo = exp(-d / halo_falloff) * (0.75 + 0.25 * sin(TIME * 1.5));

	// Curtain of light: beams fanning out from the card's centre, falling down and
	// draping past the sides and bottom. Angle 0 = straight down.
	vec2 from = p - vec2(0.0, -card_size.y * 0.1); // source a little above centre
	float ang = atan(from.x, from.y);
	float drape = smoothstep(ray_spread, ray_spread * 0.4, abs(ang)); // fades out toward the top
	// Noise across the angle makes uneven beams that sway slowly, like folds in a curtain.
	float beams = smoothstep(0.4, 0.85, noise(vec2(ang * ray_count, TIME * 0.35)));
	// Shimmer travelling down each beam, as if light is pouring out.
	float pour = 0.7 + 0.3 * sin(length(from) * 0.09 - TIME * 2.2);
	float rays = beams * pour * drape * exp(-d / ray_length) * ray_strength;

	vec3 col = mix(tip_color.rgb, gold_color.rgb, smoothstep(0.0, 0.35, heat));
	col = mix(col, core_color.rgb, smoothstep(0.3, 0.8, max(heat, halo)));
	float flame_alpha = smoothstep(0.0, 0.4, heat) + halo * 0.6;
	// Beams show where the flame is thin, and blend toward ray_color there.
	col = mix(col, ray_color.rgb, clamp(rays / max(flame_alpha + rays, 0.001), 0.0, 1.0));
	float alpha = clamp(flame_alpha + rays, 0.0, 1.0) * edge_fade(p) * intensity;
	COLOR = vec4(col, alpha);
}
