namespace Floored.Objects

import System
import Floored
import Core.Graphics

class Collectable(GameObject):
	
	rotation as single = 0.0f
	[Getter(Obj)] _obj as GameObject
	
	def constructor(obj as GameObject):
		_obj = obj
		
	def Tick():
		rotation += Game.Instance.Dt * 90.0f
		
	def Render():
		MatrixStacks.Push()
		MatrixStacks.Translate(Position.X, Position.Y, Position.Z)
		MatrixStacks.Rotate(rotation, 0, 1, 0)
		_obj.Render()
		MatrixStacks.Pop()
