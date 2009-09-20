namespace Floored.Shapes

import System
import OpenTK.Graphics
import OpenTK.Math
import Box2DX.Collision

public class Box(TriangleMesh):	
	public IsStatic = true
	public OnGameLayer = true
	public TextureSpan as single:
		get:
			return _TextureSpan
		set:
			_TextureSpan = value
			IsDirty = true

	private _TextureSpan as single

	
	[Property(Dim)] _Dim as Vector3
	
	public displayList = 0

	protected IsDirty = true
	
	private def CreateQuad(ref i as int, i0 as int, i1 as int, i2 as int, i3 as int, tu as single, tv as single):
		Triangles[(i++)] = Triangle(Vertices[i0], Vertices[i1], Vertices[i2], Vector2(0.0F, 0.0F), Vector2(tu, 0.0F), Vector2(tu, tv))
		Triangles[(i++)] = Triangle(Vertices[i0], Vertices[i2], Vertices[i3], Vector2(0.0F, 0.0F), Vector2(tu, tv), Vector2(0.0F, tv))
	
	private def CreateMesh():
		Triangles = array(Triangle, 12)
		Vertices = array(Vertex, 24)
		
		// Create all vertices
		i = 0
		for j in range(0, 3):
			for x as single in (of single: Dim.X, (-Dim.X)):
				for y as single in (of single: Dim.Y, (-Dim.Y)):
					for z as single in (of single: Dim.Z, (-Dim.Z)):
						v = Vertex()
						v.Position = Vector3(x, y, z)
						Vertices[(i++)] = v
		
		// Create all triangles
		i = 0
		CreateQuad(i, 0, 4, 6, 2, (Dim.X / TextureSpan), (Dim.Y / TextureSpan))
		CreateQuad(i, 3, 7, 5, 1, (Dim.X / TextureSpan), (Dim.Y / TextureSpan))
		CreateQuad(i, (4 + 8), (5 + 8), (7 + 8), (6 + 8), (Dim.Z / TextureSpan), (Dim.Y / TextureSpan))
		CreateQuad(i, (1 + 8), (0 + 8), (2 + 8), (3 + 8), (Dim.Z / TextureSpan), (Dim.Y / TextureSpan))
		CreateQuad(i, (1 + 16), (5 + 16), (4 + 16), (0 + 16), (Dim.X / TextureSpan), (Dim.Z / TextureSpan))
		CreateQuad(i, (7 + 16), (3 + 16), (2 + 16), (6 + 16), (Dim.X / TextureSpan), (Dim.Z / TextureSpan))

	
	private def RenderStatic():
		CreateMesh()
		
		// Calculate all normals and tangents
		for triangle as Triangle in Triangles:
			// Normals
			v1 as Vector3 = Vector3.Normalize((triangle.V0.Position - triangle.V2.Position))
			v2 as Vector3 = Vector3.Normalize((triangle.V1.Position - triangle.V2.Position))
			normal as Vector3 = Vector3.Cross(v1, v2)
			triangle.V0.Normal += normal
			triangle.V1.Normal += normal
			triangle.V2.Normal += normal
			
			// Tangent
			st1 as Vector2 = Vector2.Normalize((triangle.TexCoord0 - triangle.TexCoord2))
			st2 as Vector2 = Vector2.Normalize((triangle.TexCoord1 - triangle.TexCoord2))
			coef as single = (1.0F / ((st1.X * st2.Y) - (st2.X * st1.Y)))
			tangent as Vector3
			tangent.X = ((v1.X * st2.Y) - (v2.X * st1.Y))
			tangent.Y = ((v1.Y * st2.Y) - (v2.Y * st1.Y))
			tangent.Z = ((v1.Z * st2.Y) - (v2.Z * st1.Y))
			tangent *= coef
			triangle.V0.Tangent += tangent
			triangle.V1.Tangent += tangent
			triangle.V2.Tangent += tangent
		for v as Vertex in Vertices:
			v.Normal.Normalize()
			v.Tangent.Normalize()
		
		// Render all triangles			
		GL.FrontFace(FrontFaceDirection.Ccw)
		GL.CullFace(CullFaceMode.Back)
		GL.Begin(BeginMode.Triangles)
		for triangle as Triangle in Triangles:
			triangle.Render()
		GL.End()
		
		/*
			// Render normals
			GL.Begin(BeginMode.Lines);
			GL.Color4(Color.Red);
			foreach(Vertex v in Vertices) {
				GL.Vertex3(v.Position);
				GL.Vertex3(v.Position + 2.0f * v.Normal);
			}
			GL.End();

			// Render tangents
			GL.Begin(BeginMode.Lines);
			GL.Color4(Color.Blue);
			foreach(Vertex v in Vertices) {
				GL.Vertex3(v.Position);
				GL.Vertex3(v.Position + 2.0f * v.Tangent);
			}
			GL.End();			
			*/
		

	
	public def constructor(dim as Vector3):
		Dim = dim
		TextureSpan = 1.0F
		displayList = GL.GenLists(1)

	
	public def Render():
		if IsDirty:
			GL.NewList(displayList, ListMode.Compile)
			RenderStatic()
			IsDirty = false
			GL.EndList()
		GL.CallList(displayList)


	public def CreatePhysicalRepresentation() as Box2DX.Collision.ShapeDef:
		shapeDef = PolygonDef()
		shapeDef.SetAsBox(Dim.X, Dim.Y)
		return shapeDef