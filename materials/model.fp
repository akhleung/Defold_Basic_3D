#version 420

#define MAX_LIGHTS 16

in vec4 var_position;
in vec3 var_normal;
in vec2 var_texcoord0;

uniform sampler2D diffuse_map;
uniform sampler2D normal_map;

uniform model_fp {
    mat4 mtx_view;
    vec4 num_lights;
    vec4 light_position[MAX_LIGHTS];
    vec4 light_radii[MAX_LIGHTS];
    vec4 light_color[MAX_LIGHTS];
};

out vec4 fragColor;

vec3 light_direction(vec3 frag_pos, vec3 light_pos) {
    return normalize(light_pos - frag_pos);
}

float diffuse(vec3 light_dir, vec3 normal) {
    return max(dot(normal, light_dir), 0.0);
}

float attenuation(vec3 frag_pos, vec3 light_pos, vec4 light_radii) {
    lowp float r_inner = light_radii.x;
    lowp float r_outer = light_radii.y;
    lowp float d = distance(frag_pos, light_pos);
    // lowp float falloff = clamp((r_outer - d) / (r_outer - r_inner), 0.0, 1.0);
    lowp float falloff = 1.0 - smoothstep(r_inner, r_outer, d);
    return falloff * falloff;
}

void main() {
    vec4 ambient_light = vec4(0.2, 0.2, 0.2, 1.0);
    vec4 mat_diff = texture(diffuse_map, var_texcoord0);
    vec4 mat_norm = texture(normal_map, var_texcoord0);
    vec4 color = ambient_light * mat_diff;

    for (int i = 0; i < num_lights.x; ++i) {
        vec4 light_pos = mtx_view * light_position[i];
        vec3 light_dir = light_direction(var_position.xyz, light_pos.xyz);
        float diff = diffuse(light_dir, var_normal);
        float attn = attenuation(var_position.xyz, light_pos.xyz, light_radii[i]);
        color += diff * mat_diff * light_color[i] * attn;
    }

    color.a = mat_diff.a;

    fragColor = clamp(color, 0.0, 1.0);
}
