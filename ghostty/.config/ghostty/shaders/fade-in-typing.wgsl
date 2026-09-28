
// Fade-in by line shader in ShaderToy format
// Each row fades in based on time and Y position

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  // Normalized screen coordinates (0 - 1)
  vec2 uv = fragCoord.xy / iResolution.xy;

  // Get the base color from the input channel (glyph texture)
  vec4 color = texture(iChannel0, uv);

  // Simulate "row" by mapping Y to line index
  float rows = 40.0; // total number of virtual terminal rows
  float rowIndex = floor(uv.y * rows);

  // Time offset per row (makes each row appear later)
  float delayPerRow = 0.01; // seconds between row fade-ins

  // Calculate time threshold for this row
  float threshold = rowIndex * delayPerRow;

  // Fade factor: smoothstep(time, time + fade duration, current time)
  float fadeDuration = 0.4; // seconds to fully fade in
  float fade = smoothstep(threshold, threshold + fadeDuration, iTime);

  // Apply fade to alpha (or optionally to RGB too)
  fragColor = vec4(color.rgb * fade, color.a * fade);
}

