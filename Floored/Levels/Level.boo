namespace Floored.Levels

import System
import OpenTK
import Core.Graphics
import Core.Util.Ext
import Floored
import Floored.Shapes
import Box2DX.Common
import Box2DX.Dynamics

class Level:
	World as World
	
	protected def BackgroundBox(material as Material, center as Vector3, dim as Vector3) as GameObject:
		scale = 1f / 3f
		box = Box(dim * scale)
		bodyDef = BodyDef()
		bodyDef.Position = center.AsVec2() * scale
		body = World.CreateBodyWithoutMassFromShape(bodyDef, box.CreatePhysicalRepresentation(), 0.0f, 0.1f, 0.0f)
		shape = body.GetShapeList()
		if center.Z != 0f:
			shape.FilterData.CategoryBits = 0
			shape.FilterData.MaskBits = 0
		result = GameObject(box, body)	
		result.Material = material
		result.Position = center * scale
		return result
	
	protected def CreateBox(material as Material, center as Vector3, dim as Vector3, hasMass as bool) as GameObject:
		scale = 1f / 3f
		box = Box(dim * scale)
		bodyDef = BodyDef()
		bodyDef.Position = center.AsVec2() * scale
		body = World.CreateBodyWithoutMassFromShape(bodyDef, box.CreatePhysicalRepresentation(), 50.0f, 0.1f, 0.0f)
		if hasMass:
			body.SetMassFromShapes()
		result = GameObject(box, body)		
		result.Material = material
		result.Position = center * scale
		return result
	
	public def constructor(world as World):
		World = world
		
		wall = Material('Wall')
		wall.DiffuseTexture = Texture.Load('../Data/Textures/wall.jpg')
		wall.NormalTexture = Texture.Load('../Data/Textures/wall_n.jpg')
		
		wood = Material('Wood')
		wood.DiffuseTexture = Texture.Load('../Data/Textures/wood.jpg')
		wood.NormalTexture = Texture.Load('../Data/Textures/wood_n.jpg')
		
		grass = Material('Grass')
		grass.DiffuseTexture = Texture.Load('../Data/Textures/ground.jpg')
		grass.NormalTexture = Texture.Load('../Data/Textures/ground_n.jpg')
		
		crate = Material('Crate')
		crate.DiffuseTexture = Texture.Load('../Data/Textures/crate.png')
		crate.NormalTexture = Texture.Load('../Data/Textures/wood_n.jpg')
		
		Boxes = List[of GameObject]()
		/*Boxes.Add(CreateBox(wall, Vector3(0, 0, 0), Vector3(30.0F, 2.0F, 4.0F), false))
		Boxes.Add(BackgroundBox(wall, Vector3(0, 0, 8.0F), Vector3(30.0F, 2.0F, 4.0F)))
		Boxes.Add(BackgroundBox(wall, Vector3(0, 0, -8.0F), Vector3(30.0F, 2.0F, 4.0F)))
		//Boxes.Add(BackgroundBox(wall, Vector3(0, 4.0F, -18f), Vector3(30f, 10f, 0.2f)))
		Boxes.Add(CreateBox(wall, Vector3(20.0F, 13.0F, 0), Vector3(20.0F, 0.20000000298F, 12.0F), false))
		*/
		
		Boxes.Add(CreateBox(crate, Vector3(15.0F, 30.0F, 0.0F), Vector3(2.0F, 2.0F, 2.0F), true))
		Boxes.Add(CreateBox(crate, Vector3(12.0F, 30.0F, 0.0F), Vector3(2.0F, 2.0F, 2.0F), true))
		Boxes.Add(CreateBox(crate, Vector3(18.0F, 10.0F, 0.0F), Vector3(2.0F, 2.0F, 2.0F), true))
		Boxes.Add(CreateBox(crate, Vector3(12.0F, 30.0F, 0.0F), Vector3(2.0F, 2.0F, 2.0F), true))
		Boxes.Add(CreateBox(crate, Vector3(18.0F, 40.0F, 0.0F), Vector3(3.0F, 3.0F, 3.0F), true))
		Boxes.Add(CreateBox(crate, Vector3(-12.0F, 4.0F, 0), Vector3(2.0F, 2.0F, 2.0F), true))
		
		
		/*Boxes.Add(BackgroundBox(wall, Vector3(-15.0F, 12.0F, 0.0F), Vector3(0.5F, 1.5F, 12.0F)))
		Boxes.Add(BackgroundBox(wall, Vector3(-15.0F, 5.0F, 8.0F), Vector3(0.5F, 6.0F, 4.0F)))
		Door = CreateBox(wood, Vector3(-15.0F, 5.0F, 0), Vector3(0.20000000298F, 6.0F, 4.0F), false)
		Boxes.Add(Door)
		Boxes.Add(BackgroundBox(wall, Vector3(-15.0F, 5.0F, -8.0F), Vector3(0.5F, 6.0F, 4.0F)))
		Boxes.Add(BackgroundBox(wall, Vector3(15.0F, 12.0F, 0.0F), Vector3(0.5F, 1.5F, 12.0F)))
		Boxes.Add(BackgroundBox(wall, Vector3(15.0F, 5.0F, 8.0F), Vector3(0.5F, 6.0F, 4.0F)))
		Door = CreateBox(wood, Vector3(15.0F, 5.0F, 0), Vector3(0.20000000298F, 6.0F, 4.0F), false)
		Boxes.Add(Door)
		Boxes.Add(BackgroundBox(wall, Vector3(15.0F, 5.0F, -8.0F), Vector3(0.5F, 6.0F, 4.0F)))*/

		for box in Boxes:
			World.Objects.Add(box)
			
		// Create an elevator
		World.Objects.Add(Objects.Environment.Elevator(World, Vec2(-10, 7), Vec2(-10, 0), grass))
		World.Objects.Add(Objects.Environment.Elevator(World, Vec2(-5, 7), Vec2(-5, 20), grass))
		World.Objects.Add(Objects.Environment.Elevator(World, Vec2(-2, 7), Vec2(10, 7), grass))