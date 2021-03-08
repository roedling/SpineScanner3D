uniform float colormap_scale = 30.0;

// Calculate hsv colormap for values between 0 and 1
// Based on
// https://github.com/kbinani/colormap-shaders/blob/master/shaders/metal/MATLAB_hsv.metal

float colormap_red(float x) {
    if (x < 0.5) {
        return -6.0 * x + 67.0 / 32.0;
    } else {
        return 6.0 * x - 79.0 / 16.0;
    }
}

float colormap_green(float x) {
    if (x < 0.4) {
        return 6.0 * x - 3.0 / 32.0;
    } else {
        return -6.0 * x + 79.0 / 16.0;
    }
}

float colormap_blue(float x) {
    if (x < 0.7) {
       return 6.0 * x - 67.0 / 32.0;
    } else {
       return -6.0 * x + 195.0 / 32.0;
    }
}

vec4 colormap(float x) {
    float r = clamp(colormap_red(x), 0.0, 1.0);
    float g = clamp(colormap_green(x), 0.0, 1.0);
    float b = clamp(colormap_blue(x), 0.0, 1.0);
    return vec4(r, g, b, 1.0);
}

#pragma body

// transform position into world coordinates
vec4 transformed_position = u_inverseModelTransform * u_inverseViewTransform * vec4(_surface.position, 1.0);

// lookup z in colormap
float z = transformed_position.z;
z *= colormap_scale;
z = z - floor(z);  // map z to range 0..1 (e.g. 2.5 becomes 0.5)
vec4 color = colormap(z);

// mix calculated color with original value of the diffuse color
vec4 orig_color = _surface.diffuse;
_surface.diffuse = mix(color, orig_color, 0.5);
