// Natural blurred fullscreen grain for Ghostty
// Adds randomized, soft paper grain over entire terminal

float grainStrength = 0.10; // Adjust grain visibility
int blurRadius = 1;         // How blurry: 1 = 3x3, 2 = 5x5

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(91.3458, 472.5543))) * 12345.6789);
}

// Blurred version of the noise
float blurredRandom(vec2 uv) {
    float total = 0.0;
    int count = 0;

    for (int x = -blurRadius; x <= blurRadius; x++) {
        for (int y = -blurRadius; y <= blurRadius; y++) {
            vec2 offset = vec2(x, y) / iResolution.xy;
            total += random(uv + offset);
            count++;
        }
    }

    return total / float(count);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;

    // Terminal content
    vec3 baseColor = texture(iChannel0, uv).rgb;

    float g = blurredRandom(uv);
    baseColor += (g - 0.5) * grainStrength;

    fragColor = vec4(baseColor, 1.0);
}

