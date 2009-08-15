namespace Core.Graphics.Wavefront

import System
import OpenTK.Math
import Tao.OpenGl.Gl

class Face:
	def constructor(v1 as Vertex, v2 as Vertex, v3 as Vertex):
		self.V1 = v1
		self.V2 = v2
		self.V3 = v3
	
	public V1 as Vertex
	public V2 as Vertex
	public V3 as Vertex
	public N1 as Vector3
	public N2 as Vector3
	public N3 as Vector3
	
class Vertex:
	public Vector as Vector3
	public UV as Vector2

class Mesh:
"""Description of Mesh"""
	DisplayList as int
	public NewOffset as int
	public NewNormaloffset as int
	Material as Material
	public Name as string

	def constructor(model as Model, name as string, reader as IO.StreamReader, offset as int, normalOffset as int):
		self.Name = name
		print "Reading mesh ${name}"
		vertexList = Collections.Generic.List[of Vertex]()
		faceList = Collections.Generic.List[of Face]()
		texCoordsList = Collections.Generic.List[of Vector2]()
		normalsList = Collections.Generic.List[of Vector3]()

		while not reader.EndOfStream:
			line = reader.ReadLine()
			continue if line.StartsWith("#") or line.Trim().Length == 0
			vals = line.Split((" ",), StringSplitOptions.RemoveEmptyEntries)
			continue if vals.Length == 0
			try:
				print "'${vals[0]}'"
				if vals[0] == "v":
					# Vertex
					vertex = Vector3(single.Parse(vals[1]), single.Parse(vals[2]), single.Parse(vals[3]))
					vertex.Scale(0.3, 0.3, 0.3)
					vertex = Vector3(vertex.X, vertex.Z, -vertex.Y)
					v = Vertex()
					v.Vector = vertex
					vertexList.Add(v)
				elif vals[0] == "f":
					# Face
					parsed = [(int.Parse(vals[x + 1].Split(char.Parse('/'))[0]) - 1 - offset) for x in range(3)]
					face = Face(vertexList[parsed[0]], vertexList[parsed[1]], vertexList[parsed[2]])
					try:
						normal = [(int.Parse(vals[x + 1].Split(char.Parse('/'))[2]) - 1 - normalOffset) for x in range(3)]
						face.N1 = normalsList[normal[0]]
						face.N2 = normalsList[normal[1]]
						face.N3 = normalsList[normal[2]]					
					except e:
						print e
					faceList.Add(face)
				elif vals[0] == "vt":
					vertexList[texCoordsList.Count].UV = Vector2(single.Parse(vals[1]), single.Parse(vals[2]))
					texCoordsList.Add(Vector2(single.Parse(vals[1]), 1.0-single.Parse(vals[2])))
				elif vals[0] == "vn":
					normalsList.Add(Vector3(single.Parse(vals[1]), single.Parse(vals[3]), -single.Parse(vals[2])))
				elif vals[0] == "usemtl":
					print "Use material ${vals[1]}"
					materialName as string = vals[1]
					material = model.GetMaterial(materialName)
			except e:
				print e		
		# Create the display list for later rendering
		CreateDisplayList(faceList)
		
		newOffset = offset + vertexList.Count
		newNormaloffset = normalOffset + normalsList.Count
		
	def Render():
		glCallList(DisplayList)

	private def CreateDisplayList(faces as Collections.Generic.List[of Face]):
		print "Creating display list for ${faces.Count} faces"
		displayList = glGenLists(1)
		glNewList(displayList, GL_COMPILE)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
		#glDisable(GL_TEXTURE_2D)
		if Material is not null and Material.texture is not null:
			Material.texture.Bind()
		glBegin(GL_TRIANGLES)
		for f as Face in faces:
			for v as Vertex, n as Vector3 in ((f.V1, f.N1), (f.V2, f.N2), (f.V3, f.N3)):
				glColor3f(1, 1, 1)
				glNormal3f(n.X, n.Y, n.Z)
				glTexCoord2f(v.UV.X, v.UV.Y)
				glVertex3f(v.Vector.X, v.Vector.Y, v.Vector.Z)
		glEnd()		

		/*glBegin(GL_LINES)
		for f as Face in faces:
			for v as Vertex, n as Vector3 in ((f.V1, f.N1), (f.V2, f.N2), (f.V3, f.N3)):
				glColor3f(0, 0, 1)
				glVertex3f(v.Vector.X, v.Vector.Y, v.Vector.Z)		
				glVertex3f(v.Vector.X + n.X*20, v.Vector.Y + n.Y*20, v.Vector.Z + n.Z*20)
		glEnd()*/
		
		glEndList()
