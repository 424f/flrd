using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows;
using System.Windows.Forms;
using Core.Util;
using Core.Graphics;
using Core.Graphics.Md3;
using OpenTK.Math;
using OpenTK.Graphics;
using OpenTK;
using Tao.OpenGl;
using LevelEditor.Tools;
using Box2DX.Dynamics;
using Box2DX.Collision;
using Box2DX.Common;

namespace LevelEditor
{
	/// <summary>
	/// Description of EditorRenderer.
	/// </summary>
	public class EditorRenderer : ContactListener
	{
		public MainForm Form;
		public GLControl GLControl;
		public ITool ActiveTool = new NullTool();
		public Texture TextureRock;
		public Texture TextureBump;
		
		// Data
		public List<GameObject> GameObjects;
		public List<ITweener> Tweeners;	
		public List<Box> Boxes;
		Vector3 Dir;
		Dictionary<Keys, bool> KeyStates = new Dictionary<Keys, bool>();
		
		// Camera
		public Camera Camera;
		public float ZoomTarget = 0.0f;
		
		// Picking
		public Vector3 Origin = Vector3.Zero;
		public Vector3 Direction = Vector3.Zero;
		public Box SelectedBox;
		public Point LastMousePosition;
		
		// Graphics
		public ShaderProgram Program;
		Light Light;
		Skydome Skydome;
		CharacterModel Model;
		CharacterInstance Character;
		public ShaderProgram Md3Program;
		Box Door;
		Model Weapon;
		float GotoLevel = 0.0f;
		
		// Physics
		World World;
		Body PlayerBody;
		
		RocketObject rocket;
		Model rocketModel;
		
		// Spring
		GameObject base1, base2, platform;
		
		// Particles
		ParticleEngine particles;
			
		Dictionary<string, Texture> Textures = new Dictionary<string, Texture>();
		
		public Texture GetTexture(string fileName) {
			if(!Textures.ContainsKey(fileName))
				Textures[fileName] = Texture.Load(fileName);
			return Textures[fileName];
		}
		
		public Box BackgroundBox(Material material, Vector3 center, Vector3 dim) {
			Box result = new Box(material, center, dim);
			result.IsStatic = true;
			result.OnGameLayer = false;
			return result;
		}
		
