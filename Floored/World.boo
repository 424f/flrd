namespace Floored

import System
import OpenTK.Graphics.OpenGL
import Box2DX.Collision
import Box2DX.Common
import Box2DX.Dynamics

class CollisionGroups:
	public static final Background as ushort = 1
	public static final Player as ushort = 2
	public static final Projectiles as ushort = 4

class World:
	public Physics as Box2DX.Dynamics.World
	public Objects = List[of GameObject]()
	protected DestroyList = List[of GameObject]()
	protected AddList = List[of GameObject]()
	
	public def constructor(worldAABB as AABB, gravity as Vec2, groundY as single):
		/*worldAAB.LowerBound.Set(-200.0f, -200.0f);
		worldAAB.UpperBound.Set(200.0f, 200.0f);*/
		/*Vec2 gravity = new Vec2(0.0f, -10.0f);*/
		
		doSleep = true
		Physics = Box2DX.Dynamics.World(worldAABB, gravity, doSleep)
		
		// Ground body
		groundBodyDef = BodyDef()
		thickness = 2.0f
		groundBodyDef.Position.Set(0.0f, groundY - thickness)
		groundBody = Physics.CreateBody(groundBodyDef)
		groundShapeDef = PolygonDef()
		groundShapeDef.SetAsBox(worldAABB.UpperBound.X, thickness)
		shape = groundBody.CreateShape(groundShapeDef)
		shape.FilterData.CategoryBits = cast(ushort, CollisionGroups.Background)
		
		Physics.SetContactListener(ContactListener())

	public def Step(dt as single):
		for o in Objects:
			o.Tick(dt)
		for o in AddList:
			Objects.Add(o)
		for o in DestroyList:
			Objects.Remove(o)
			Physics.DestroyBody(o.Body)
		DestroyList.Clear()
		
		velocityIterations = 10
		positionIterations = 1
		Physics.Step(dt, velocityIterations, positionIterations)
		for o in Objects:
			continue if o.Body.IsSleeping()
			o.Update()
			
	public def CreateBodyFromShape(bodyDef as BodyDef, shapeDef as ShapeDef, density as single, friction as single, restitution as single) as Body:
		body = CreateBodyWithoutMassFromShape(bodyDef, shapeDef, density, friction, restitution)
		body.SetMassFromShapes()
		return body

	public def CreateBodyWithoutMassFromShape(bodyDef as BodyDef, shapeDef as ShapeDef, density as single, friction as single, restitution as single) as Body:
		body = Physics.CreateBody(bodyDef)
		shapeDef.Density = density
		shapeDef.Friction = friction
		shapeDef.Restitution = restitution
		body.CreateShape(shapeDef)
		return body
		
	public def Destroy(o as GameObject):
		if not DestroyList.Contains(o) and Objects.Contains(o):
			DestroyList.Add(o)

	public def Add(o as GameObject):
		if not AddList.Contains(o) and not Objects.Contains(o):
			AddList.Add(o)
			
	public def Visualize():
		// Visualize physics
		// Render AABBs
		GL.Disable(EnableCap.DepthTest)
		GL.Disable(EnableCap.DepthTest)
		aabb as AABB
		GL.Disable(EnableCap.Texture2D);
		GL.PolygonMode(MaterialFace.FrontAndBack, PolygonMode.Line);
		GL.Begin(BeginMode.Quads);
		b = Physics.GetBodyList()
		while b != null:
			s = b.GetShapeList()
			while s != null:
				if not b.IsSleeping():
					GL.Color4(System.Drawing.Color.Green)
				else:
					GL.Color4(System.Drawing.Color.Gray);									
				if s.IsSensor:
					si = s.UserData as SensorInformation
					if si.__LastContact < 1.0f:
						GL.Color4(System.Drawing.Color.Purple)
						si.__LastContact += 0.01f
				s.ComputeAABB(aabb, b.GetXForm());
				GL.Vertex3(aabb.LowerBound.X, aabb.LowerBound.Y, 0.0f);
				GL.Vertex3(aabb.UpperBound.X, aabb.LowerBound.Y, 0.0f);
				GL.Vertex3(aabb.UpperBound.X, aabb.UpperBound.Y, 0.0f);
				GL.Vertex3(aabb.LowerBound.X, aabb.UpperBound.Y, 0.0f);
				s = s.GetNext()
			b = b.GetNext()
		
		// Render Joints
		GL.Color4(System.Drawing.Color.Blue);
		joint = Physics.GetJointList()
		while joint != null:
			GL.Vertex3(joint.Anchor1.X, joint.Anchor1.Y, 0.0f)
			GL.Vertex3(joint.Anchor2.X, joint.Anchor2.Y, 0.0f)
			GL.Vertex3(joint.GetBody1().GetPosition().X, joint.GetBody1().GetPosition().Y, 0.0f)
			GL.Vertex3(joint.GetBody2().GetPosition().X, joint.GetBody2().GetPosition().Y, 0.0f)
			joint = joint.GetNext()
		
		GL.End()
		GL.PolygonMode(MaterialFace.FrontAndBack, PolygonMode.Fill)
	
		GL.Enable(EnableCap.DepthTest)		