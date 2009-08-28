namespace Floored.Shapes

interface IShape(Core.Graphics.IRenderable):
	def Render()
	"""Renders the shape at the world origin"""

	def CreatePhysicalRepresentation() as Box2DX.Collision.ShapeDef
	"""Builds the physical representation for this shape"""

