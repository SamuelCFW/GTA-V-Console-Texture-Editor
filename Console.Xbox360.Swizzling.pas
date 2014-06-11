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

unit Console.Xbox360.Swizzling;

interface

uses SysUtils, Classes, Windows;

function XGAddress2DTiledOffset(x, y, w, texelPitch: DWORD): DWORD;

implementation

{Swizzling is a method of texture storage in a special mode, which is optimized for console videocard.
In order to improve better performance (which is very critical for consoles), the majority of graphic resources in games is not prepared for reading by human (developers, etc), but for it optimal usage in video memory.

See more info at:
 * http://dageron.com/?page_id=5210&lang=en
 * http://dageron.com/?page_id=5238}


function XGAddress2DTiledOffset(x, y, w, texelPitch: DWORD): DWORD;
var
  alignedWidth, logBpp, Macro, Micro, Offset: DWORD;
begin
  alignedWidth := (w + 31) and not 31;
  logBpp := (TexelPitch shr 2) + ((TexelPitch shr 1) shr (TexelPitch shr 2));
  Macro := ((x shr 5) + (y shr 5) * (alignedWidth shr 5)) shl (logBpp + 7);
  Micro := (((x and 7) + ((y and 6) shl 2)) shl LogBpp);
  Offset := Macro + ((Micro and not 15) shl 1) + (Micro and 15) + ((y and 8) shl (3 + logBpp)) + ((y and 1) shl 4);
  Result:= (((Offset and not 511) shl 3) + ((Offset and 448) shl 2) + (Offset and 63) + ((y and 16) shl 7) + (((((y and 8) shr 2) + (x shr 3)) and 3) shl 6)) shr logBpp;
end;

end.
