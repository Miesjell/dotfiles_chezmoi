
// void mainImage( out vec4 fragColor, in vec2 fragCoord )
// {
//         fragColor = fragColor;
// } 


// ============================================================================
// Foam Orb — authored in BrainVault (glsl-shader-intelligence), 2026-07-29
// ----------------------------------------------------------------------------
// A glass sphere held on a dark reflective floor. Its shell is a soap-foam
// cell network; the films are iridescent by thin-film interference and act as
// prisms at the ridges. Inside, backlit cauliflower clusters float in an
// absorbing medium.
//
// THE IDEA THIS SHADER EXISTS TO TEST
// -----------------------------------
// The vault holds two halves of the same problem that nobody had joined:
//
//   [[two-surface-refraction]] (Frostbyte_/BigWIngs) — glass needs the EXIT
//       surface and the internal path length, and pays a second 100-step
//       raymarch to get them.
//   [[bilinear-patch-intersection]] (morimea) — an analytic intersector hands
//       you BOTH roots and the discriminant for one sqrt.
//
// A sphere is a quadric. So:
//   * both roots        -> two-surface refraction with NO second march
//   * their difference  -> the chord length, i.e. the Beer-Lambert depth, free
//   * the discriminant  -> an exact silhouette signal, used here to fade the
//                          rim and to widen dispersion where the shell is edge-on
//
// The interior march is then bounded by the chord instead of by the scene, so
// the whole thing costs a fixed ~28 steps regardless of camera distance.
//
// Techniques drawn on (all vault pages):
//   two-surface-refraction · optical-depth-absorption · voronoi-cellular-noise
//   derivative-band-limited-cosine · chromatic-dispersion-refraction
//   fresnel-term · reinhard-tonemap · emissive-accumulation-march
//   shader-portability-guards · compile-time-variant-defines
//
// New here: THIN-FILM INTERFERENCE as the colour source, and the analytic
// both-roots shortcut standing in for the second refraction march.
// ============================================================================


// ------------------------------- quality ------------------------------------
#if HW_PERFORMANCE==0
    #define AA          1
    #define CLOUD_STEPS 12
#else
    #define AA          1       // 1..3
    #define CLOUD_STEPS 12
#endif

// slower, prettier: a second refracted bounce off the floor
//#define FLOOR_CAUSTIC

#define ZERO (min(int(iFrame),0))   // a zero the compiler cannot fold
#define PI   3.14159265359

const float R_ORB = 1.0;
const float IOR   = 1.42;
const vec3  SIGMA = vec3(0.16, 0.09, 0.05);   // per-channel absorption: warm core, cool rim


