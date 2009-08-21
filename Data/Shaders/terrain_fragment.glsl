uniform sampler2D Grass;
uniform sampler2D Stone;
uniform sampler2D Rock;


varying vec4 diffuse,ambient;
varying vec3 normal;
varying vec4 position;
varying float fogFactor;

void main()
{
	vec3 lightDir = normalize(vec3(gl_LightSource[0].position));
	vec3 halfVector = normalize(lightDir - normalize(position.xyz)); //normalize(gl_LightSource[0].halfVector.xyz);
	
	vec3 n,halfV,viewV,ldir;
	float NdotL,NdotHV;
	vec4 color = ambient;
	
	/* a fragment shader can't write a verying variable, hence we need
	a new variable to store the normalized interpolated normal */
	n = normalize(normal);
	
	/* compute the dot product between normal and ldir */
	NdotL = max(dot(n,lightDir),0.0);

	if (NdotL > 0.0 && gl_Color.a > 0.0) {
		halfV = normalize(halfVector);
		NdotHV = max(dot(n,halfV),0.0);
		color += gl_Color.a * gl_FrontMaterial.specular * gl_LightSource[0].specular * pow(NdotHV, gl_FrontMaterial.shininess);
		color += gl_Color.a * diffuse * NdotL;
	}

   vec3 dist = vec3(gl_Color.r, gl_Color.g, gl_Color.b);	
   vec3 clrs = gl_Color.rgba / (gl_Color.r + gl_Color.g + gl_Color.b);
   vec4 texel = vec4(0, 0, 0, 1);
   
   if(clrs.r > 0.0)
     texel += texture2D(Grass, vec2(gl_TexCoord[0])/6.0)*clrs.r; // Tile
   if(clrs.g > 0.0)
     texel += texture2D(Rock,  vec2(gl_TexCoord[0])/6.0)*clrs.g; // Tile
   if(clrs.b > 0.0)
     texel += texture2D(Stone, vec2(gl_TexCoord[0])/6.0)*clrs.b; // Tile
	
   //gl_FragColor = vec4(color.rgb * texel.rgb, texel.a * color.a);	
   gl_FragColor = mix(gl_Fog.color, vec4(color.rgb * texel.rgb, 1.0), fogFactor);
   //gl_FragColor = vec4(fogFactor, fogFactor, fogFactor, 1);
   //gl_FragColor = vec4(gl_Color);

}
