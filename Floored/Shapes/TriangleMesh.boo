﻿namespace Floored.Shapes

import System

abstract class TriangleMesh(Core.Graphics.AbstractRenderable, IShape):
"""Description of TriangleMesh"""
	protected Triangles as (Triangle)
	protected Vertices as (Vertex)

	public def constructor():
		pass

	