		public EditorRenderer(MainForm form)
		{
			Form = form;
			GLControl = form.GLControl;
			Tweeners = new List<ITweener>();
			Boxes = new List<Box>();
			GameObjects = new List<GameObject>();
			
			// Set up camera
			Camera = new Camera(
				new Vector3(0, 20, 50),
				new Vector3(0, 0, 0),
				new Vector3(0, 1, 0)
			);
			
			// Create materials
			Material wall = new Material("Wall");
			wall.DiffuseTexture = GetTexture("../Data/Textures/wall.jpg");
			wall.NormalTexture = GetTexture("../Data/Textures/wall_n.jpg");
			
			Material wood = new Material("Wood");
			wood.DiffuseTexture = GetTexture("../Data/Textures/wood.jpg");
			wood.NormalTexture = GetTexture("../Data/Textures/wood_n.jpg");

			Material grass = new Material("Grass");
			grass.DiffuseTexture = GetTexture("../Data/Textures/ground.jpg");
			grass.NormalTexture = GetTexture("../Data/Textures/ground_n.jpg");			

			Material crate = new Material("Crate");
			crate.DiffuseTexture = GetTexture("../Data/Textures/crate.png");
			crate.NormalTexture = GetTexture("../Data/Textures/wood_n.jpg");
			
			
			//
			
			Boxes.Add(new Box(wall, new Vector3(0, 0, 0), new Vector3(30.0f, 2.0f, 4.0f)));
			Boxes.Add(BackgroundBox(wall, new Vector3(0, 0, 8.0f), new Vector3(30.0f, 2.0f, 4.0f)));
			Boxes.Add(BackgroundBox(wall, new Vector3(0, 0, -8.0f), new Vector3(30.0f, 2.0f, 4.0f)));
			Boxes.Add(BackgroundBox(wall, new Vector3(0, 4.0f, -12.2f), new Vector3(30.0f, 10.0f, 0.2f)));
			
			// Front box
			//Boxes.Add(new Box(wall, new Vector3(0, 4.0f, 12.2f), new Vector3(20.0f, 10.0f, 0.2f)));

			// Create ceiling
			Boxes.Add(new Box(wall, new Vector3(20.0f, 13.0f, 0), new Vector3(20.0f, 0.2f, 12.0f)));

			// Create a crate
			Box Crate = new Box(crate, new Vector3(-12.0f, 4.0f, 0), new Vector3(2.0f, 2.0f, 2.0f));
			Crate.IsStatic = false;
			Boxes.Add(Crate);			

			// Create a crate
			Crate = new Box(crate, new Vector3(12.0f, 30.0f, 0.0f), new Vector3(2.0f, 2.0f, 2.0f));
			Crate.IsStatic = false;
			Boxes.Add(Crate);			

			Box Crate2 = new Box(crate, new Vector3(18.0f, 40.0f, 0.0f), new Vector3(3.0f, 3.0f, 3.0f));
			Crate2.IsStatic = false;
			Boxes.Add(Crate2);						
			
			// Create a door
			Boxes.Add(BackgroundBox(wall, new Vector3(-15.0f, 12.0f, 0.0f), new Vector3(0.5f, 1.5f, 12.0f)));
			Boxes.Add(BackgroundBox(wall, new Vector3(-15.0f, 5.0f, 8.0f), new Vector3(0.5f, 6.0f, 4.0f)));
			Door = new Box(wood, new Vector3(-15.0f, 5.0f, 0), new Vector3(0.2f, 6.0f, 4.0f));
			Boxes.Add(Door);
			Boxes.Add(BackgroundBox(wall, new Vector3(-15.0f, 5.0f, -8.0f), new Vector3(0.5f, 6.0f, 4.0f)));
			
			
			// Create a door
			Boxes.Add(BackgroundBox(wall, new Vector3(15.0f, 12.0f, 0.0f), new Vector3(0.5f, 1.5f, 12.0f)));
			Boxes.Add(BackgroundBox(wall, new Vector3(15.0f, 5.0f, 8.0f), new Vector3(0.5f, 6.0f, 4.0f)));
			Door = new Box(wood, new Vector3(15.0f, 5.0f, 0), new Vector3(0.2f, 6.0f, 4.0f));
			Boxes.Add(Door);
			Boxes.Add(BackgroundBox(wall, new Vector3(15.0f, 5.0f, -8.0f), new Vector3(0.5f, 6.0f, 4.0f)));
			
			// Scale all boxes
			foreach(Box b in Boxes) {
				b.Center /= 3.0f;
				b.Dim /= 3.0f;
			}
			
			// Load textures
			TextureRock = GetTexture("../Data/Textures/floor.jpg");
			TextureBump = GetTexture("../Data/Textures/floor_n.jpg");
		
			// Load shaders
			Program = new ShaderProgram();
			Shader VertexShader = new Shader(ShaderType.VertexShader, "Shaders/bump.vert");
			Shader FragmentShader = new Shader(ShaderType.FragmentShader, "Shaders/bump.frag");
			Program.Attach(VertexShader);
			Program.Attach(FragmentShader);
			Program.Link();
			
			// Load md3 shader
			Md3Program = new ShaderProgram();
			Shader VertexShader2 = new Shader(ShaderType.VertexShader, "Shaders/md3_vertex.glsl");
			Shader FragmentShader2 = new Shader(ShaderType.FragmentShader, "Shaders/md3_fragment.glsl");
			Md3Program.Attach(VertexShader2);
			Md3Program.Attach(FragmentShader2);
			Md3Program.Link();			
			
			// Create a light
			Light = new Light(0);
			
			// Event handlers
			GLControl.MouseDown += MouseDown;
			GLControl.MouseMove += MouseMove;
			GLControl.Resize += delegate(object sender, EventArgs e) {
				GL.Viewport(0, 0, GLControl.Width, GLControl.Height);
				GL.MatrixMode(MatrixMode.Projection);
				GL.LoadIdentity();
				OpenTK.Graphics.Glu.Perspective(20.0, GLControl.Width / (double)(GLControl.Height), 1.0, 6000.0);			
			};
			
			Form.CreateBoxButton.Click += delegate(object sender, EventArgs e) {
				Vector3 center = new Vector3(float.Parse(Form.BoxX.Text), float.Parse(Form.BoxY.Text), float.Parse(Form.BoxZ.Text));
				Vector3 dim = new Vector3(float.Parse(Form.BoxDimX.Text), float.Parse(Form.BoxDimY.Text), float.Parse(Form.BoxDimZ.Text));
				Box box = new Box(grass, center, dim);
				Boxes.Add(box);
			};
			

			GLControl.KeyUp += delegate(object sender, KeyEventArgs e) { 
				KeyStates.Remove(e.KeyCode);
			};
				
			GLControl.KeyDown += delegate(object sender, KeyEventArgs e) {
				if(!KeyStates.ContainsKey(e.KeyCode))
					KeyStates.Add(e.KeyCode, true);
				
/*
				if(e.KeyCode == Keys.W) {
					//Dir = new Vector3(0, 0, -1.0f);
					if(GotoLevel == 0.0f) 
						GotoLevel = -8.0f;
					else if(GotoLevel == 8.0f)
						GotoLevel = 0.0f;
					else
						return;
				} else if(e.KeyCode == Keys.S) {
					//Dir = new Vector3(0, 0, 1.0f);
					if(GotoLevel == 0.0f) 
						GotoLevel = 8.0f;
					else if(GotoLevel == -8.0f)
						GotoLevel = 0.0f;
					else
						return;					
				}
				
				if(Dir != Vector3.Zero) {
					Character.WalkDirection = Dir;
					Character.LookDirection = Dir;
				}*/
			};
			
			// Skydome
			Skydome = new Skydome(GetTexture("../Data/Textures/SkyBlue.jpg"), 500f);
			
			// Load a character with weapon
			Model = new CharacterModel("../Data/Models/Players/sergei/");
			CharacterSkin skin = Model.Skins["default"];
			Character = skin.CreateInstance();
			Character.Position = new Vector3(0, 4.5f, 0);
			Character.LowerAnimation = Character.Model.GetAnimation(AnimationId.LEGS_WALK);
			Weapon = new Model("../Data/Models/Weapons/grenadel/grenadel.md3");
			Character.WeaponModel = Weapon;
			Enemy = Model.Skins["red"].CreateInstance();
			Enemy.LowerAnimation = Character.Model.GetAnimation(AnimationId.LEGS_IDLE_CR);
			Enemy.UpperAnimation = Character.Model.GetAnimation(AnimationId.TORSO_GESTURE);
			Enemy.Position = new Vector3(1.5f, 1.5f, 8.0f / 3.0f);
			
			// Physics
			// World
			AABB worldAAB = new AABB();
			worldAAB.LowerBound.Set(-200.0f, -200.0f);
			worldAAB.UpperBound.Set(200.0f, 200.0f);
			// Gravity
			Vec2 gravity = new Vec2(0.0f, -10.0f);
			bool doSleep = true;
			World = new World(worldAAB, gravity, doSleep);
			World.Gravity = new Vec2(0, -20.0f);
			
			// Ground body
			BodyDef groundBodyDef = new BodyDef();
			groundBodyDef.Position.Set(0.0f, 0.0f);
			Body groundBody = World.CreateBody(groundBodyDef);
			PolygonDef groundShapeDef = new PolygonDef();
			groundShapeDef.SetAsBox(180.0f, 0.2f);
			groundBody.CreateShape(groundShapeDef);
			
			
			
			
			// Add a body for every box
			Body Body1 = null;
			Body Body2 = null;
			foreach(Box b in Boxes) {
				Body body = null;
				if(b.OnGameLayer) {
					BodyDef bodyDef = new BodyDef();
					bodyDef.Position.Set(b.Center.X, b.Center.Y);
					body = World.CreateBody(bodyDef);
					PolygonDef shapeDef = new PolygonDef();
					shapeDef.SetAsBox(b.Dim.X, b.Dim.Y);
					shapeDef.Density = 1.0f;
					shapeDef.Friction = 2.0f;
					body.CreateShape(shapeDef);
					shapeDef.Restitution = 0.0f;
					if(!b.IsStatic) {
						body.SetMassFromShapes();
						shapeDef.Restitution = 0.5f;
					}
					
				}
				if(b == Crate)
					Body1 = body;
				if(b == Crate2)
					Body2 = body;
				BoxObject bo = new BoxObject(b, body);
				//body.SetUserData(bo);
				GameObjects.Add(bo);
			}
			
			// Attach two crates
			DistanceJointDef jointDef = new DistanceJointDef();
			jointDef.Body1 = Body1;
			jointDef.Body2 = Body2;
			jointDef.CollideConnected = true;
			jointDef.Length = 10.0f;
			World.CreateJoint(jointDef);
			
			// Player body
			if(true) {
				BodyDef bodyDef = new BodyDef();
				bodyDef.Position.Set(Character.Position.X, Character.Position.Y + 2.0f);
				PlayerBody = World.CreateBody(bodyDef);
				PolygonDef shapeDef = new PolygonDef();
				shapeDef.SetAsBox(0.5f, 1.0f);
				shapeDef.Density = 0.3f;
				shapeDef.Friction = 0.1f;
				shapeDef.Restitution = 0.0f;
				PlayerBody.CreateShape(shapeDef);
				PlayerBody.SetMassFromShapes();
			}
			
			// Add a rope
			base1 = new GameObject(new NullRenderable(), CreateBoxBody(new Vec2(-2.0f, 15.0f), new Vec2(0.2f, 0.2f), 0.0f));
			GameObjects.Add(base1);
			base2 = new GameObject(new NullRenderable(), CreateBoxBody(new Vec2(2.0f, 15.0f), new Vec2(0.2f, 0.2f), 0.0f));
			GameObjects.Add(base2);
			platform = new BoxObject(new Box(crate, Vector3.Zero, new Vector3(1.0f, 0.1f, 0.5f)), CreateBoxBody(new Vec2(1.0f, 5.0f), new Vec2(1.0f, 0.1f), 0.1f));
			GameObjects.Add(platform);
			
			float length = 4.0f;
			int sections = 10;
			float r = length / (1 + sections);
			Body lastSection = null;
			if(true) {
				foreach(GameObject go in new GameObject[]{ base1, base2 }) {
					Vec2 pos = go.Body.GetPosition();
					Vec2 dpos = platform.Body.GetPosition() - pos;
					dpos.Normalize();
					dpos *= 1.0f / (sections + 1);
					for(int i = 0; i <= sections; ++i) {
						pos += dpos;
						DistanceJointDef jointD = new DistanceJointDef();
						if(i == 0)
							jointD.Body1 = go.Body;
						else 
							jointD.Body1 = lastSection;
						if(i == sections) {
							jointD.Body2 = platform.Body;
							if(go == base1) {
								jointD.LocalAnchor2.Set(-1.0f, 0.0f);
							} else {
								jointD.LocalAnchor2.Set(1.0f, 0.0f);
							}							
						} else {
							lastSection = CreateSphereBody(pos, r, 0.1f);
							jointD.Body2 = lastSection;
						}
						jointD.CollideConnected = false;
						jointD.Length = r;
						if(i == sections) {

						}
						World.CreateJoint(jointD);
					}
				}
			}

			
			// Add ground plane
			if(true) {
				//Body body = new Body(World);
				//body.Geometry = 
				//new PlaneGeometry(World.Space, 0.0f, 1.0f, 0.0f, 0.0f);
				//GameObjects.Add(new GameObject(new NullRenderable(), body));
			}
			
			// Set up particles
			particles = new ParticleEngine(null);
			
			rocketModel = new Model("../Data/Models/Ammo/rocket/rocket.md3");
			rocketModel.Scale = 0.025f;
			
			World.SetContactListener(this);
		}
		
