namespace Core.Util

import System
import System.IO
import System.Runtime.InteropServices

class Structs:
	static def Create(stream as Stream, type as Type):
		buf = array(byte, Marshal.SizeOf(type))
		stream.Read(buf, 0, Marshal.SizeOf(type))
		return Create(buf, type)
	
	static def Create(buf as (byte), type as Type):
		handle as GCHandle = GCHandle.Alloc(buf, GCHandleType.Pinned)
		ptr as IntPtr = handle.AddrOfPinnedObject()
		result = Marshal.PtrToStructure(ptr, type)
		handle.Free()
		return result
		
	static def Print(obj as object):
		for field as Reflection.FieldInfo in obj.GetType().GetFields():
			print "${field.Name} = ${field.GetValue(obj)}"		
