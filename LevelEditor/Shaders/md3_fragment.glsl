varying vec4 diffuse,ambient;
varying vec3 normal;
uniform sampler2D tex;
varying vec4 position;

void main(void)
{
	vec3 lightDir = normalize(vec3(gl_LightSource[0].position));
	vec3 halfVector = normalize(lightDir - normalize(position.xyz));
	
	vec3 n,halfV,viewV,ldir;
	float NdotL,NdotHV;
	vec4 color = ambient;
	
	/* a fragment shader can't write a verying variable, hence we need
	a new variable to store the normalized interpolated normal */
	n = normalize(normal);
	
	/* compute the dot product between normal and ldir */
	NdotL = max(dot(n,lightDir),0.0);

	if (NdotL > 0.0) {
		halfV = normalize(halfVector);
		NdotHV = max(dot(n,halfV),0.0);
		color += gl_FrontMaterial.specular * gl_LightSource[0].specular * pow(NdotHV, gl_FrontMaterial.shininess);
		color += diffuse * NdotL;
	}
	
   vec4 texel = texture2D(tex, vec2(gl_TexCoord[0]));
   gl_FragColor = vec4(texel.rgb * color.rgb, texel.a * color.a);
}