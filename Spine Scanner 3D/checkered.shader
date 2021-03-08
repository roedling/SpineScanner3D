
// show a mesh of checkered lines on the body
// the lines are aligned to the x and y axis of the world

uniform float checkered_scale = 40.0; // frequence of stripes
uniform float checkerd_size = 0.1; // size of stripes

#pragma body

// transform position into world coordinates
vec4 transformed_position = u_inverseModelTransform * u_inverseViewTransform * vec4(_surface.position, 1.0);

// lookup z in colormap
float x = transformed_position.x*checkered_scale;
float y = transformed_position.y*checkered_scale;

x -= floor(x);
y -= floor(y);

if (x < checkerd_size || y < checkerd_size) {
    _surface.diffuse =vec4(0.0, 0.0, 0.0, 1.0);  // black lines
}
