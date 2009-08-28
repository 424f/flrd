namespace Floored.Objects

import Floored
import Core.Graphics
import OpenTK.Math
import OpenTK.Graphics
import Box2DX.Common
import Box2DX.Collision
import Box2DX.Dynamics

class Player(GameObject, IDamageable):	
	Health = 100.0f
	Character as Md3.CharacterInstance
	BodyShape as Shape
	OnGround = false
	FeetShape as Shape
	LastJump = 100f

	public def constructor(skin as Md3.CharacterSkin):
		# Instantiate model
		character = skin.GetInstance()
		character.Position = Vector3(0, 0, 0)
		character.LowerAnimation = character.Model.GetAnimation(Md3.AnimationId.LEGS_WALK)
		character.Scale = 0.033f
		character.LookDirection = Vector3(-1.0f, 0.0f, 0.0f)
		character.WalkDirection = character.LookDirection
		Character = character
		
		# Create a body
		bodyDef = BodyDef()

		PlayerBody = Game.Instance.World.Physics.CreateBody(bodyDef)
		
		shapeDef = PolygonDef()
		shapeDef.SetAsBox(0.5f, 0.9f, Vec2(0, 0.05f), 0f)
		shapeDef.Density = 50.0f
		shapeDef.Friction = 0.0f
		shapeDef.Restitution = 0.0f

		shapeDef.Filter.MaskBits = ~cast(ushort, CollisionGroups.Player)
		shapeDef.Filter.CategoryBits = cast(ushort, CollisionGroups.Player)
		
		BodyShape = PlayerBody.CreateShape(shapeDef)

		feetDef = PolygonDef()
		feetDef.SetAsBox(0.3f, 0.11f, Vec2(0f, -0.80f), 0f)
		feetDef.IsSensor = true
		FeetShape = PlayerBody.CreateShape(feetDef)
		FeetShape.UserData = SensorInformation()
		
		PlayerBody.SetMassFromShapes();		
		
		super(character, PlayerBody)
		
	public override def Tick(dt as single):
		Character.Tick(dt)
		OnGround = (FeetShape.UserData as SensorInformation).Contacts.Count > 0
		LastJump += dt
		if OnGround and LastJump >= 0.25f:
			Body.ApplyImpulse(Body.GetMass()*Vec2(0f, 10f), Vec2.Zero)
			LastJump = 0f
			print "JUMP"
		OnGround = false
		
	public override def Update():
		super.Update()
		if Body.GetAngle() != 0f:
			Body.SetXForm(Body.GetPosition(), 0f)
		_Position.Y = Body.GetPosition().Y - 0.9f					
	
	public override def Render():
		super.Render()

	public def Damage(amount as single, inflictedBy as GameObject):
		Health -= amount
		if Health <= 0.0f:
			Character.LowerAnimation = Character.Model.GetAnimation(Md3.AnimationId.BOTH_DEATH_1)
			Character.UpperAnimation = Character.Model.GetAnimation(Md3.AnimationId.BOTH_DEATH_1)
			BodyShape.FilterData.CategoryBits = 0
	
	public override def Collide(other as GameObject, contact as ContactResult):
		if FeetShape in (contact.Shape1, contact.Shape2):
			OnGround = true
			//print "${contact.Shape1} ${contact.Shape2}"