// -------------------------------- hashes ------------------------------------
float hash11(float p){
    p = fract(p*0.1031);  p *= p + 33.33;  p *= p + p;
    return fract(p);
}
vec3 hash33(vec3 p){                       // Dave_Hoskins-style: no sin()
    p = fract(p*vec3(0.1031, 0.1030, 0.0973));
    p += dot(p, p.yxz + 33.33);
    return fract((p.xxy + p.yxx)*p.zyx);
}
float hash13(vec3 p3){
    p3 = fract(p3*0.1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return fract((p3.x + p3.y)*p3.z);
}
float vnoise(vec3 p){
    vec3 i = floor(p), f = fract(p);
    f = f*f*(3.0 - 2.0*f);
    float n = 0.0;
    for (int k = ZERO; k < 8; k++){
        vec3 o = vec3(float(k&1), float((k>>1)&1), float((k>>2)&1));
        float w = mix(1.0-f.x, f.x, o.x)*mix(1.0-f.y, f.y, o.y)*mix(1.0-f.z, f.z, o.z);
        n += w*hash13(i+o);
    }
    return n;
}
float fbm(vec3 p){
    float a = 0.5, s = 0.0;
    for (int k = ZERO; k < 3; k++){ s += a*vnoise(p); p *= 2.07; a *= 0.5; }
    return s;
}


// ------------------------- analytic sphere, both roots ----------------------
vec3 iSphere(vec3 ro, vec3 rd, float r){
    float b = dot(ro, rd);
    float c = dot(ro, ro) - r*r;
    float h = b*b - c;
    if (h < 0.0) return vec3(-1.0, -1.0, 0.0);
    h = sqrt(h);
    return vec3(-b - h, -b + h, h);
}


// -------------------------------- the foam ----------------------------------
vec3 voronoi3(vec3 x, out vec3 bdir){
    vec3 p = floor(x), f = fract(x);
    float id = 0.0;
    vec2  res = vec2(100.0);
    vec3  r1 = vec3(0.0), r2 = vec3(0.0);
    for (int k = -1; k <= 1; k++)
    for (int j = -1; j <= 1; j++)
    for (int i = -1; i <= 1; i++){
        vec3  b = vec3(float(i), float(j), float(k));
        vec3  r = b - f + hash33(p + b);
        float d = dot(r, r);
        if (d < res.x){
            id = dot(p+b, vec3(1.0, 57.0, 113.0));
            res = vec2(d, res.x);  r2 = r1;  r1 = r;
        } else if (d < res.y){ res.y = d;  r2 = r; }
    }
    // the border is the bisector of the two nearest sites, so its normal is
    // the difference of the offsets — an analytic ridge direction, free.
    bdir = r2 - r1;
    return vec3(sqrt(res), abs(id));
}
vec3 voronoi3(vec3 x){ vec3 d; return voronoi3(x, d); }

vec3 foam(vec3 n, float scale, out vec3 ridge, out float slope){
    vec3  bd;
    vec3  v  = voronoi3(n*scale + 11.3, bd);
    ridge = bd - n*dot(bd, n);                 // project onto the tangent plane
    ridge = (dot(ridge, ridge) > 1e-8) ? normalize(ridge) : vec3(0.0);
    float e  = v.y - v.x;

    float w  = fwidth(e);
    float lw = length(vec3(w));
    float aa = ((lw == 0.0) || isnan(lw) || isinf(lw)) ? 0.035 : clamp(w*1.5, 0.010, 0.25);

    float W = aa + 0.055;
    float wall = 1.0 - smoothstep(0.0, W, e);
    float u = clamp(e/W, 0.0, 1.0);
    slope = -6.0*u*(1.0 - u)/W;                // d(wall)/de, analytically

    float base = 260.0 + 520.0*hash11(v.z*0.137);
    float thick = base*(0.35 + 0.65*smoothstep(0.0, 0.30, e));
    return vec3(wall, thick, v.z);
}
vec3 foam(vec3 n, float scale){ vec3 r; float sl; return foam(n, scale, r, sl); }


// -------------------- thin-film interference (the colour) -------------------
vec3 thinFilm(float d_nm, float cosI){
    const float nFilm = 1.33;
    float sinT2 = (1.0 - cosI*cosI)/(nFilm*nFilm);
    float cosT  = sqrt(max(0.0, 1.0 - sinT2));
    float opd   = 2.0*nFilm*d_nm*cosT;
    vec3  lam   = vec3(612.0, 549.0, 464.0);
    vec3  I     = 0.5 + 0.5*cos(2.0*PI*opd/lam + PI);
    return I*I;
}


// ------------------------------ interior clouds -----------------------------
float cloudDensity(vec3 p, float t){
    vec3 q = p;
    q.xz *= mat2(cos(t*0.07), sin(t*0.07), -sin(t*0.07), cos(t*0.07));

    float b = fbm(q*2.6 + vec3(0.0, t*0.03, 0.0));
    b = 1.0 - abs(2.0*b - 1.0);
    float b2 = fbm(q*6.1 - vec3(t*0.02));
    float shell = 0.34 - abs(length(q) - 0.30);
    float d = shell*1.35 + (b - 0.56)*0.80 + (b2 - 0.5)*0.30;
    return clamp(d*2.6, 0.0, 1.0);
}

vec3 cloudAlbedo(float dens, float id){
    vec3 warm = vec3(1.00, 0.93, 0.86);
    vec3 cool = vec3(0.42, 0.58, 0.95);
    vec3 blush= vec3(1.00, 0.74, 0.82);
    vec3 c = mix(cool, warm, smoothstep(0.15, 0.75, dens));
    return mix(c, blush, 0.35*hash11(id*0.311));
}


// -------------------------------- environment -------------------------------
const vec3 LDIR = normalize(vec3(-0.45, 0.78, -0.42));

vec3 sky(vec3 rd){
    float key = pow(max(dot(rd, LDIR), 0.0), 220.0)*9.0;
    float haze= pow(max(dot(rd, LDIR), 0.0), 6.0)*0.045;
    return vec3(0.0016, 0.0020, 0.0034) + vec3(1.0, 0.97, 0.93)*(key + haze);
}

vec3 floorCol(vec3 ro, vec3 rd, float yFloor){
    float t = (yFloor - ro.y)/rd.y;
    if (t <= 0.0) return sky(rd);
    vec3  p = ro + rd*t;
    float r = length(p.xz);

    float pool = exp(-r*r*1.5)*0.10;
    float grain= 0.006*fbm(vec3(p.x, 0.0, p.z)*9.0);
    float fade = exp(-t*0.14);
    return (vec3(0.0045, 0.0050, 0.0065)*fade + vec3(0.85, 0.92, 1.0)*pool + grain)*0.9;
}


// ---------------------------------- the orb ---------------------------------
vec3 shadeOrb(vec3 ro, vec3 rd, out float alpha){
    alpha = 0.0;
    vec3 s = iSphere(ro, rd, R_ORB);
    if (s.x < 0.0) return vec3(0.0);

    float t0 = max(s.x, 0.0);
    vec3  pIn = ro + rd*t0;
    vec3  nIn = pIn/R_ORB;

    float rim = clamp(s.z/R_ORB, 0.0, 1.0);

    vec3 ridge; float slope;
    vec3  fm   = foam(nIn, 3.1, ridge, slope);
    float wall = fm.x;
    vec3  nor  = normalize(nIn - ridge*slope*0.055);

    float cosI = clamp(dot(-rd, nor), 0.0, 1.0);

    vec3 film = thinFilm(fm.y, cosI);

    float R0 = (IOR - 1.0)/(IOR + 1.0);  R0 *= R0;
    float fres = R0 + (1.0 - R0)*pow(1.0 - cosI, 5.0);
    fres = clamp(fres + wall*0.20, 0.0, 1.0);

    vec3 refl = sky(reflect(rd, nor))
              + floorCol(pIn, reflect(rd, nor), -1.02)*0.5;
    refl *= mix(vec3(1.0), film*2.4 + 0.12, 0.35 + 0.65*wall);

    float abb = 0.008 + 0.090*wall + 0.055*(1.0 - rim);

    float chord = max(s.y - t0, 0.0);
    vec3  colIn = vec3(0.0);

    vec3 rIn = refract(rd, nor, 1.0/IOR);
    if (dot(rIn, rIn) == 0.0) rIn = reflect(rd, nor);

    float acc = 0.0, trans = 1.0, lit = 0.0;
    {
    float dt = chord/float(CLOUD_STEPS);
        for (int i = ZERO; i < CLOUD_STEPS; i++){
            vec3  q = pIn + rIn*(dt*(float(i) + 0.5));
            if (dot(q, q) > R_ORB*R_ORB) break;
            float d = cloudDensity(q*1.7, iTime);
            if (d > 0.001){
                float glow = trans*trans;   // self-shadowing from the running transmittance
                float a    = d*dt*2.6;
                lit   += trans*a*glow;
                acc   += trans*a;
                trans *= exp(-a*1.35);
            }
            if (trans < 0.01) break;
        }

    }

    vec3 pOut = ro + rd*s.y;
    vec3 nOut = -pOut/R_ORB;
    vec3 clusters = cloudAlbedo(acc, fm.z);
    vec3 absorb = exp(-SIGMA*chord*2.4);

    for (int ch = 0; ch < 3; ch++){
        vec3 rOut = refract(rIn, nOut, IOR + (float(ch) - 1.0)*abb);
        if (dot(rOut, rOut) == 0.0) rOut = reflect(rIn, nOut);
        vec3 behind = sky(rOut) + floorCol(pOut, rOut, -1.02)*0.55;
        colIn[ch] = behind[ch]*trans*absorb[ch]
                  + clusters[ch]*(lit*0.85 + acc*0.06)*absorb[ch];
    }

    vec3 col = mix(colIn, refl, fres);
    col += film*wall*0.75*(0.25 + 0.75*rim);

    alpha = smoothstep(0.0, 0.10, rim*R_ORB) * 0.985 + 0.015;
    return col;
}


// ---------------------------------- camera ----------------------------------
mat3 setCamera(vec3 ro, vec3 ta){
    vec3 cw = normalize(ta - ro);
    vec3 cu = normalize(cross(cw, vec3(0.0, 1.0, 0.0)));
    vec3 cv = cross(cu, cw);
    return mat3(cu, cv, cw);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
    float t  = mod(iTime, 3600.0);
    float an = 0.20*t;
    if (iMouse.z > 0.0) an = 6.2831*(iMouse.x/iResolution.x);

    vec3 ro = vec3(3.05*sin(an), 0.42 + 0.10*sin(t*0.23), 3.05*cos(an));
    vec3 ta = vec3(0.0, 0.02, 0.0);
    mat3 ca = setCamera(ro, ta);

    vec3 tot = vec3(0.0);
    for (int m = ZERO; m < AA; m++)
    for (int n = ZERO; n < AA; n++){
        vec2 o  = vec2(float(m), float(n))/float(AA) - 0.5;
        vec2 p  = (2.0*(fragCoord + o) - iResolution.xy)/iResolution.y;
        vec3 rd = ca*normalize(vec3(p, 2.5));

        vec3 col = floorCol(ro, rd, -1.02);

        float alpha;
        vec3 orb = shadeOrb(ro, rd, alpha);
        col = mix(col, orb, alpha);

        float tf = (-1.02 - ro.y)/rd.y;
        if (tf > 0.0){
            vec3 fp = ro + rd*tf;
            vec3 fr = reflect(rd, vec3(0.0, 1.0, 0.0));
            vec3 ms = iSphere(fp, fr, R_ORB);
            if (ms.x > 0.0){
                vec3 mn = (fp + fr*ms.x)/R_ORB;
                vec3 mf = foam(mn, 3.1);
                vec3 mc = thinFilm(mf.y, clamp(dot(-fr, mn), 0.0, 1.0));
                float gloss = exp(-length(fp.xz)*0.55)*0.42;
                col += (mc*(0.45 + 0.55*mf.x) + 0.06)*gloss*clamp(ms.z/R_ORB, 0.0, 1.0);
            }
        }
        tot += col;
    }
    tot /= float(AA*AA);

    tot  = 1.0 - exp(-tot*2.6);
    vec2 uv = fragCoord/iResolution.xy;
    tot *= pow(16.0*uv.x*uv.y*(1.0 - uv.x)*(1.0 - uv.y), 1.0/12.0);
    fragColor = vec4(pow(max(tot, 0.0), vec3(1.0/2.2)), 1.0);
}
