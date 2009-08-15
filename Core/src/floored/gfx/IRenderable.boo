namespace Core.Graphics

interface IRenderable:
	def Render()
  
class DummyRenderable(IRenderable):
	def Render():
		pass
