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

unit Global.Endian;

// Endian swap

interface

function EndianChangeDWORD(i:longword):longword;
function EndianChangeWORD(i:longword):longword;

implementation

function EndianChangeDWORD(i:longword):longword;
var
  j:integer;
  b1,b2,b3,b4:byte;
begin
  j:=i;
  asm
    mov eax,j
    mov b4,al
    mov b3,ah
    shr eax,10h
    mov b2,al
    mov b1,ah
    mov al,b3
    mov ah,b4
    shl eax,10h
    mov ah,b2
    mov al,b1
    mov j,eax
  end;
  Result:=j;
end;

function EndianChangeWORD(i:longword):longword;
var
  j:integer;
  b1,b2:byte;
begin
  j:=i;
  asm
    mov eax,j
    mov b2,al
    mov b1,ah
    mov al,b1
    mov ah,b2
    mov j,eax
  end;
  Result:=j;
end;

end.
