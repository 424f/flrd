namespace Floored.Objects.Environment

import Floored
import Core.Util.Ext
import OpenTK
import Core.Graphics
import Box2DX.Common
import Box2DX.Dynamics

class Elevator(GameObject):
"""An elevator is a platform that moves between two points"""
	public Start as Vec2
	public Destination as Vec2
	public TimePassed = 0f
	public Joint as PrismaticJoint

	public def constructor(world as World, start as Vec2, destination as Vec2, material as Material):
		// Create a static box at start position
		box = Shapes.Box(Vector3(1.5f, 0.2f, 1.5f))
		bodyDef = BodyDef()
		bodyDef.Position = start
		body = world.CreateBodyFromShape(bodyDef, box.CreatePhysicalRepresentation(), 500.0f, 1.5f, 0.0f)
		super(box, body)

		// Create a prismatic joint
		joint = Box2DX.Dynamics.PrismaticJointDef()
		dir = destination - start
		dir.Normalize()
		joint.Initialize(world.Physics.GetGroundBody(), body, start, dir)
		joint.LowerTranslation = 0f
		joint.UpperTranslation = (destination - start).Length()
		joint.MaxMotorForce = 30000f
		joint.MotorSpeed = 4f
		joint.EnableLimit = true
		joint.EnableMotor = true
		Joint = world.Physics.CreateJoint(joint)
		
		Position = start.AsVector3()
		
		Material = material

	public override def Tick(dt as single):
		TimePassed += dt
		if TimePassed >= 4f:
			Joint.MotorSpeed = -Joint.MotorSpeed
			TimePassed -= 4f