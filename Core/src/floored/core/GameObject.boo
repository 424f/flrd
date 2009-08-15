namespace Core.Common
import OpenTK.Math
import Core.Graphics
import Core.Math

abstract class GameObject(IRenderable):
"""
A GameObject is an entity that's part of the game world
"""
	def constructor():
		pass
		
	virtual def Collect(target as GameObject):
		pass
	
	abstract def Tick():
		pass
	
	Health as int:
		virtual set:
			pass
		virtual get:
			return 0
	
	Name as string:
		virtual get:
			return self.GetType().Name
	
	virtual def Revive():
		pass
		
	virtual def Kill():
		pass
	
	[Property(Position)] _Position as Vector3
	
	BoundingSphere:
		get:
			return Sphere(self.Position, 25.0f)
