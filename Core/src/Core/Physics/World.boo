namespace Core.Physics

import System
import Tao.Ode
import Tao.Ode.Ode
import OpenTK.Math

class World:
"""Description of World"""
	public _World as IntPtr
	public Dt = 0.02f
	public Time = 0.0f
	public Space as Space
	
	public Gravity as Vector3:
		set:
			dWorldSetGravity(_World, value.X, value.Y, value.Z)

	public def constructor():
		_World = Ode.dWorldCreate()	
		dWorldSetERP(_World, 0.2f)
		dWorldSetCFM(_World, 0.00001f)
		dWorldSetContactMaxCorrectingVel(_World, 0.9f)
		dWorldSetContactSurfaceLayer(_World, 0.001f)
		dWorldSetAutoDisableFlag(_World, 1)
		
		Gravity = Vector3(0, -4.0, 0)
		Space = Space(self)
	
	public def CreateBody() as Body:
		return Body(self)
	
	public def Step():
		Space.Collide()
		Ode.dWorldQuickStep(_World, Dt)
		Space.Clear()
		Time += Dt

class Space:
	public _Space as IntPtr
	MaxContacts = 10
	World as World
	ContactGroup as IntPtr
	
	def constructor(world as World):
		_Space = dSimpleSpaceCreate(IntPtr.Zero)
		World = world
		ContactGroup = Tao.Ode.Ode.dJointGroupCreate(0)

	public def NearCallback(data as IntPtr, o1 as IntPtr, o2 as IntPtr):
		body1 = dGeomGetBody(o1)
		body2 = dGeomGetBody(o2)
		
		
		contacts = array(dContact, 4)
		contactGeoms = array(dContactGeom, contacts.Length)
		
		collisions = dCollide(o1, o2, contactGeoms.Length, contactGeoms, Marshal.SizeOf(contactGeoms[0]))
		for i in range(collisions):
			continue if contactGeoms[i].depth == 0
			contacts[i].surface.mode = cast(int, dContactFlags.dContactBounce)
			contacts[i].surface.bounce = 0.5
			contacts[i].surface.mu = 100.0
			
			joint = dJointCreateContact(World._World, ContactGroup, contacts[i])
			dJointAttach(joint, body1, body2)
		
	public def Collide():
		dSpaceCollide(_Space, IntPtr.Zero, NearCallback)
	
	public def Clear():
		dJointGroupEmpty(ContactGroup)
	
abstract class IMass:
	pass
	
class BoxMass:
	pass
	
interface IGeometry:
	Body as Body:
		get
		set

class AbstractGeometry(IGeometry):	
	_Geometry as IntPtr
	
	
	
	protected def constructor(geometry as IntPtr):
		_Geometry = geometry	

	public virtual Placeable as bool:
		get: return true

	public Body as Body:
		set: 
			if not Placeable:
				return
			if value.Geometry != self:
				raise Exception("Cannot geometry to body with body.Geometry != self")
			dGeomSetBody(_Geometry, value._Body)
			_Body = value
		get:
			return _Body
	private _Body as Body
	
	
class SphereGeometry(AbstractGeometry):
	def constructor(space as Space, radius as single):
		super(dCreateSphere(space._Space, radius))
	
class BoxGeometry(AbstractGeometry):
	def constructor(space as Space, lx as single, ly as single, lz as single):
		super(dCreateBox(space._Space, lx, ly, lz))

class PlaneGeometry(AbstractGeometry):
	def constructor(space as Space, a as single, b as single, c as single, d as single):
		super(dCreatePlane(space._Space, a, b, c, d))

	public override Placeable as bool:
		get: return false

	
class Body:
	public _Body as IntPtr
	public _Mass as Ode.dMass
	public World as World
	
	public Geometry as IGeometry:
		set:
			_Geometry = value
			value.Body = self
		get:
			return _Geometry
	private _Geometry as IGeometry
	
	public Timestamp as single = single.NaN
	"""Time the object's properties were last updated"""
	
	public Position as Vector3:
	"""The body's current position"""
		set:
			_Position = value
			Ode.dBodySetPosition(_Body, value.X, value.Y, value.Z)
		get:
			Update() if Timestamp != World.Time
			return _Position
	private _Position as Vector3
	
	public Velocity as Vector3:
	"""The body's current velocity"""	
		set:
			Ode.dBodySetLinearVel(_Body, value.X, value.Y, value.Z)
	
	protected def Update():
		vec = Ode.dBodyGetPosition(_Body)
		Position = Vector3(vec.X, vec.Y, vec.Z)
		Timestamp = World.Time
	
	def constructor(world as World):
		World = world
		_Body = Ode.dBodyCreate(world._World)
		
		// Set up mass (TODO: move mass to own class)
		_Mass = Ode.dMass()
		Ode.dMassSetSphere(_Mass, 2500, 0.05f)
		_Mass.mass = 1.0f
		Ode.dBodySetMass(_Body, _Mass)
		
		Position = Vector3(0, 2, 0)
		Velocity = Vector3(0, 0, 0)
		
		// Set up 
		