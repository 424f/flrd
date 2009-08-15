namespace Game.Objects

import System
import Tao.OpenGl.Gl
import Core.Common
import Game

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
		
		# Add a label
		/*tmp = OpenTK.Math.Vector4(Position.X, Position.Y, Position.Z, 1)
		tmp = OpenTK.Math.Vector4.Transform(tmp, Game.Instance.inverseModelMatrix)*/
		
		/*
		// TODO: make these calculations ONCE per frame
		model = array(double, 16)
		glGetDoublev(GL_MODELVIEW_MATRIX, model)
		proj = array(double, 16)
		glGetDoublev(GL_PROJECTION_MATRIX, proj)
		view = (0, 0, 1024, 768)
		glGetIntegerv(GL_VIEWPORT, view)
		
		winX as double
		winY as double
		winZ as double
		
		gluProject(Position.X, Position.Y, Position.Z, model, proj, view, winX, winY, winZ)
		
		
		Game.Instance.WeaponLabel.label = "Machine Gun"
		Game.Instance.WeaponLabel.Position = Core.Math.Rect(winX - 50, 768-winY-150, 400, 200)
		*/
		