		Body CreateBoxBody(Vec2 position, Vec2 dim, float density) {
			BodyDef bodyDef = new BodyDef();
			bodyDef.Position = position;
			Body body = World.CreateBody(bodyDef);
			PolygonDef shapeDef = new PolygonDef();
			shapeDef.SetAsBox(dim.X, dim.Y);
			shapeDef.Density = density;
			shapeDef.Friction = 5.1f;
			shapeDef.Restitution = 0.0f;
			body.CreateShape(shapeDef);
			body.SetMassFromShapes();			
			return body;
		}

		Body CreateSphereBody(Vec2 position, float r, float density) {
			BodyDef bodyDef = new BodyDef();
			bodyDef.Position = position;
			Body body = World.CreateBody(bodyDef);
			CircleDef shapeDef = new CircleDef();
			shapeDef.Radius = r;
			shapeDef.Density = density;
			shapeDef.Friction = 0.0f;
			shapeDef.Restitution = 0.0f;
			shapeDef.Filter.MaskBits = 0;
			body.CreateShape(shapeDef);
			body.SetMassFromShapes();			
			return body;
		}
		
		
		public CharacterInstance Enemy;
		
		public int FramesRendered = 0;
		public float TimeElapsed = 0.0f;
		public void Render() {
			// Calculate scene
			TimeElapsed += 0.025f;
			FramesRendered += 1;

			Camera.Eye = new Vector3(Character.Position.X, Character.Position.Y + 1.0f, Camera.Eye.Z);
			Camera.LookAt = Character.Position;
			if(System.Math.Abs(ZoomTarget) >= 1.0f) {
				float d = ZoomTarget / 3.0f;
				Camera.Eye += new Vector3(0, 0, d);
				Camera.LookAt += new Vector3(0, 0, d);
				ZoomTarget -= d;
				System.Diagnostics.Debug.WriteLine(ZoomTarget);
			} else {
				ZoomTarget = 0.0f;
			}
			
			Light.Position[0] = (float)System.Math.Cos(TimeElapsed)*5.0f;
			Light.Position[1] = 20.0f + (float)System.Math.Sin(TimeElapsed)*5.0f;
			Light.Position[2] = 0.0f;
			Light.Position[3] = 1.0f;
			
			Light.Position[0] = Character.Position.X + (float)System.Math.Cos(TimeElapsed)*5.0f;
			Light.Position[1] = Character.Position.Y + 5.0f;
			Light.Position[2] = Character.Position.Z + (float)System.Math.Sin(TimeElapsed)*5.0f + 20.0f;
			
			/*Vector3 center = Door.Center;
			center.Z = 5.0f - 12.0f + (float)Math.Sin(TimeElapsed)*6.0f;
			Door.Center = center;*/
			
			// Controls
			PlayerBody.WakeUp();
			Vec2 dir2 = PlayerBody.GetLinearVelocity();
			Dir = new Vector3(dir2.X, dir2.Y, 0.0f);
			if(KeyStates.ContainsKey(Keys.Space))
				Dir.Y = 7.0f;
			const float walkingThreshold = 2.0f;
			const float runningThreshold = 4.0f;
			const float maxSpeed = 10.5f;
			const float accel = 2.0f;
			bool walking = Dir.Length >= walkingThreshold;
			bool running = Dir.Length >= runningThreshold;
			if(KeyStates.ContainsKey(Keys.D)) {
				Dir.X += System.Math.Min(accel, maxSpeed - Dir.X);
			}
			else if(KeyStates.ContainsKey(Keys.A)) {
				Dir.X -= System.Math.Min(accel, maxSpeed + Dir.X);
			} else {
				Dir.X /= 2.0f;
			}
			//Character.Position += Dir;
			PlayerBody.SetLinearVelocity(new Vec2(Dir.X, Dir.Y));
			
			if(Character.LowerAnimation == Character.Model.GetAnimation(AnimationId.BOTH_DEATH_2)) {
			   	
			} /*else if(Dir.Y <= -10.0f) {
			   	Character.LowerAnimation = Character.Model.GetAnimation(AnimationId.BOTH_DEATH_2);
			   	Character.UpperAnimation = Character.Model.GetAnimation(AnimationId.BOTH_DEATH_2);
			} */ else if(Dir.Y > 0.1f) {
				Character.LowerAnimation = Character.Model.GetAnimation(AnimationId.LEGS_JUMP);
			} else if(Dir.Y < -0.1f) {
				Character.LowerAnimation = Character.Model.GetAnimation(AnimationId.LEGS_LAND);
			}
			else if(Dir.Length >= runningThreshold) {
				Character.LowerAnimation = Character.Model.GetAnimation(AnimationId.LEGS_RUN);
			}
			else if(Dir.Length >= walkingThreshold) {
				Character.LowerAnimation = Character.Model.GetAnimation(AnimationId.LEGS_WALK);
			}
			else {
				Character.LowerAnimation = Character.Model.GetAnimation(AnimationId.LEGS_IDLE);
			}

			
			
			if(Dir.Length >= 0.2f) {
				Character.WalkDirection = Dir;
				
				float ydir = 0.0f;
				if(KeyStates.ContainsKey(Keys.I))
					ydir += 1.0f;
				if(KeyStates.ContainsKey(Keys.K))
					ydir -= 1.0f;
				Character.LookDirection = new Vector3(System.Math.Sign(Dir.X)*1.0f, ydir, 0.0f);
				
			}
			
			// Move between layers
			if(Character.Position.Z != GotoLevel) {
				float z = (Character.Position.Z + GotoLevel) / 2.0f;
				Character.Position = new Vector3(Character.Position.X, Character.Position.Y, z);
			}
			
			// Create explosion
			if(KeyStates.ContainsKey(Keys.E)) {
				Vec2 center = PlayerBody.GetPosition();
				// Set off rocket
				Vec2 dir = new Vec2(Character.LookDirection.X, Character.LookDirection.Y);
				dir.Normalize();
				rocket = new RocketObject(rocketModel, CreateBoxBody(center + dir*2.0f, new Vec2(0.4f, 0.2f), 0.2f));
				rocket.Body.ApplyImpulse(dir * 2.0f, Vec2.Zero);
				//rocket.AutoTransform = true;
				//GameObjects.Add(rocket);
				KeyStates.Remove(Keys.E);
			}
			
			// Physics
			float dt = 0.025f;
			int velocityIterations = 10;
			int positionIterations = 1;
			World.Step(dt, velocityIterations, positionIterations);
			
			// Update player
			if(System.Math.Abs(PlayerBody.GetAngle()) >= 0.10)
				PlayerBody.SetXForm(PlayerBody.GetPosition(), 0.0f);
			Vec2 pos = PlayerBody.GetPosition();
			Vec2 vel = PlayerBody.GetLinearVelocity();
			Character.Position = new Vector3(pos.X, pos.Y - 1.0f, 0.0f);
			System.Diagnostics.Debug.WriteLine("FPS " + FramesRendered / TimeElapsed);
			
			// Render scene
			GL.ClearColor(System.Drawing.Color.SkyBlue);
			GL.Clear(ClearBufferMask.ColorBufferBit | ClearBufferMask.DepthBufferBit | ClearBufferMask.StencilBufferBit);
			
			GL.Disable(EnableCap.Texture2D);
			GL.Enable(EnableCap.DepthTest);
			GL.Enable(EnableCap.Blend);
			GL.BlendFunc(BlendingFactorSrc.SrcAlpha, BlendingFactorDest.OneMinusSrcAlpha);
			
			GL.MatrixMode(MatrixMode.Modelview);
			GL.LoadIdentity();
			Camera.Push();	
			
			GL.PushMatrix();
			GL.Translate(0, -250, 0);
			GL.Translate(Camera.Eye);
			GL.Rotate(45.0, 0, 1, 0);
			Skydome.Render();
			GL.PopMatrix();

			// Render light
			bool renderLight = false;
			if(renderLight) {
				GL.Disable(EnableCap.Texture2D);
				GL.Color4(System.Drawing.Color.Yellow);
				GL.PushMatrix();
				GL.Begin(BeginMode.Quads);
				Vector3 lightPos = new Vector3(Light.Position[0], Light.Position[1], Light.Position[2]);
				GL.Vertex3(lightPos + new Vector3(-1.0f, -1.0f, 0.0f));
				GL.Vertex3(lightPos + new Vector3(1.0f, -1.0f, 0.0f));
				GL.Vertex3(lightPos + new Vector3(1.0f, 1.0f, 0.0f));
				GL.Vertex3(lightPos + new Vector3(-1.0f, 1.0f, 0.0f));
				GL.End();
				GL.PopMatrix();
			}
			// Set up light
			//Light.Position = new float[]{ 1.0f, 40.0f, 40.0f, 1.0f };
			Light.Enable();
	
			GL.Enable(EnableCap.Texture2D);
			Character.UpperAnimation = Character.Model.GetAnimation(AnimationId.TORSO_STAND);
			Character.Tick(0.025f);
			Character.Scale = 0.03f;
			Enemy.Tick(0.025f);
			Enemy.Scale = 0.03f;
			
			Md3Program.Apply();
			Character.Render();
			Enemy.Render();
			GL.Enable(EnableCap.Blend);
			GL.BlendFunc(BlendingFactorSrc.SrcAlpha, BlendingFactorDest.OneMinusSrcAlpha);
			if(rocket != null) 
				rocket.Render();
			GL.Disable(EnableCap.Blend);
			Md3Program.Remove();
			
			Program.Apply();
			//Light.Enable();
			
			// Draw a ground plane
			Program.BindUniformTexture("DiffuseTexture", GetTexture("../Data/Textures/grass.jpg"), 0);
			Program.BindUniformTexture("NormalTexture", GetTexture("../Data/Textures/grass_n.jpg"), 1);
			GL.Color4(System.Drawing.Color.White);
			GL.Begin(BeginMode.Triangles);
			GL.Normal3(0, 1, 0);
			Vector3 tangent = new Vector3(1, 0, 0);
			GL.MultiTexCoord3(TextureUnit.Texture1, ref tangent);
			float tt = 10.0f;
			GL.TexCoord2(0, 0); GL.Vertex3(-100, 0, -100);
			GL.TexCoord2(0, tt); GL.Vertex3(-100, 0, 100);
			GL.TexCoord2(tt, tt); GL.Vertex3(100, 0, 100);
			
			GL.TexCoord2(tt, tt); GL.Vertex3(100, 0, 100);
			GL.TexCoord2(tt, 0); GL.Vertex3(100, 0, -100);
			GL.TexCoord2(0, 0); GL.Vertex3(-100, 0, -100);			
			
			GL.End();
			
			// Obtain a list of objects that disturb view
			List<Box> ignore = PickAll(Camera.Eye, Camera.LookAt - Camera.Eye);
			
			
			// Draw elements
			
			/*String[] names = new String[]{ "DiffuseTexture", "NormalTexture" };
			Texture[] textures = new Texture[] { GetTexture("../Data/Textures/brick.jpg"), GetTexture("../Data/Textures/brick_n.jpg") };
			for(int i = 0; i < names.Length; ++i) {
				Program.BindUniformTexture(names[i], textures[i], i);
			}*/
			
			/*Material lastMaterial = null;
			foreach(Box b in Boxes) {
				if(ignore.Contains(b) && b.Center.Z > Character.Position.Z)
					continue;
				if(lastMaterial != b.Material) {
					b.Material.Apply(Program);
					lastMaterial = b.Material;
				}
				b.Render();
			}
*/
			foreach(GameObject o in GameObjects) {
				o.Update();
			}
			

			Material lastMaterial = null;
			foreach(GameObject o in GameObjects) {
				if(typeof(BoxObject).IsInstanceOfType(o)) {
					BoxObject bo = (BoxObject)o;
					Box b = bo.Box;
					//if(b.OnGameLayer)
					//	b.Selected = true;
					if(lastMaterial != b.Material) {
						b.Material.Apply(Program);
						lastMaterial = b.Material;
					}
				}
				o.Render();
			}
			
			Program.Remove();
			GL.ActiveTexture(TextureUnit.Texture0);

			// Render AABBs
			bool renderPhysics = true;
			if(renderPhysics) {
				AABB aabb;
				GL.Disable(EnableCap.Texture2D);
				GL.Color4(System.Drawing.Color.Green);
				GL.PolygonMode(MaterialFace.FrontAndBack, PolygonMode.Line);
				GL.Begin(BeginMode.Quads);
				for(Body b = World.GetBodyList(); b != null; b = b.GetNext()) {
					for(Shape s = b.GetShapeList(); s!= null; s = s.GetNext()) {
						s.ComputeAABB(out aabb, b.GetXForm());
						GL.Vertex3(aabb.LowerBound.X, aabb.LowerBound.Y, 0.0f);
						GL.Vertex3(aabb.UpperBound.X, aabb.LowerBound.Y, 0.0f);
						GL.Vertex3(aabb.UpperBound.X, aabb.UpperBound.Y, 0.0f);
						GL.Vertex3(aabb.LowerBound.X, aabb.UpperBound.Y, 0.0f);
					}
				}
				
				// Render Joints
				GL.Color4(System.Drawing.Color.Blue);
				for(Joint joint = World.GetJointList(); joint != null; joint = joint.GetNext()) {
					GL.Vertex3(joint.Anchor1.X, joint.Anchor1.Y, 0.0f);
					GL.Vertex3(joint.Anchor2.X, joint.Anchor2.Y, 0.0f);
					GL.Vertex3(joint.GetBody1().GetPosition().X, joint.GetBody1().GetPosition().Y, 0.0f);
					GL.Vertex3(joint.GetBody2().GetPosition().X, joint.GetBody2().GetPosition().Y, 0.0f);				
				}
				
				GL.End();		
				GL.PolygonMode(MaterialFace.FrontAndBack, PolygonMode.Fill);
			
				// Draw picking ray
				GL.Begin(BeginMode.Lines);
				GL.Vertex3(Origin);
				GL.Vertex3(Origin + Direction * 50.0f);
				GL.End();
			}
			
			
			particles.Render();
			
			Camera.Pop();
			
			// Create physics stuff
			
		}

