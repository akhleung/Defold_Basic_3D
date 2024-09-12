#define MAX_LIGHTS 16

varying mediump vec4 var_position;
varying mediump vec3 var_normal;
varying mediump vec2 var_texcoord0;

uniform sampler2D diffuse_map;
uniform sampler2D normal_map;

uniform mediump mat4 mtx_view;
uniform mediump vec4 num_lights;
uniform mediump vec4 light_position[MAX_LIGHTS];
uniform mediump vec4 light_radii[MAX_LIGHTS];
uniform mediump vec4 light_color[MAX_LIGHTS];

mediump vec3 light_direction(mediump vec3 frag_pos, mediump vec3 light_pos) {
    return normalize(light_pos - frag_pos);
}

mediump float diffuse(mediump vec3 light_dir, mediump vec3 normal) {
    return max(dot(normal, light_dir), 0.0);
}

mediump float attenuation(mediump vec3 frag_pos, mediump vec3 light_pos, mediump vec4 light_radii) {
    lowp float r_inner = light_radii.x;
    lowp float r_outer = light_radii.y;
    lowp float d = distance(frag_pos, light_pos);
    // lowp float falloff = clamp((r_outer - d) / (r_outer - r_inner), 0.0, 1.0);
    lowp float falloff = 1.0 - smoothstep(r_inner, r_outer, d);
    return falloff * falloff;
}

void main() {
    mediump vec4 ambient_light = vec4(0.2, 0.2, 0.2, 1.0);
    mediump vec4 mat_diff = texture2D(diffuse_map, var_texcoord0);
    mediump vec4 mat_norm = texture2D(normal_map, var_texcoord0);
    mediump vec4 color = ambient_light * mat_diff;

    for (int i = 0; i < int(num_lights.x); ++i) {
        mediump vec4 light_pos = mtx_view * light_position[i];
        mediump vec3 light_dir = light_direction(var_position.xyz, light_pos.xyz);
        mediump float diff = diffuse(light_dir, var_normal);
        mediump float attn = attenuation(var_position.xyz, light_pos.xyz, light_radii[i]);
        color += diff * mat_diff * light_color[i] * attn;
    }

    color.a = mat_diff.a;

    gl_FragData[0] = clamp(color, 0.0, 1.0);
    gl_FragData[1] = vec4(var_normal, 1.0);
    gl_FragData[2] = var_position;
}
