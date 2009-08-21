uniform sampler2D DiffuseTexture;
uniform sampler2D NormalTexture;
varying vec3 lightVec;
varying vec3 halfVec;
varying vec3 eyeVec;
varying vec4 diffuse, ambient;
varying vec3 distance;

void main()
{
	vec3 normal = 2.0 * texture2D(NormalTexture, gl_TexCoord[0].st).rgb - 1.0;
	//normal = vec3(0, 0, 1);
	vec4 color = vec4(0, 0, 0, 1); //ambient;
	
	vec3 n = normalize(normal);
	
	lightVec = normalize(lightVec);
	
	float NdotL = max(dot(n, lightVec), 0.0);
	
	float ld = length(distance);
	float f = 1.0 - ld * ld / 2500.0;
	
	if(NdotL > 0.0) {
		vec3 halfV = normalize(halfVec);
		float NdotHV = max(dot(n,halfV),0.0);
		color += f * gl_FrontMaterial.specular * gl_LightSource[0].specular * pow(NdotHV, gl_FrontMaterial.shininess);
		color += f * diffuse * NdotL;
	}
	
	vec4 texel = texture2D(DiffuseTexture, vec2(gl_TexCoord[0]));
	//texel = vec4(1, 1, 1, 1);
	
	color = vec4(color.rgb * gl_Color.rgb, color.a * gl_Color.a);
	gl_FragColor = vec4(color.rgb * texel.rgb, texel.a);	
	//gl_FragColor = vec4(NdotL, NdotL, NdotL, 1.0);
	//gl_FragColor = vec4(lightVec, 1.0);
	
}