		static float IntersectTriangle(Vector3 rayOrigin, Vector3 rayDirection, Triangle t) {
			// Should use matrix3 to increase performance
			Vertex p1 = t.V0;
			Vertex p2 = t.V1;
			Vertex p3 = t.V2;
			Matrix4 A = new Matrix4(new Vector4(p1.Position-p3.Position),
			                        new Vector4(p2.Position-p3.Position),
			                        new Vector4(-rayDirection),
			                        new Vector4(0, 0, 0, 1));
			try {
				A.Invert();
			} catch(Exception) {
				return float.PositiveInfinity;
			}
			
			Vector4 res = Vector3.Transform(rayOrigin - p3.Position, A);
			if(res.X >= 0 && res.Y >= 0 && res.X <= 1 && res.Y <= 1 && 1 - res.X - res.Y <= 1 && 1 - res.X - res.Y >= 0) {
				return res.Z;
			}
			return float.PositiveInfinity;
		}		

		protected void MouseMove(object Sender, MouseEventArgs e) {			
			// Selecting boxes
			Box b = Pick(e);
			if(b != null) {
				if(SelectedBox != null)
					SelectedBox.Selected = false;
				b.Selected = true;
				SelectedBox = b;
			} else {
				if(SelectedBox != null)
					SelectedBox.Selected = false;				
				SelectedBox = null;
			}
		}
		
