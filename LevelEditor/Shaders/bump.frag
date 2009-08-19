uniform sampler2D Texture;
uniform sampler2D BumpTexture;
varying vec3 lightVec;
varying vec3 eyeVec;
varying vec3 nx;

void main()
{
	vec3 normal = 2.0 * texture2D(BumpTexture, gl_TexCoord[0].st).rgb - 1.0;
	//normal = vec3(0, 0, 1);

	vec3 lightDir = lightVec;
	//vec3 lightDir = normalize(vec3(gl_LightSource[0].position));
	//vec3 halfVector = normalize(lightDir - normalize(position.xyz));
	
	//vec3 n,halfV,viewV,ldir;
	//float NdotL,NdotHV;
	vec4 color = vec4(0, 0, 0, 1);
	
	vec3 n = normalize(normal);
	
	float NdotL = max(dot(n, lightDir), 0.0);
	vec4 diffuse = vec4(1.0, 1.0, 1.0, 1.0);
	
	if(NdotL > 0.0) {
		//halfV = normalize(halfVector);
		//NdotHV = max(dot(n,halfV),0.0);
		//color += gl_FrontMaterial.specular * gl_LightSource[0].specular * pow(NdotHV, gl_FrontMaterial.shininess);
		color += diffuse * NdotL;
	}
	
	vec4 texel = texture2D(Texture, vec2(gl_TexCoord[0]));
	gl_FragColor = vec4(color.rgb * texel.rgb, color.a * texel.a);	
	//gl_FragColor = vec4(nx, 1.0);
	
}
