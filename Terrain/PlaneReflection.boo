namespace BooLandscape

import System
import OpenTK.Graphics
import Tao.OpenGl.Gl

class PlaneReflection:
"""
Renders reflections of objects to a floor
TODO: more generic version
"""
	public def constructor():
		pass
		
	public def render(callbackObjects as callable, callbackFloor as callable):	
		# Set up clipping plane 
		clipEqr = (0.0, -1.0, 0.0, 0.0)
		
		# Render stencil func floor
		GL.Disable(EnableCap.DepthTest)
		//GL.Enable(EnableCap.Lighting)
		GL.Enable(EnableCap.StencilTest)
		GL.ColorMask(false, false, false, false)
		GL.StencilFunc(StencilFunction.Always, 1, 1)
		GL.StencilOp(StencilOp.Keep, StencilOp.Keep, StencilOp.Replace)
		callbackFloor()
		
		# Render reflected copy of objects
		GL.ColorMask(true, true, true, true)
		GL.Enable(EnableCap.DepthTest)
		GL.StencilFunc(StencilFunction.Equal, 1, 1)
		GL.StencilOp(StencilOp.Keep, StencilOp.Keep, StencilOp.Keep)
		GL.PushMatrix()
		glEnable(GL_CLIP_PLANE0)
		glClipPlane(GL_CLIP_PLANE0, clipEqr)
		//GL.Translate(0, 0.0f, 0)
		GL.Scale(1.0, -1.0, 1.0)
		GL.Color4(1, 1, 1, 1)
		callbackObjects()
		GL.PopMatrix()
		glDisable(GL_CLIP_PLANE0)
		glDisable(GL_STENCIL_TEST)
		
		# Blend floor onto the screen
		GL.Enable(EnableCap.Blend)
		//GL.Disable(EnableCap.Lighting)
		GL.BlendFunc(OpenTK.Graphics.BlendingFactorSrc.SrcAlpha, OpenTK.Graphics.BlendingFactorDest.OneMinusSrcAlpha);
		GL.Color4(1, 1, 1, 0.85f)
		callbackFloor()
		//GL.Enable(EnableCap.Lighting)
		GL.Disable(EnableCap.Blend)
		GL.Color4(1, 1, 1, 1.0f)
		
		//GL.Enable(EnableCap.Lighting)