		protected void MouseDown(object Sender, MouseEventArgs e) {
			Box b = Pick(e);
			if(b != null) {
				if(SelectedBox != null)
					SelectedBox.Selected = false;
				b.Selected = true;
				SelectedBox = b;
				ActiveTool = new MoveBoxTool(this);
				ActiveTool.Enable();				
				Form.ItemProperties.SelectedObject = b;
			}			
		}
		
		public System.Collections.Generic.List<Box> PickAll(Vector3 rayOrigin, Vector3 rayDirection) {
			System.Collections.Generic.List<Box> result = new List<Box>();
			foreach(Box b in Boxes) {
				Triangle[] triangles = b.GetTriangles();
				if(triangles == null)
					continue;
				for(int i = 0; i < triangles.Length; i += 1) {
					float dist = IntersectTriangle(rayOrigin, rayDirection, triangles[i]);
					if(!float.IsInfinity(dist)) {
						result.Add(b);
					}
				}
			}			
			return result;
		}
		
		public Box Pick(MouseEventArgs e) {
			double[] modelView = Core.Util.Matrices.RawModelViewd;
			double[] projection = Core.Util.Matrices.RawProjectiond;
			int[] viewport = new int[4];
			Gl.glGetIntegerv(Gl.GL_VIEWPORT, viewport);
			Vector3d near;
			Vector3d far;
			
			Tao.OpenGl.Glu.gluUnProject(e.X, viewport[3] - e.Y, 0.0, modelView, projection, viewport, out near.X, out near.Y, out near.Z);
			Tao.OpenGl.Glu.gluUnProject(e.X, viewport[3] - e.Y, 1.0, modelView, projection, viewport, out far.X, out far.Y, out far.Z);
			Vector3 ray = (Vector3)(far - near);
			Origin = Camera.Eye;
			Direction = Vector3.Normalize(ray);
			
			float closest = float.MaxValue;
			Box result = null;
			foreach(Box b in Boxes) {				
				Triangle[] triangles = b.GetTriangles();
				if(triangles == null)
					continue;				
				for(int i = 0; i < triangles.Length; i += 1) {
					float dist = IntersectTriangle(Origin, Direction, triangles[i]);
					if(!float.IsInfinity(dist) && dist < closest) {
						result = b;
						closest = dist;
					}
				}
			}
			return result;
		}
		
