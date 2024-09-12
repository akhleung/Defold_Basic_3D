varying mediump vec2 var_texcoord0;

uniform highp sampler2D render_sampler;

void main() {
    // highp float d = texture2D(render_sampler, var_texcoord0.xy).r;
    // d = (1.0 - d) * 64.0;
	// d = (2.0 / d) * 2.5;
    // gl_FragColor = vec4(d, d, d, 1.0); // depth buffer visualization
	gl_FragColor = texture2D(render_sampler, var_texcoord0); // normal rendering
}
