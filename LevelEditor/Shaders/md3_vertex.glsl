varying vec4 diffuse,ambient;
varying vec3 normal;
varying vec4 position;
			
void main()
{
    gl_TexCoord[0]  = gl_MultiTexCoord0;
    normal = normalize(gl_NormalMatrix * gl_Normal);

	diffuse = gl_FrontMaterial.diffuse * gl_LightSource[0].diffuse;
	ambient = gl_FrontMaterial.ambient * gl_LightSource[0].ambient;
	ambient += gl_LightModel.ambient * gl_FrontMaterial.ambient;	
	
	position = gl_ModelViewMatrix * gl_Vertex;
	
    gl_Position = ftransform();
    gl_FrontColor = gl_Color;
    gl_ClipVertex = gl_ModelViewMatrix * gl_Vertex; // Is this bad? (http://hacksoflife.blogspot.com/2008/10/user-clip-planes-and-glsl.html)
}