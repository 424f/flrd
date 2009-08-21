varying vec3 lightVec;
varying vec3 eyeVec;
varying vec4 diffuse, ambient;
varying vec3 halfVec;
varying vec3 distance;

void main()
{
	diffuse = gl_FrontMaterial.diffuse * gl_LightSource[0].diffuse;
	ambient = gl_FrontMaterial.ambient * gl_LightSource[0].ambient;

	vec3 vertexPosition = vec3(gl_ModelViewMatrix * gl_Vertex);
	vec3 lightDir = normalize(gl_LightSource[0].position.xyz - vertexPosition);

	distance = gl_LightSource[0].position.xyz - vertexPosition;
	
	// Light from eye to tangent space
	vec3 tangent = vec3(gl_MultiTexCoord1);
	vec3 n = normalize(gl_NormalMatrix * gl_Normal);
	vec3 t = normalize(gl_NormalMatrix * tangent);
	vec3 b = cross(n, t);
	
	// transform vectors
	vec3 v;
	v.x = dot(lightDir, t);
	v.y = dot(lightDir, b);
	v.z = dot(lightDir, n);
	lightVec = v;
	
	v.x = dot(vertexPosition, t);
	v.y = dot(vertexPosition, b);
	v.z = dot(vertexPosition, n);
	eyeVec = v;

	vertexPosition = normalize(vertexPosition);
	vec3 halfVector = normalize((vertexPosition + lightDir) / 2.0);
	v.x = dot (halfVector, t);
	v.y = dot (halfVector, b);
	v.z = dot (halfVector, n);
	halfVec = v;
	
	

	gl_TexCoord[0]  = gl_MultiTexCoord0;
	gl_TexCoord[1]  = gl_MultiTexCoord1;
	gl_Position = ftransform();
	gl_FrontColor = gl_Color;
} 
