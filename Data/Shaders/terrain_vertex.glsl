varying vec4 diffuse,ambient;
varying vec3 normal;
varying vec4 position;
varying float fogFactor;

void main()
{	
	normal = normalize(gl_NormalMatrix * gl_Normal);
	
	diffuse = gl_FrontMaterial.diffuse * gl_LightSource[0].diffuse;
	ambient = gl_FrontMaterial.ambient * gl_LightSource[0].ambient;
	ambient += gl_LightModel.ambient * gl_FrontMaterial.ambient;
	
	
	gl_Position = ftransform();
	position = gl_ModelViewMatrix * gl_Vertex;
	
	gl_TexCoord[0]  = gl_MultiTexCoord0;
	gl_FrontColor = gl_Color;
	gl_ClipVertex = gl_ModelViewMatrix * gl_Vertex; // Is this bad? (http://hacksoflife.blogspot.com/2008/10/user-clip-planes-and-glsl.html)

	const float LOG2 = 1.442695;
	gl_FogFragCoord = length(vec3(position) / 400.0);
	fogFactor = exp2( -gl_Fog.density * 
					   gl_Fog.density * 
					   gl_FogFragCoord * 
					   gl_FogFragCoord * 
					   LOG2 );
	fogFactor = clamp(fogFactor, 0.0, 1.0);
	
} 
