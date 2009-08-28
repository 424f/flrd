namespace Floored.Shapes

import System
import OpenTK.Math
import OpenTK.Graphics

public class Vertex:
	public Position as Vector3
	public Normal as Vector3
	public Tangent as Vector3
	public TexCoord as Vector2
	
	public def Render():
		GL.Normal3(Normal)
		GL.MultiTexCoord3(TextureUnit.Texture1, Tangent)
		GL.Vertex3(Position)