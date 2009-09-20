namespace Floored.Objects

import System
import Floored
import Tao.OpenGl.Gl

class Collectable(GameObject):
	
	rotation as single = 0.0f
	[Getter(Obj)] _obj as GameObject
	
	def constructor(obj as GameObject):
		_obj = obj
		
	def Tick():
		rotation += Game.Instance.Dt * 90.0f
		
	def Render():
		glPushMatrix()
		glTranslatef(Position.X, Position.Y, Position.Z)
		glRotatef(rotation, 0, 1, 0)
		_obj.Render()
		glPopMatrix()
