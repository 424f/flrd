namespace BooLandscape

import System
import System.Drawing
import OpenTK
import OpenTK.Graphics
import Tao.OpenGl.Gl
import System.Math
import OpenTK.Math
import Core.Graphics

class TerrainChunk:
	public ID as int
	public LowPoly as int
	public Max as Vector3
	public Min as Vector3
	
class Terrain:
	trees = List[of Point]()	
	public program as ShaderProgram
	Skybox as Skybox
	grasses = List[of Vector3]()
	maples = List[of Vector3]()
	gridSize = 50.0
	GridLength = 64
	GridWidth = gridSize * GridLength	
	public heightMap = matrix(Vertex, GridLength, GridLength)	
	sun = Vector3.Normalize(Vector3(4, 4, 0))
	mapList = -1	
	texSand as int
	texGrass as int
	texRock as int	
	texMaple as int
	ChunkSize = 16
	Chunks as (TerrainChunk, 2)
	

	public def constructor(textureLoader as callable(string) as int):
		/*texRock = textureLoader("""Data/Textures/Terrain/SnowDirt.jpg""")
		texGrass = textureLoader("""Data/Textures/Terrain/Snow.jpg""")
		texSand = textureLoader("""Data/Textures/Terrain/Ice.jpg""")*/
		texRock = textureLoader("""Data/Textures/Terrain/a.jpg""")
		texGrass = textureLoader("""Data/Textures/Terrain/x.jpg""")
		texSand = textureLoader("""Data/Textures/Terrain/z.jpg""")		
		texMaple = textureLoader("""Data/Textures/Billboards/Tree2.png""")
		
		// Upper-most point
		ceiling = -10000.0

		bitmap as Bitmap = System.Drawing.Bitmap.FromFile("""Data/Heightmaps/Map.bmp""")
		r = Random()
		for i in range(GridLength):
			for j in range(GridLength):
				vertex = Vertex()
				fact = Sin((i) / 16.0 * gridSize) + \
				       Sin(10+(j) / 16.0 * gridSize) + \
				       1.2*Sin(3+(i) / 16.0 * gridSize / 2.3) + \
				       Sin(Log(i)*Log(j)) 
				vertex.v = Vector3((-GridLength / 2 + i)*gridSize,  30 + 10*(fact), (j - GridLength / 2)*gridSize)
				vertex.v.Y -= j / 2.0
				height = bitmap.GetPixel(i, j).GetBrightness() * 400.0 - 20.0
				vertex.v.Y = height
				if vertex.v.Y > ceiling:
					ceiling = vertex.v.Y
				vertex.c = Vector4(1, 0, 0, 1)
				vertex.normal = Vector3(0, 0, 0)
				heightMap[i, j] = vertex
				//if vertex.v.Y > 0 and r.Next(0, 15) == 0:
				//	grasses.Add(vertex.v)
				if vertex.v.Y > 10 and r.Next(0, 90) == 0:
					maples.Add(vertex.v)
		# Calculate normal
		ambient = 0.3
		print "Sun = ${sun}"
		
		// Loop through every triangle and add its normal to the three vertices
		for i in range(GridLength-1):
			for j in range(GridLength-1):
				for v in (heightMap[i, j], heightMap[i+1, j+1]):
					x = heightMap[i+1, j]
					y = heightMap[i, j+1]
					va = Vector3(x.v - v.v)
					vb = Vector3(y.v - v.v)
					normal = Vector3.Cross(vb, va)
					if normal.Y < 0:
						normal = -normal
					normal.Normalize()
					
					for vv in (x, y, v):
						vv.normal += normal
					//print normal
				//print '--'
		
		// Apply blur to brightness
		// ...
		
		// Normalize normals and calculate lighting
		for i in range(GridLength):
			for j in range(GridLength):
				heightMap[i, j].normal.Normalize()				
				// Is the vertex at all visible from the sun?
				visible = true
				heightMap[i, j].c = Vector4(0, 0, 0, 0)
				
				pos = heightMap[i, j].v + sun
				// TODO: improve to only make as little comparisons as possible
				while pos.Y < ceiling:
					p = PositionToIndex(pos)
					ii = p.X
					jj = p.Y
					
					if false: // and i != ii or j != jj:
						print "ERROR is ${ii}, ${jj} should be ${i}, ${j}"
					if ii < 0 or ii >= GridLength or jj < 0 or jj >= GridLength:
						break
					v = heightMap[ii, jj].v
					if v.Y > pos.Y:
						//print "Got hit at ${v.Y} VS ${pos.Y}"
						visible = false
						break
					pos += sun
				
				if visible:
					heightMap[i, j].c.W = 1.0
				else:
					heightMap[i, j].c.W = 0.0
				
				// Apply textures
				Y = heightMap[i, j].v.Y
				heightMap[i, j].c.X = 0.0
				trans = 30.0
				levels = (40.0, 110.0)
				
				if Y > levels[0] - trans and Y < levels[1]:
					if Y < levels[0]:
						heightMap[i, j].c.X = (Y - levels[0] + trans) / trans
					if Y > levels[1] - trans:
						heightMap[i, j].c.X = (levels[1] - Y) / trans
					else:
						heightMap[i, j].c.X = 1.0
				
				if Y > levels[1] - trans:
					if Y < levels[1]:
						heightMap[i, j].c.Y = (Y - levels[1] + trans) / trans
					else:
						heightMap[i, j].c.Y = 1.0
					
				if Y <= levels[0]:
					if Y <= levels[0] - trans:
						heightMap[i, j].c.Z = 1.0
					else:
						heightMap[i, j].c.Z = (levels[0] - Y) / trans		

		// Load shaders
		vertexShader = Shader(ShaderType.VertexShader, "Data/Shaders/terrain_vertex.glsl")
		fragmentShader = Shader(ShaderType.FragmentShader, "Data/Shaders/terrain_fragment.glsl")
		
		program = ShaderProgram()
		program.Attach(vertexShader)
		program.Attach(fragmentShader)
		program.Link()
			
	public def Render():
		def clr(vertex as Vertex):			
			v = vertex.v
			GL.Color4(vertex.c)			
			m = 1.0 / 30.0
			OpenTK.Graphics.GL.MultiTexCoord2(OpenTK.Graphics.TextureUnit.Texture0, (v.X * m, v.Z * m))	
		
		numChunks = GridLength / ChunkSize
		
		program.Apply()

		# Draw landscape
		i = 0
		for s as string, tex as int in (("Grass", texGrass), ("Rock", texRock), ("Stone", texSand)):
			alphaLoc = program.GetUniformLocation(s)
			GL.ActiveTexture(TextureUnit.Parse(TextureUnit, "Texture${i}"))
			GL.BindTexture(TextureTarget.Texture2D, tex)
			OpenTK.Graphics.GL.Uniform1(alphaLoc, i)	
			i += 1
		
		if mapList == -1:
			Chunks = matrix(TerrainChunk, numChunks, numChunks)
			for x in range(numChunks):
				for y in range(numChunks):
					t = TerrainChunk()
					
					// Create high resolution display list
					mapList = glGenLists(1)
					glNewList(mapList, GL_COMPILE)

					def draw(i, j):
						v = heightMap[i, j].v
						clr(heightMap[i, j])
						GL.Normal3(heightMap[i, j].normal)
						GL.Vertex3(v)	
						if t.Min.X < v.X:
							t.Min.X = v.X
						if t.Min.Y < v.Y:
							t.Min.Y = v.Y
						if t.Min.Z < v.Z:
							t.Min.Z = v.Z

						if t.Max.X > v.X:
							t.Max.X = v.X
						if t.Max.Y > v.Y:
							t.Max.Y = v.Y
						if t.Max.Z > v.Z:
							t.Max.Z = v.Z							
					//GL.CullFace(CullFaceMode.Back)
					GL.Begin(BeginMode.Triangles)
					for i in range(ChunkSize*x, ChunkSize*(x + 1)):
						for j in range(ChunkSize*y, ChunkSize*(y + 1)):							
							if i == GridLength - 1 or j == GridLength - 1: 
								break
							if (i + j) % 2 == 0:
								draw(i, j)
								draw(i+1, j)
								draw(i, j+1)
				
								draw(i+1, j+1)
								draw(i+1, j)
								draw(i, j+1)
							else:
								draw(i, j+1)
								draw(i+1, j+1)
								draw(i, j)
				
								draw(i+1, j)
								draw(i+1, j+1)
								draw(i, j)
					GL.End()		
					glEndList()
					t.ID = mapList

					// Create low resolution display list
					mapList = glGenLists(1)
					glNewList(mapList, GL_COMPILE)
						
					GL.Begin(BeginMode.Triangles)
					for i in range(ChunkSize*x, ChunkSize*(x + 1), 8):
						for j in range(ChunkSize*y, ChunkSize*(y + 1), 8):							
							if i >= GridLength - 8 or j >= GridLength - 8: 
								break
							draw(i, j)
							draw(i+8, j)
							draw(i, j+8)
			
							draw(i+8, j+8)
							draw(i+8, j)
							draw(i, j+8)
					GL.End()		
					glEndList()
					
					t.LowPoly = mapList
					Chunks[x, y] = t
		
		modelView = Core.Util.Matrices.ModelView
		
		for x in range(numChunks):
			for y in range(numChunks):
				chunk = Chunks[x, y]
				
				// Calculate distance
				center = Vector4(chunk.Max - chunk.Min)
				center.W = 1.0
				centerEye = Vector3(Vector4.Transform(center, modelView))
				l = centerEye.Length
				
				if l >= 1000.0 and false:
					glCallList(Chunks[x, y].LowPoly)
				else:
					glCallList(Chunks[x, y].ID)
				
		program.Remove()
		GL.ActiveTexture(TextureUnit.Texture0)	
		
		// Render grass
		model = array(double, 16)
		glGetDoublev(GL_MODELVIEW_MATRIX, model)
		
		GL.Enable(EnableCap.Blend)
		GL.Enable(EnableCap.Texture2D)
		GL.AlphaFunc(AlphaFunction.Greater, 0.3)
		GL.Enable(EnableCap.AlphaTest)
		
		GL.BindTexture(TextureTarget.Texture2D, texMaple)
		glDisable(GL_LIGHTING)
		GL.Begin(BeginMode.Triangles)
		GL.Color4(Color.White)
		ex = 80.0
		right = Vector3(model[0], model[4], model[8]) * ex
		up = Vector3(model[1], model[5], model[9]) * 2 * ex		
		for grass as Vector3 in maples:
			GL.TexCoord2(0, 1.0)
			GL.Vertex3(grass - right)
			GL.TexCoord2(1, 1.0)
			GL.Vertex3(grass + right)
			GL.TexCoord2(1, 0)
			GL.Vertex3(grass + right + up)

			GL.TexCoord2(0, 1.0)
			GL.Vertex3(grass - right)
			GL.TexCoord2(0, 0)
			GL.Vertex3(grass - right + up)
			GL.TexCoord2(1, 0)
			GL.Vertex3(grass + right + up)
		GL.End()
		
		GL.Disable(EnableCap.Blend)		
		GL.Disable(EnableCap.AlphaTest)
		GL.AlphaFunc(AlphaFunction.Greater, 0.0)		

	public def PositionToIndex(position as Vector3) as Point:
		ii = cast(int, (position.X + GridWidth / 2) / gridSize)
		jj = cast(int, (position.Z + GridWidth / 2) / gridSize)
		//print "${position} got ${ii}, ${jj}"
		return Point(ii, jj)		