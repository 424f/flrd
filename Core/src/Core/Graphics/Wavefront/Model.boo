namespace Core.Graphics.Wavefront

import System
import System.IO
import Core.Graphics
import OpenTK.Graphics.OpenGL
import OpenTK

class Model(AbstractRenderable):
	static loadedModels = Collections.Generic.Dictionary[of string, Model]()
	
	materials = Collections.Generic.Dictionary[of string, Wavefront.Material]()
	_path as string
	textureLoader as callable(string) as Texture
	meshes = Collections.Generic.List[of Mesh]()
	
	Faces = List[of Face]()
	Vertices = List[of Wavefront.Vertex]()
	Normals = List[of Vector3]()
	TexCoords = List[of Vector2]()
	
	static public def Load(filename as string):
		file = Path.GetFullPath(filename)
		if not loadedModels.ContainsKey(file):
			loadedModels[file] = Model(filename, Texture.Load)
		return loadedModels[file]
		
	
	private def constructor(filename as string, textureLoader as callable(string) as Texture):
		_path = filename
		self.textureLoader = textureLoader
	
		# First of all, try to load materials
		LoadMaterials()
	
		# Load the model itself
		stream = FileStream(filename, FileMode.Open, FileAccess.Read, FileShare.None)
		reader = StreamReader(stream)
		
		sw as StreamWriter
		ms as MemoryStream
		meshName = ""
		
		offset = 0
		normalOffset = 0
		
		while not reader.EndOfStream:
			line = reader.ReadLine()
			continue if line.StartsWith("#") or line.Trim().Length == 0
			vals = line.Split(char.Parse(" "))
			continue if vals.Length == 0
			if vals[0] == "g":
				OnGroup(vals)
			elif vals[0] == "v":
				OnVertex(vals)
			elif vals[0] == "vn":
				OnNormal(vals)
			elif vals[0] == "vt":
				OnTexCoord(vals)
			elif vals[0] == "f":
				OnFace(vals)

		stream.Close()
		
	def OnGroup(params as (string)):
		pass
		
	def OnVertex(params as (string)):
		v = Vertex()
		v.Vector.X = single.Parse(params[1])
		v.Vector.Y = single.Parse(params[2])
		v.Vector.Z = single.Parse(params[3])
		v.Vector *= 0.01f // TODO: scaling factor (configurable)
		
		Vertices.Add(v)

	def OnNormal(params as (string)):
		v = Vector3()
		v.X = single.Parse(params[1])
		v.Y = single.Parse(params[2])
		v.Z = single.Parse(params[3])
		
		Normals.Add(v)

	def OnTexCoord(params as (string)):
		v = Vector2()
		v.X = single.Parse(params[1])
		v.Y = single.Parse(params[2])
		
		TexCoords.Add(v)
		
	def OnFace(params as (string)):		
		// Vertices
		parsed = [(int.Parse(params[x + 1].Split(char.Parse('/'))[0]) - 1) for x in range(3)]
		i1 = parsed[0]
		i2 = parsed[1]
		i3 = parsed[2]
		v1 = Vertices[i1]
		v2 = Vertices[i2]
		v3 = Vertices[i3]
		f = Face(v1, v2, v3)

		// TexCoords
		try:
			parsed = [(int.Parse(params[x + 1].Split(char.Parse('/'))[1]) - 1) for x in range(3)]
			i1 = parsed[0]
			i2 = parsed[1]
			i3 = parsed[2]
			t1 = TexCoords[i1]
			t2 = TexCoords[i2]
			t3 = TexCoords[i3]
			f.V1.UV = t1
			f.V2.UV = t2
			f.V3.UV = t3
		except:
			pass
		
		// Normals
		//parsed = [(int.Parse(params[x + 1].Split(char.Parse('/'))[2]) - 1) for x in range(3)]
		//i1 = parsed[0]
		//i2 = parsed[1]
		//i3 = parsed[2]
		n = Vector3.Cross(v2.Vector - v1.Vector, v3.Vector - v1.Vector)
		n.Normalize()
		f.N1 = n
		f.N2 = n
		f.N3 = n
		
		Faces.Add(f)
	
	def Render():
		GL.Enable(EnableCap.Lighting)
		GL.Color4(Drawing.Color.White)
		GL.Begin(BeginMode.Triangles)
		for face in Faces:
			for v in (face.V1, face.V2, face.V3):
				GL.Normal3(face.N1)
				GL.TexCoord2(v.UV)
				GL.Vertex3(v.Vector.X, v.Vector.Y, v.Vector.Z)
		GL.End()
		
	def LoadMaterials():
		path = Path.Combine(Path.GetDirectoryName(_path), Path.GetFileNameWithoutExtension(_path) + ".mtl")
		print path
		if not File.Exists(path):
			print "No material file found!!"
			return
		reader = StreamReader(FileStream(path, FileMode.Open, FileAccess.Read, FileShare.None))			
		material as Wavefront.Material = null
		while not reader.EndOfStream:
			line = reader.ReadLine()
			continue if line.StartsWith("#") or line.Trim().Length == 0
			vals = line.Split(char.Parse(" "))
			continue if vals.Length == 0
			
			if vals[0] == "newmtl":
				material = Wavefront.Material()
				materials.Add(vals[1], material)
			continue if material is null
			
			if vals[0] == "map_Kd":
				material.texture = textureLoader([x for x in vals[1:]].Join(" "))
				
		reader.Close()

	def GetMaterial(name as string) as Wavefront.Material:
		if not materials.ContainsKey(name):
			return null
		return materials[name]
