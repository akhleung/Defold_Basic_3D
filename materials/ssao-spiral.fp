#version 420

in vec2 var_texcoord0;

uniform ssao_fp {
	mat4 mtx_proj;
	vec4 resolution;
};

uniform sampler2D color_sampler;
uniform sampler2D normal_sampler;
uniform sampler2D position_sampler;

out vec4 frag_color;

#define SAMPLES 16
#define INTENSITY 0.8
#define SCALE 1
#define BIAS 0.01
#define SAMPLE_RAD 0.05
#define MAX_DISTANCE 0.25

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
    float ao = max(0.0, dot(cnorm, normalize(diff)) - BIAS) * (1.0 / (1.0 + d));
    ao *= 1.0 - smoothstep(MAX_DISTANCE * 0.0, MAX_DISTANCE * 1.5, l);
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
