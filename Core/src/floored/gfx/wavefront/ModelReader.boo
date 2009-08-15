namespace Core.Graphics.Wavefront

import System
import OpenTK.Math

abstract class ModelReader:
"""
Delivers data from an OBJ file, e.g. vertices and normals. We use this 
additional abstraction so we can use "real" OBJ files and our own
cached binary OBJ files
"""
	
	handlers = {
		'g': HandleMesh,
		'usemtl': HandleMaterial,
		'v': HandleVertex,
		'vt': HandleTexCoords,
		'vn': HandleNormal,
		'f': HandleFace
	}
	"""Maps data types to their handler methods"""

	def constructor():
		pass	

	abstract def Load(path as string) as Model:
		pass

	protected def HandleMesh(name as string):
		pass
		
	protected def HandleMaterial(name as string):
		pass
				
	protected def HandleVertex(v as Vector3):
		pass
				
	protected def HandleNormal(n as Vector3):
		pass
		
	protected def HandleFace():
		pass
		
	protected def HandleTexCoords(uv as Vector2):
		pass
