#version 420 core

in vec2 var_texcoord0;

uniform sampler2D normal_sampler;
uniform sampler2D position_sampler;

out vec4 frag_color;

#define SAMPLES 16
#define INTENSITY 1.5
#define SCALE 1
#define BIAS 0.01
#define SAMPLE_RAD 0.2
#define MAX_DISTANCE 0.5

const vec3 mod3 = vec3(.1031, .11369, .13787);
const float goldenAngle = 2.4;
const float inv = 1.0 / float(SAMPLES);

float hash12(vec2 p) {
	vec3 p3  = fract(vec3(p.xyx) * mod3);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

float doAmbientOcclusion(in vec3 op, in vec3 p, in vec3 cnorm) {
    vec3 diff = op - p;
    float l = length(diff);
    float d = l * SCALE;
    float f = dot(cnorm, normalize(diff));
    f = smoothstep(0.15, 1.0, f); // discard oblique occluders to prevent self-occlusion artifacts on flat surfaces caused by precision errors
    float ao = max(0.0, f - BIAS) /* * (1.0 / (1.0 + d))*/;
    // float ao = max(0.0, dot(cnorm, normalize(diff)) - BIAS) * (1.0 / (1.0 + d));
    ao *= 1.0 - smoothstep(MAX_DISTANCE * 0.5, MAX_DISTANCE, l); // increasing the upper bound seems to allow AO to persist at very oblique angles
    return ao;
}

float spiralAO(vec3 p, vec3 n, float rad) {
    float ao = 0.0;
    float radius = 0.0;

    float rotatePhase = hash12(var_texcoord0 * 100.0) * 6.28;
    float rStep = inv * rad;
    vec2 spiralUV;

    for (int i = 0; i < SAMPLES; i++) {
        spiralUV.x = sin(rotatePhase);
        spiralUV.y = cos(rotatePhase);
        radius += rStep;
		vec3 offset_pos = texture(position_sampler, var_texcoord0 + spiralUV * radius).xyz;
        ao += doAmbientOcclusion(offset_pos, p, n);
        rotatePhase += goldenAngle;
    }
    ao *= inv;
    return ao;
}

void main() {

	vec3 position = texture(position_sampler, var_texcoord0).xyz;
  	vec3 normal   = texture(normal_sampler, var_texcoord0).xyz;

	float ao = 0.0;
	float rad = SAMPLE_RAD / abs(position.z);

	ao = spiralAO(position, normal, rad);
	ao = 1.0 - ao * INTENSITY;

	frag_color = vec4(ao, ao, ao, 1.0);
}
