// cracked_glass.glsl — Ghostty custom-shader
//
// A subtle "cracked glass" overlay for a semi-transparent terminal.
// Text stays readable: cracks are thin, refraction is small, and the
// crack lines are rendered bright so a bloom pass chained after this
// one will make them glow.
//
// Ghostty config (~/.config/ghostty/config):
//   background-opacity = 0.85
//   background-blur = 20
//   custom-shader = /path/to/cracked_glass.glsl
//   custom-shader = /path/to/bloom.glsl        // chain a bloom shader after this
//   custom-shader-animation = true
//
// Tunables are grouped right below — adjust to taste, nothing else
// needs to change.

// ---- tunables -------------------------------------------------------
#define CELL_SCALE      6.0    // crack density (higher = smaller shards)
#define CRACK_WIDTH     0.012  // thickness of the crack lines
#define CRACK_SOFTNESS  0.02   // edge falloff, keeps lines anti-aliased
#define REFRACT_STRENGTH 0.004 // how much text bends near a crack (keep small)
#define GLINT_SPEED     0.35   // how fast the light glint sweeps the cracks
#define GLINT_WIDTH     0.25   // width of the moving glint band
#define CRACK_BRIGHTNESS 1.8   // >1.0 so bloom has something to grab
#define BASE_TINT       vec3(0.85, 0.92, 1.0) // faint cool glass tint on cracks
#define VIGNETTE_STRENGTH 0.12 // subtle darkening at the corners, 0 to disable
// ----------------------------------------------------------------------

// Hash / value noise helpers for a jittered Voronoi (crack) field.
vec2 hash2(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453123) - 0.5;
}

// Returns: x = distance to nearest cell point, y = distance to 2nd nearest.
vec2 voronoi(vec2 p) {
    vec2 n = floor(p);
    vec2 f = fract(p);

    float f1 = 8.0;
    float f2 = 8.0;

    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 g = vec2(float(i), float(j));
            vec2 o = hash2(n + g) * 0.5; // jitter, kept mild so shards stay glass-like
            vec2 r = g + o - f;
            float d = dot(r, r);
            if (d < f1) { f2 = f1; f1 = d; }
            else if (d < f2) { f2 = d; }
        }
    }
    return vec2(sqrt(f1), sqrt(f2));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;

    // Keep cracks square regardless of window aspect ratio.
    vec2 aspectUV = uv;
    aspectUV.x *= iResolution.x / iResolution.y;

    vec2 cellUV = aspectUV * CELL_SCALE;
    vec2 vf = voronoi(cellUV);

    // Distance to the crack line = gap between nearest and 2nd-nearest point.
    float edgeDist = vf.y - vf.x;
    float crack = 1.0 - smoothstep(CRACK_WIDTH, CRACK_WIDTH + CRACK_SOFTNESS, edgeDist);

    // Approximate the crack's local direction via a tiny finite-difference
    // gradient, then push the sample sideways across it. That's what makes
    // the terminal content look like it is bending through glass at the seam.
    vec2 epsX = vec2(1.0 / iResolution.x, 0.0);
    vec2 epsY = vec2(0.0, 1.0 / iResolution.y);
    vec2 vfX = voronoi((aspectUV + epsX) * CELL_SCALE);
    vec2 vfY = voronoi((aspectUV + epsY) * CELL_SCALE);
    float dEdge_dx = (vfX.y - vfX.x) - edgeDist;
    float dEdge_dy = (vfY.y - vfY.x) - edgeDist;
    vec2 gradDir = normalize(vec2(dEdge_dx, dEdge_dy) + 1e-5);

    vec2 refractOffset = gradDir * crack * REFRACT_STRENGTH;

    // Sample the actual terminal contents (with the tiny refraction offset).
    vec4 base = texture(iChannel0, uv + refractOffset);

    // A soft moving glint so bloom has motion to catch, without redrawing
    // the whole crack pattern every frame (the shard layout stays fixed).
    float glintPos = fract(iTime * GLINT_SPEED);
    float glintBand = 1.0 - smoothstep(0.0, GLINT_WIDTH, abs(fract(uv.x + uv.y - glintPos)));
    float glint = crack * glintBand;

    vec3 crackColor = BASE_TINT * CRACK_BRIGHTNESS;
    vec3 color = mix(base.rgb, crackColor, crack * 0.55);
    color += crackColor * glint * 0.6;

    // Faint vignette to sell the "pane of glass" edges.
    vec2 centered = uv * 2.0 - 1.0;
    float vig = 1.0 - VIGNETTE_STRENGTH * dot(centered, centered);
    color *= vig;

    // Keep original alpha so background transparency/blur still works;
    // let crack lines nudge alpha up slightly so they read against a
    // see-through background too.
    float alpha = clamp(base.a + crack * 0.15, 0.0, 1.0);

    fragColor = vec4(color, alpha);
}
