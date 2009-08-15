namespace Core.Common

import System
import System.IO

class Logger:
"""Description of Logger"""
	public static _writer as TextWriter	
	public static def Create(writer as TextWriter):
		_writer = writer

def Log(text as string):
	Logger._writer.WriteLine(text)
	Logger._writer.Flush()
	
def Debug(text as string):
	Logger._writer.WriteLine(text)
	Logger._writer.Flush()
	
def Warning(text as string):
	Logger._writer.WriteLine("*** WARNING *** ${text}")
	Logger._writer.Flush()
