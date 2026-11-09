// Shared pieces for card glow shaders. Put  #include "card_common.gdshaderinc"
// under `shader_type canvas_item;` in each glow shader.

// CardView tweens this on hover: 0 = hidden, 1 = full.
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec2 card_size = vec2(110.0, 160.0); // card size in pixels
uniform float margin = 60.0;                 // how far the Glow rect reaches past the card
uniform float corner_radius = 8.0;

// Pixel position measured from the card's centre.
vec2 card_pos(vec2 uv) {
	return (uv - 0.5) * (card_size + 2.0 * margin);
}

// Distance from p to the card's rounded edge (negative = inside the card).
float card_dist(vec2 p) {
	vec2 q = abs(p) - card_size * 0.5 + corner_radius;
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - corner_radius;
}

// Fades to 0 near the Glow rect's border so effects never look cut off.
float edge_fade(vec2 p) {
	vec2 full = card_size + 2.0 * margin;
	float to_edge = min(full.x * 0.5 - abs(p.x), full.y * 0.5 - abs(p.y));
	return smoothstep(0.0, margin * 0.6, to_edge);
}

// Random number 0..1 for a grid cell. (No sin(): that version goes blocky on some GPUs.)
float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

// Smooth random noise 0..1.
float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
	           mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

// Layered noise: big shapes plus finer detail. Looks like smoke or fire.
float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * noise(p);
		p *= 2.0;
		a *= 0.5;
	}
	return v;
}
