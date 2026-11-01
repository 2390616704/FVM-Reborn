varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_time;
uniform float u_intensity;
uniform vec4 u_core;
uniform vec4 u_glow;
uniform vec4 u_edge;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void main() {
    float x = v_vTexcoord.x;
    float y = v_vTexcoord.y;
    float wob = sin(x * 18.0 + u_time * 3.0) * 0.012
              + sin(x * 7.0 - u_time * 1.7) * 0.020;
    float d = abs(y - 0.5 + wob);
    float core = 1.0 - smoothstep(0.03, 0.11, d);
    float glow = 1.0 - smoothstep(0.0, 0.52, d);
    float n = noise(vec2(x * 9.0 - u_time * 2.2, y * 5.0 + u_time * 0.6));
    float bands = 0.5 + 0.5 * sin(x * 46.0 - u_time * 7.0 + n * 5.0);
    float pulse = 0.75 + 0.25 * sin(x * 22.0 - u_time * 4.0 + n * 2.0);

    vec3 col = mix(u_glow.rgb, u_core.rgb, core);
    col = mix(col, u_edge.rgb, glow * (1.0 - core) * (0.40 + 0.60 * (1.0 - bands)));
    col *= pulse * (0.75 + 0.45 * u_intensity) * v_vColour.rgb;

    float taper = smoothstep(0.0, 0.04, x) * (1.0 - smoothstep(0.78, 1.0, x));
    float alpha = (core * 1.0 + glow * 0.65) * (0.65 + 0.35 * u_intensity) * v_vColour.a * taper;
    gl_FragColor = vec4(col, alpha);
}
