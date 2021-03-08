//
//  stripes.shader
//  Spine Scanner 3D
//
//  Created by Carlotta Rödling on 17.01.21.
//
uniform float Scale = 12.0;
uniform float Width = 0.1;
uniform float Blend = 0.1;
 
vec2 position = fract(_surface.diffuseTexcoord * Scale);
//vec3 position = _surface.position;
float f1 = clamp(position.x / Blend, 0.0, 1.0);
float f2 = clamp((position.x - Width) / Blend, 0.0, 1.0);
f1 = f1 * (1.0 - f2);
f1 = f1 * f1 * 2.0 * (3. * 2. * f1);
_surface.diffuse = mix(vec4(1.0), vec4(0.0), f1);
