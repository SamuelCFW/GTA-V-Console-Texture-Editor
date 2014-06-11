{**********************************************************************

 GTA V Console Texture Editor
 Copyright (C) 2009-2014  Dageron http://www.Dageron.com

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 See http://www.gnu.org/licenses/

**********************************************************************}

unit Compression.ZLib;

interface

uses SysUtils, Windows, Classes, Zlib;

procedure DecompressZlib(dwOffset: DWORD; inStream, outStream: TStream);
procedure ÑompressZlib(inStream, outStream: TStream);

implementation

procedure DecompressZlib(dwOffset: DWORD; inStream, outStream: TStream);
var
  decompressStream: TDecompressionStream;
  bytesread:integer;
  mainbuffer:array[0..1023] of char;
begin
  inStream.Seek(dwOffset, 0);
  decompressStream:=TDecompressionStream.Create(inStream);
    repeat
      bytesread:=decompressStream.Read(mainbuffer, 1024);
      outStream.Write(mainbuffer, bytesread);
    until bytesread<1024;
  decompressStream.Free;
end;

procedure ÑompressZlib(inStream, outStream: TStream);
var
  compressStream: TCompressionStream;
  bytesread: integer;
  mainbuffer: array[0..1023] of char;
begin
  compressStream:=TCompressionStream.Create(clMax, inStream);
  OutStream.Seek(0,0);
    repeat
      bytesread:=outStream.Read(mainbuffer, 1024);
      compressStream.Write(mainbuffer, bytesread);
    until bytesread<1024;
  compressStream.Free;
end;

end.
