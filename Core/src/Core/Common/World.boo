namespace Core.Common

class WorldObject:
	pass

abstract class World:
	[Getter(Objects)] _objects = []
	"""All the objects contained in the World"""
	
	def constructor():
		pass	
	
	def Add(obj as WorldObject):
		_objects += [obj]
		
	def Remove(obj as WorldObject):
		_objects.Remove(obj)

	abstract def GetObjectsWithinSphere(origin, radius) as List:
		pass
		
	abstract def GetObjectsWithinQuad(quad) as List:
		pass
		
class BruteForceWorld(World):
	def GetObjectsWithinSphere(origin, radius):
		pass
		
	def GetObjectsWithinQuad(quad):
		return []
		
abstract class OctreeWorld(World):
"""A world using an Octree to locate objects"""
	pass
