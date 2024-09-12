#version 140

in mediump vec2 var_texcoord0;

uniform ssao_fp {
	mediump mat4 mtx_proj;
	highp vec4 kernel[64];
	highp vec4 noise[16];
};

uniform highp sampler2D color_sampler;
uniform highp sampler2D normal_sampler;
uniform highp sampler2D position_sampler;

lowp float radius    = 1.0;
lowp float bias      = 0.01;
lowp float magnitude = 1.5;
lowp float contrast  = 1.5;

// out vec4 frag_out;

#define MOD3 vec3(.1031,.11369,.13787)

float hash12(vec2 p) {
	vec3 p3  = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

vec2 hash22(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3, p3.yzx+19.19);
    return fract(vec2((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y));
}

mediump float doAmbientOcclusion(mediump vec3 spos, mediump vec3 pos, mediump vec3 norm){
   vec3 diff = spos - pos;
   vec3 v = normalize(diff);
   float d = length(diff);

   return max(0.0, dot(norm, v) - bias) * ( 1.0/(1.0 + d) ) * contrast;
}

vec2 reflection(in vec2 v1,in vec2 v2){
    vec2 result= 2.0 * dot(v2, v1) * v2;
    result = v1-result;
    return result;
}

void main() {

	mediump vec3 position = texture(position_sampler, var_texcoord0).xyz;
  	mediump vec3 normal   = texture(normal_sampler, var_texcoord0).xyz;

  	int  noiseX = int(gl_FragCoord.x - 0.5) % 4;
  	int  noiseY = int(gl_FragCoord.y - 0.5) % 4;
  	highp vec3 random = noise[noiseX * 4 + noiseY * 4].xyz;

	vec3 tangent  = normalize(random - normal * dot(random, normal));
  	vec3 binormal = cross(normal, tangent);
  	mat3 tbn      = mat3(tangent, binormal, normal);

	float occlusion = 0.0;

  	for (int i = 0; i < 64; ++i) {
    	vec3 samplePosition = tbn * kernel[i].xyz;
        samplePosition = position + samplePosition * radius;

		occlusion += doAmbientOcclusion(samplePosition, position, normal);

		// vec4 offset = vec4(samplePosition, 1.0);
        // offset      = mtx_proj * offset;
        // offset.xyz /= offset.w;
        // offset.xyz  = offset.xyz * 0.5 + 0.5;

		// vec4 offsetPosition = texture2D(position_sampler, offset.xy);
		// mediump float depth = offsetPosition.z;
		// mediump float intensity = smoothstep(0.0, 1.0, radius / abs(position.z - depth));
		// occlusion += (depth >= samplePosition.z + bias ? 1.0 : 0.0) * intensity;
  	}

	occlusion = 1.0 - (occlusion / 64.0);
	gl_FragColor = vec4(vec3(occlusion), 1.0);

	// gl_FragColor = vec4(position, 1.0);

	// frag_out = vec4(vec3(occlusion), 1.0);

	// highp float d = texture2D(position_sampler, var_texcoord0).z;
	// gl_FragData[0] = vec4(d, d, d, 1.0);
}
