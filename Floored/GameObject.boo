namespace Floored

import System
import Core.Graphics
import Core.Util.Ext
import Box2DX.Common
import Box2DX.Dynamics
import OpenTK
import OpenTK.Graphics
import OpenTK.Graphics.OpenGL

public class GameObject(AbstractRenderable):
	[Property(Body)] _Body as Body
	[Property(Renderable)] _Renderable as IRenderable
	[Property(AutoTransform)] _AutoTransform = true
	[Property(EnableRendering)] _EnableRendering = true
	
	public Position as Vector3:
	"""The object's position in the game world. This usually relates to the center of the object."""
		set:
			_Position = value
			Body.SetXForm(value.AsVec2(), Body.GetAngle())
		get: return _Position
	protected _Position as Vector3
	
	virtual ReportCollisions as bool:
		get: return true
	
	protected def constructor():
		pass
	
	public def constructor(renderable as IRenderable, body as Body):
		Renderable = renderable
		Body = body
		Body.SetUserData(self)
	
	public virtual def Update():
	"""Updates the object after a physics step has been performed"""
		return if Body.IsSleeping()
		// Update 3d coordinates with the simulated 2d coordinates
		pos as Vec2 = Body.GetPosition()
		_Position.X = pos.X
		_Position.Y = pos.Y
	
	public virtual def Render():
		if Material != null:
			RenderState.Instance.ApplyMaterial(Material)
		if AutoTransform:
			MatrixStacks.Push()
			MatrixStacks.Translate(Position)
			MatrixStacks.Rotate(Body.GetAngle() * 180 / System.Math.PI, 0f, 0f, -1f)
			//MatrixStacks.Rotate(90.0F, 0.0F, 1.0F, 0.0F)
		Renderable.Render()
		if AutoTransform:
			MatrixStacks.Pop()
	
	public virtual def Tick(dt as single):
		pass

	public virtual def Collide(other as GameObject, contact as ContactResult):
		pass
			
	public def Destroy():
		Game.Instance.World.Destroy(self)
		