		public override void Result(ContactResult point)
		{
			if(rocket == null)
				return;
			if(point.Shape1.GetBody() == rocket.Body ||
			   point.Shape2.GetBody() == rocket.Body)
			{
				if(point.NormalImpulse < 1.0f)
					return;
				Shape[] shapes = new Shape[64];
				Vec2 center = point.Position;
				float forceRadius = 5.0f;
				AABB aabb;
				aabb.LowerBound = center - new Vec2(forceRadius, forceRadius);
				aabb.UpperBound = center + new Vec2(forceRadius, forceRadius);
				int count = World.Query(aabb, shapes, shapes.Length);
				
				for(int i = 0; i < count; ++i) {
					Body body = shapes[i].GetBody();
					Vec2 v = body.GetPosition() - center;
					if(forceRadius < v.Length())
						continue;
					if(v.Length() == 0.0f)
						continue;
					Vec2 force = 20.0f * v * (1.0f / v.Length());
					body.ApplyImpulse(force, body.GetPosition());
					
				}
				
				// Add a few particles
				Random r = new Random();
				for(int i = 0; i < 10; ++i) {
					Vector3 randomDir = new Vector3((float)r.NextDouble() - 0.5f, (float)r.NextDouble() - 0.5f, (float)r.NextDouble() - 0.5f) * 10.0f;
					particles.Add(new Vector3(center.X, center.Y, 0.0f), randomDir, new Vector4(1.0f, 0.0f, 0.0f, 1.0f));
				}
				rocket = null;
			}
			
		}
	}
	
}
