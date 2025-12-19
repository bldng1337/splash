shader_type canvas_item;

// Background shader that supports tiling (repeating) and offsetting the texture.
// Usage:
// - Set `tiling` to repeat the texture in X/Y (e.g. vec2(2.0, 2.0) doubles the tiles).
// - Set `offset` to shift the repeated texture (values are in UV space).
// - If your texture import wrap mode is not "Repeat", enable `use_fract` to force repetition in the shader.
//
// Note: It's usually best to enable "Repeat" on the texture import for better filtering,
// but `use_fract` provides a fallback.

uniform float tiling = 1.0;
uniform vec2 offset = vec2(0.0, 0.0);

// Center around which tiling scales (0..1). Default is (0.5, 0.5) -> center of UVs.
uniform vec2 center = vec2(0.5, 0.5);

// If true, the shader wraps UVs using fract(), which forces repetition even if the texture
// import wrap mode isn't set to REPEAT. If your texture uses REPEAT, set this false.
uniform bool use_fract = true;

void vertex() {
	// No per-vertex modification needed for this simple tiling shader,
	// but the function must exist if you want to extend it later.
}

void fragment() {
	// Compute UVs with tiling around the chosen center and apply offset.
	vec2 uv = (UV - center) * vec2(tiling,tiling) + center + offset;

	// Optionally force repeat by taking the fractional part of the UVs.
	if (use_fract) {
		uv = fract(uv);
	}

	// Sample the texture and multiply by the canvas item color (modulate).
	vec4 tex = texture(TEXTURE, uv);
	COLOR = tex;
}
