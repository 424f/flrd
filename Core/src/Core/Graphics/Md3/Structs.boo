namespace Core.Graphics.Md3

import System
import System.Runtime.InteropServices
import OpenTK

struct ModelHeader:
	Magic as Int32
	Version as Int32
	[MarshalAs(UnmanagedType.ByValTStr, SizeConst:64)] Name as string
	Flags as Int32
	
	NumFrames as Int32
	NumTags as Int32
	NumMeshes as Int32
	NumSkins as Int32
	
	OffsetFrames as Int32
	OffsetTags as Int32
	OffsetMeshes as Int32
	OffsetEOF as Int32

struct Vec3f:
	X as single
	Y as single
	Z as single
	
	def ToString() as string:
		return "${X}, ${Y}, ${Z}"
		
	def ToVector():
		return Vector3(X, Y, Z)

	def constructor(X as single, Y as single, Z as single):
		self.X = X
		self.Y = Y
		self.Z = Z
		
	static def op_UnaryNegation(v as Vec3f):
		return Vec3f(-v.X, -v.Y, -v.Z)
		
struct Frame:
	MinBounds as Vec3f
	MaxBounds as Vec3f
	LocalOrigin as Vec3f
	Radius as single
	[MarshalAs(UnmanagedType.ByValTStr, SizeConst:16)] Name as string

struct MeshHeader:
	Ident as Int32
	[MarshalAs(UnmanagedType.ByValTStr, SizeConst:64)] Name as string
	Flags as Int32
	
	NumFrames as Int32
	NumSkins as Int32
	NumVertices as Int32
	NumTriangles as Int32
	
	OffsetTriangles as Int32
	OffsetSkins as Int32
	OffsetTexCoords as Int32
	OffsetVertices as Int32
	OffsetEOF as Int32

struct Triangle:
	I1 as Int32
	I2 as Int32
	I3 as Int32
	
	Indices as (Int32):
		get: return (I1, I2, I3)

struct TexCoords:
	U as single
	V as single
	
struct Skin:
	[MarshalAs(UnmanagedType.ByValTStr, SizeConst:64)] _Name as string
	Index as Int32
	
	Name:
		get: return _Name

struct EncodedVertex:
	X as short
	Y as short
	Z as short
	Normals as short
	
	Normal0:
		get: return (Normals >> 8) & 255
		
	Normal1:
		get: return Normals & 255

struct Vertex:
	Pos as Vec3f
	Normal as Vec3f
	Tu as single
	Tv as single

struct Tag:
	[MarshalAs(UnmanagedType.ByValTStr, SizeConst:64)] Name as string
	Origin as Vec3f
	[MarshalAs(UnmanagedType.ByValArray, SizeConst:3)] Axis as (Vec3f)
