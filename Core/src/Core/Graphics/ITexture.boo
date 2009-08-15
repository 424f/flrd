namespace Core.Graphics

import System
import Core.Math

interface ITexture:
	def Bind()
	def Render(pos as Rect)		
	def Render(source as Rect, dest as Rect)


