namespace Floored

import System
import Box2DX.Collision
import Box2DX.Common
import Box2DX.Dynamics

enum CollisionGroups:
	Background = 0x1
	Player = 0x2
	Projectiles = 0x4
	

class World:
	public Physics as Box2DX.Dynamics.World
	public Objects = List[of GameObject]()
	protected DestroyList = List[of GameObject]()
	
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