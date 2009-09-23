namespace Core.Graphics.Wavefront

import System
import System.IO
import Core.Graphics
import OpenTK.Graphics.OpenGL

class Model(IRenderable):
	static loadedModels = Collections.Generic.Dictionary[of string, Model]()
	
	materials = Collections.Generic.Dictionary[of string, Material]()
	_path as string
	textureLoader as callable(string) as Texture
	meshes = Collections.Generic.List[of Mesh]()
	
	Faces = List[of Face]()
	Vertices = List[of Vertex]()
	
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
		v.Vector *= 0.01f
		
		Vertices.Add(v)
		
	def OnFace(params as (string)):
		parsed = [(int.Parse(params[x + 1].Split(char.Parse('/'))[0]) - 1) for x in range(3)]
		i1 = parsed[0]
		i2 = parsed[1]
		i3 = parsed[2]
		v1 = Vertices[i1]
		v2 = Vertices[i2]
		v3 = Vertices[i3]
		f = Face(v1, v2, v3)
		Faces.Add(f)
	
	def Render():
		GL.Color4(System.Drawing.Color.Red)
		GL.Begin(BeginMode.Triangles)
		GL.Disable(EnableCap.CullFace)
		for face in Faces:
			for v in (face.V1.Vector, face.V2.Vector, face.V3.Vector):
				GL.Vertex3(v.X, v.Y, v.Z)
		GL.End()
		
	def LoadMaterials():
		path = Path.Combine(Path.GetDirectoryName(_path), Path.GetFileNameWithoutExtension(_path) + ".mtl")
		print path
		if not File.Exists(path):
			print "No material file found!!"
			return
		reader = StreamReader(FileStream(path, FileMode.Open, FileAccess.Read, FileShare.None))			
		material as Material = null
		while not reader.EndOfStream:
			line = reader.ReadLine()
			continue if line.StartsWith("#") or line.Trim().Length == 0
			vals = line.Split(char.Parse(" "))
			continue if vals.Length == 0
			
			if vals[0] == "newmtl":
				material = Material()
				materials.Add(vals[1], material)
			continue if material is null
			
			if vals[0] == "map_Kd":
				material.texture = textureLoader([x for x in vals[1:]].Join(" "))
				
		reader.Close()

	def GetMaterial(name as string) as Material:
		if not materials.ContainsKey(name):
			return null
		return materials[name]
