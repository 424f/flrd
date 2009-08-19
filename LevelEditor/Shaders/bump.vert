varying vec3 lightVec;
varying vec3 eyeVec;
varying vec3 nx;

void main()
{
	vec3 vertexPosition = vec3(gl_ModelViewMatrix * gl_Vertex);
	vec3 lightDir = normalize(gl_LightSource[0].position.xyz - vertexPosition);

	// Light from eye to tangent space
	vec3 tangent = vec3(0, 0, 1); //vec3(gl_MultiTexCoord1);
	vec3 n = normalize(gl_NormalMatrix * gl_Normal);
	vec3 t = normalize(gl_NormalMatrix * tangent);
	vec3 b = cross(n, t);
	nx = n;
	
	// transform vectors
	vec3 v;
	v.x = dot(lightDir, t);
	v.y = dot(lightDir, b);
	v.z = dot(lightDir, n);
	lightVec = normalize(v);
	
	v.x = dot(vertexPosition, t);
	v.y = dot(vertexPosition, b);
	v.z = dot(vertexPosition, n);
	eyeVec = normalize(v);


	gl_TexCoord[0]  = gl_MultiTexCoord0;
	gl_TexCoord[1]  = gl_MultiTexCoord1;
	gl_Position = ftransform();
} 
