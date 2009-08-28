namespace Floored.Shapes

import System
import OpenTK.Graphics
import OpenTK.Math

public class Triangle:

	public V0 as Vertex

	public V1 as Vertex

	public V2 as Vertex

	public TexCoord0 as Vector2

	public TexCoord1 as Vector2

	public TexCoord2 as Vector2

	
	public def constructor(v0 as Vertex, v1 as Vertex, v2 as Vertex, texCoord0 as Vector2, texCoord1 as Vector2, texCoord2 as Vector2):
		self(v0, v1, v2)
		TexCoord0 = texCoord0
		TexCoord1 = texCoord1
		TexCoord2 = texCoord2

	
	public def constructor(v0 as Vertex, v1 as Vertex, v2 as Vertex):
		V0 = v0
		V1 = v1
		V2 = v2

	
	public def Render():
		GL.TexCoord2(TexCoord0)
		V0.Render()
		GL.TexCoord2(TexCoord1)
		V1.Render()
		GL.TexCoord2(TexCoord2)
		V2.Render()