// Cursor trail (smear/blaze) shader for Ghostty.
//
// Based on cursor_blaze by hackr-sh/ghostty-shaders, which in turn is based on
// https://gist.github.com/chardskarth/95874c54e29da6b5a36ab7b50ae2d088
//
// Drawn as a comet: a bright leading edge fading into a translucent tail with a
// soft glow. The color comes from `iCurrentCursorColor`, so it follows the
// `cursor-color` set in the config.

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b)
{
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}
// Based on Inigo Quilez's 2D distance functions article: https://iquilezles.org/articles/distfunctions2d/
// Potencially optimized by eliminating conditionals and loops to enhance performance and reduce branching
float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfParallelogram(in vec2 p, in vec2 v0, in vec2 v1, in vec2 v2, in vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);

    d = seg(p, v0, v3, s, d);
    d = seg(p, v1, v0, s, d);
    d = seg(p, v2, v1, s, d);
    d = seg(p, v3, v2, s, d);

    return s * sqrt(d);
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float blend(float t)
{
    float sqr = t * t;
    return sqr / (2.0 * (sqr - t) + 1.0);
}

float antialising(float distance) {
    return 1. - smoothstep(0., normalize(vec2(2., 2.), 0.).x, distance);
}

float determineStartVertexFactor(vec2 a, vec2 b) {
    // Conditions using step
    float condition1 = step(b.x, a.x) * step(a.y, b.y); // a.x < b.x && a.y > b.y
    float condition2 = step(a.x, b.x) * step(b.y, a.y); // a.x > b.x && a.y < b.y

    // If neither condition is met, return 1 (else case)
    return 1.0 - max(condition1, condition2);
}
vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}

// --- Tunables ---------------------------------------------------------------

// How long the trail lingers (seconds). Lower = snappier, higher = longer.
const float DURATION = 0.2;
// Peak opacity of the smear body. Under 1.0 so text shows through.
const float TRAIL_OPACITY = 0.72;
// Soft halo around the smear. Sizes are in normalized units (screen height = 2).
const float GLOW_SIZE = 0.02;
const float GLOW_OPACITY = 0.30;
// Head-to-tail falloff. Higher = shorter, punchier comet; lower = even fade.
const float TAPER = 1.7;
// How hard the leading edge is tinted away from the background (0-1).
const float HEAD_CONTRAST = 0.35;
// Don't draw a trail within this distance * cursor size. Prevents smears while
// typing normally; only larger jumps leave a trail.
const float DRAW_THRESHOLD = 1.5;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float bgLuma = 0.0;
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    // The corner is window padding, so it stands in for the background color.
    vec3 bg = texture(iChannel0, vec2(1.0) / iResolution.xy).rgb;
    bgLuma = dot(bg, vec3(0.2126, 0.7152, 0.0722));
    #endif

    // Tint the head away from the background: toward white on a dark theme,
    // toward black on a light one, so it stands out against the tail.
    vec3 trailColor = iCurrentCursorColor.rgb;
    vec3 contrastTint = mix(vec3(1.0), vec3(0.0), step(0.5, bgLuma));
    vec3 headColor = mix(trailColor, contrastTint, HEAD_CONTRAST);

    //Normalization for fragCoord to a space of -1 to 1;
    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);

    //Normalization for cursor position and size;
    //cursor xy has the postion in a space of -1 to 1;
    //zw has the width and height
    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));

    //When drawing a parellelogram between cursors for the trail i need to determine where to start at the top-left or top-right vertex of the cursor
    float vertexFactor = determineStartVertexFactor(currentCursor.xy, previousCursor.xy);
    float invertedVertexFactor = 1.0 - vertexFactor;

    //Set every vertex of my parellogram
    vec2 v0 = vec2(currentCursor.x + currentCursor.z * vertexFactor, currentCursor.y - currentCursor.w);
    vec2 v1 = vec2(currentCursor.x + currentCursor.z * invertedVertexFactor, currentCursor.y);
    vec2 v2 = vec2(previousCursor.x + currentCursor.z * invertedVertexFactor, previousCursor.y);
    vec2 v3 = vec2(previousCursor.x + currentCursor.z * vertexFactor, previousCursor.y - previousCursor.w);

    // The trail retracts toward the cursor while `envelope` fades what's left.
    float progress = blend(clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0));
    float retract = 1.0 - progress;
    float envelope = pow(retract, 0.7);

    //Distance between cursors determine the total length of the parallelogram;
    vec2 centerCC = getRectangleCenter(currentCursor);
    vec2 centerCP = getRectangleCenter(previousCursor);
    float cursorSize = max(currentCursor.z, currentCursor.w);
    float trailThreshold = DRAW_THRESHOLD * cursorSize;
    float lineLength = distance(centerCC, centerCP);
    //
    bool isFarEnough = lineLength > trailThreshold;
    if (isFarEnough && retract > 0.0) {
        // 0 at the cursor, 1 at the far end of what is still drawn.
        float span = max(lineLength * retract, 1e-4);
        float along = clamp(distance(vu, centerCC) / span, 0.0, 1.0);
        float alpha = pow(1.0 - along, TAPER) * envelope;

        vec3 color = mix(headColor, trailColor, smoothstep(0.0, 0.55, along));

        float sdfCursor = getSdfRectangle(vu, currentCursor.xy - (currentCursor.zw * offsetFactor), currentCursor.zw * 0.5);
        float sdfTrail = getSdfParallelogram(vu, v0, v1, v2, v3);

        float core = antialising(sdfTrail);
        // (1 - core) keeps the halo outside the body so the two don't stack.
        float glow = exp(-max(sdfTrail, 0.0) / GLOW_SIZE) * (1.0 - core);

        vec4 newColor = fragColor;
        newColor.rgb = mix(newColor.rgb, color, glow * GLOW_OPACITY * alpha);
        newColor.rgb = mix(newColor.rgb, color, core * TRAIL_OPACITY * alpha);

        fragColor = mix(newColor, fragColor, step(sdfCursor, 0.0));
    }
}
