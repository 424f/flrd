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
	JumpEnergy = 0f
	public Weapon as Weapons.IWeapon
	
	// -- Controls --
	// TODO: refactor
	public DoJump = false
	public LookDirection = Vector2.Zero
	public WalkDirection = Vector2.Zero
		/*
		shape = PlayerBody.CreateShape(shapeDef);
		shape.FilterData.MaskBits = ~cast(ushort, CollisionGroups.Player)
		shape.FilterData.CategoryBits = cast(ushort, CollisionGroups.Player)*/
		
	public def constructor(skin as Md3.CharacterSkin):
		# Instantiate model
		character = skin.CreateInstance()
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
		feetDef.SetAsBox(0.3f, 0.20f, Vec2(0f, -0.80f), 0f)
		feetDef.IsSensor = true
		feetDef.Filter.MaskBits = shapeDef.Filter.MaskBits
		feetDef.Filter.CategoryBits = shapeDef.Filter.CategoryBits
		FeetShape = PlayerBody.CreateShape(feetDef)
		FeetShape.UserData = SensorInformation()
		
		// Set mass manually
		md = MassData()
		md.I = 0f
		md.Mass = 80f
		md.Center = Vec2.Zero
		PlayerBody.SetMass(md)
		
		
		PlayerBody.AllowSleeping(false)
		
		super(character, PlayerBody)
		
	public override def Tick(dt as single):
		// Is player on solid ground?
		OnGround = (FeetShape.UserData as SensorInformation).Contacts.Count > 0
		dir = Body.GetLinearVelocity()
		
		// User controls
		if WalkDirection.Length >= 0.2f:
			Character.WalkDirection = Vector3(WalkDirection.X, WalkDirection.Y, 0f)		
		
		if LookDirection.Length >= 0.2f:
				Character.LookDirection = Vector3(LookDirection.X, LookDirection.Y, 0f)
			else:
				Character.LookDirection = Character.WalkDirection	
		
		// Walking
		maxWalkVelocity = 7.0f
		if OnGround or true:
			if System.Math.Abs(WalkDirection.X) > 0.2f:
				pass
			else:
				maxWalkVelocity = 0.0f
			maxWalkVelocity *= System.Math.Sign(WalkDirection.X)
			impulse = Body.GetMass()*(maxWalkVelocity - dir.X)*5.0f
			Body.ApplyForce(Vec2(impulse, 0.0f), Vec2.Zero)		
		
		// Jumping
		LastJump += dt		
		if DoJump and OnGround and LastJump >= 0.25f:
			Body.ApplyImpulse(Body.GetMass()*Vec2(0f, 8f), Vec2.Zero)
			JumpEnergy = 0.3f
			LastJump = 0f
			print "Start jump"
			
		if DoJump and JumpEnergy > 0f:
			Body.ApplyForce(Body.GetMass()*Vec2(0f, 35f), Vec2.Zero)
			JumpEnergy -= dt
			print "Jump force"
			print JumpEnergy

		// Set correct animation
		Dir = Body.GetLinearVelocity()
		walkingThreshold = 2f
		runningThreshold = 4f
		maxSpeed = 10.5f
		accel = 2.0f
		walking = Dir.Length() >= walkingThreshold
		running = Dir.Length() >= runningThreshold
		
		if not OnGround:
			if Dir.Y > 0.1f:
				Character.LowerAnimation = Character.Model.GetAnimation(Md3.AnimationId.LEGS_JUMP)
			elif Dir.Y < -0.1f:
				Character.LowerAnimation = Character.Model.GetAnimation(Md3.AnimationId.LEGS_LAND)
		elif Math.Abs(Dir.X) >= walkingThreshold:
			if (Dir.X > 0f) ^ (LookDirection.X > 0f):
				Character.LowerAnimation = Character.Model.GetAnimation(Md3.AnimationId.LEGS_BACK)
				Character.WalkDirection = -Character.WalkDirection
			elif Math.Abs(Dir.X) >= runningThreshold:
				Character.LowerAnimation = Character.Model.GetAnimation(Md3.AnimationId.LEGS_RUN)
			elif Math.Abs(Dir.X) >= walkingThreshold:
				Character.LowerAnimation = Character.Model.GetAnimation(Md3.AnimationId.LEGS_WALK)
		else:
			Character.LowerAnimation = Character.Model.GetAnimation(Md3.AnimationId.LEGS_IDLE)		

		// Weapon controls

		// Reset sensor
		OnGround = false
		
		// Animations etc
		Character.Tick(dt)
		
		
	public override def Update():
		super.Update()
		if Body.GetAngle() != 0f:
			Body.SetXForm(Body.GetPosition(), 0f)
			Body.SetAngularVelocity(0.0f)
		_Position.Y = Body.GetPosition().Y - 0.9f					
	
	public override def Render():
		Character.WeaponModel = Weapon
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