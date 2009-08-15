namespace Core.Graphics.Wavefront

import System
import System.IO
import Core.Graphics

class Model(IRenderable):
	static loadedModels = Collections.Generic.Dictionary[of string, Model]()
	
	materials = Collections.Generic.Dictionary[of string, Material]()
	_path as string
	textureLoader as callable(string) as Texture
	meshes = Collections.Generic.List[of Mesh]()
	
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
				# Already a mesh read?
				if sw is not null:
					sw.Flush()
					ms.Seek(0, SeekOrigin.Begin)
					m = Mesh(self, meshName, StreamReader(ms), offset, normalOffset)
					if m.Name != "collision":
						meshes.Add(m)
					offset = m.NewOffset
					normalOffset = m.NewNormaloffset
				meshName = vals[1]
				print "Loading mesh ${vals[1]}.."
				ms = MemoryStream()
				sw = StreamWriter(ms)
			elif sw is not null:
				sw.WriteLine(line)

		if sw is not null:
			sw.Flush()
			ms.Seek(0, SeekOrigin.Begin)
			m = Mesh(self, meshName, StreamReader(ms), offset, normalOffset)
			if m.Name != "collision":
				meshes.Add(m)
			offset = m.NewOffset

		stream.Close()
		
		
	def Render():
		for mesh in meshes:
			mesh.Render()
		
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
