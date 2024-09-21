#version 420

in vec2 var_texcoord0;

uniform sampler2D render_sampler;

out vec4 color_out;

void main() {
    // highp float d = texture2D(render_sampler, var_texcoord0.xy).r;
    // d = (1.0 - d) * 64.0;
	// d = (2.0 / d) * 2.5;
    // gl_FragColor = vec4(d, d, d, 1.0); // depth buffer visualization
	color_out = texture(render_sampler, var_texcoord0); // normal rendering
}
