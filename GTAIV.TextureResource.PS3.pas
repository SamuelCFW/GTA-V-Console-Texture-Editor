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

unit GTAIV.TextureResource.PS3;

interface

uses SysUtils, Classes, Windows,

Global.Endian,
Compression.Zlib;

{some structures}
type CTDHeader = record   //unpacked resource header, contains basic information about dictionary
  _vmt                : DWORD;
  dwOffsetMapOffset   : DWORD;
  dwHashTableOffset   : DWORD;
  _fC                 : DWORD;
  _f10                : DWORD;
  dwTextureCount      : DWORD;
  dwTextureCount2     : DWORD;
  dwTextureListOffset : DWORD;
  dwTextureCount3     : DWORD;
  dwTextureCount4     : DWORD;
end;

type grcTextureCell = record    //item information block (PS3), each one contains information about relevant texture
  _vmt                : DWORD;
  _f4                 : DWORD;
  _f8                 : BYTE;
  _f9                 : BYTE;
  _fA                 : WORD;
  _fC                 : DWORD;
  _f10                : DWORD;
  pszNamePtr          : DWORD;
  dwTextureOffset     : DWORD;
  dwWidth             : WORD;
  dwHeight            : WORD;
  _f20                : DWORD;
  //_f24                : D3DVECTOR;
  //_f30:               : D3DVECTOR;
end;

procedure LoadResource(InStream: TStream; var OutStream: TMemoryStream; var dwCPUSize, dwGPUSize : DWORD; var bIsCPUSizeUnknown: boolean);
procedure SaveResource(CompressedFile: TMemoryStream; InStream: TStream);
procedure LoadCTD(InStream: TMemoryStream; iWorkMode: integer);

implementation

uses MainUnit;

function GetOffset(dwOffset: DWORD): DWORD;
begin
if dwOffset = 0 then result:=0
  else if ((dwOffset shr 28 <> 5) and (dwOffset shr 28 <> 6)) then result:=0
    else result:=dwOffset and $0FFFFFFF;
end;

function GetValueRSC7(dwFlag, baseSize: integer): integer;
var
  newBaseSize, Size, i: integer;
begin
  newBaseSize := baseSize shl (dwFlag and $f);
  Size := ((((dwFlag shr 17) and $7f) + (((dwFlag shr 11) and $3f) shl 1) + (((dwFlag shr 7) and $f) shl 2) + (((dwFlag shr 5) and $3) shl 3) + (((dwFlag shr 4) and $1) shl 4)) * newBaseSize);
  for i:=0 to 3 do
  begin
    if (((dwFlag shr (24 + i)) and 1) = 1) then
      size:= size + newBaseSize shr (1 + i);
  end;
  result:=size;
end;

procedure LoadResource(InStream: TStream; var OutStream: TMemoryStream; var dwCPUSize, dwGPUSize : DWORD; var bIsCPUSizeUnknown: boolean);
var
  dwSignature, dwFlags, dwFlags1, dwFlags2, tmp: DWORD;
  isRSC7: boolean;
  isRSC7Compressed: boolean;
  DecompressionStream:TMemoryStream;
begin
  isRSC7:=true;
  isRSC7Compressed:=true;
  bIsCPUSizeUnknown:=false;
  InStream.Seek(0, 0);
  InStream.Read(dwSignature, 4);
  InStream.Seek(8,0);
  dwCPUSize:=0;
  dwGPUSize:=0;
  if (dwSignature=$52534305) or (dwSignature=$05435352) or (dwSignature=$52534306) or (dwSignature=$06435352) then
    begin
      isRSC7:=false;
      isRSC7Compressed:=false;
      InStream.Read(dwFlags, 4);
      if (dwSignature=$52534305) or (dwSignature=$52534306) then dwFlags:=EndianChangeDword(dwFlags);    //params in resource header can be big-endian or little-endian
      {memory blocks size calculation, at this stage "technical" definition of flags value is not important}
      dwCPUSize:=(dwFlags AND $7FF) shl (((dwFlags shr 11) AND $F) + 8);
      dwGPUSize:=((dwFlags shr 15) AND $7FF) shl (((dwFlags shr 26) AND $F)+8);
      InStream.Seek(12, 0);
    end;
  if (dwSignature=$52534385) or (dwSignature=$85435352) then    //params in resource header can be big-endian or little-endian
    begin
      isRSC7:=false;
      isRSC7Compressed:=false;
      inStream.Read(dwFlags1, 4);
      inStream.Read(dwFlags2, 4);
      if dwSignature=$52534385 then
        begin
          dwFlags1:=EndianChangeDword(dwFlags1);
          dwFlags2:=EndianChangeDword(dwFlags2);
          if (dwFlags2 and $80000000)=0 then dwCPUSize:=((dwFlags1 and $7FF) shl (((dwFlags1 shr 11) and 15)+8)) else dwCPUSize:=(dwFlags2 and $3FFF) shl 12;
          if (dwFlags2 and $80000000)=0 then dwGPUSize:=(((dwFlags1 shr 15) and $7FF) shl (((dwFlags1 shr 26) and 15)+8)) else dwGPUSize:=(dwFlags2 shl 2) and $3FFF000;
        end;
      InStream.Seek(16, 0);
    end;
  if (dwSignature=$37435352) then // GTA V
    begin
      isRSC7:=true;
      isRSC7Compressed:=false;
      inStream.Seek(8, 0);
      inStream.Read(dwFlags1, 4);
      inStream.Read(dwFlags2, 4);
      dwFlags1:=EndianChangeDword(dwFlags1);
      dwFlags2:=EndianChangeDword(dwFlags2);
      dwCPUSize:=GetValueRSC7(dwFlags1, $1000);
      dwGPUSize:=GetValueRSC7(dwFlags2, $1580);
    end;
  if not(isRSC7Compressed) then
  begin
    OutStream.Seek(0, 0);
    if not(isRSC7) then
      begin
        // usual game resources
        DecompressZLib(InStream.Position, InStream, OutStream);
      end
      else
      begin
        // GTA V (RSC7: uncompressed)
        InStream.Seek(16, 0);
        OutStream.CopyFrom(InStream, InStream.Size-16);
      end;
    OutStream.Seek(0, 0);
  end
  else
  begin
    // GTA V (compressed, without RSC header)
    OutStream.Seek(0, 0);
    InStream.Seek(16, 0);
    DecompressionStream:=TMemoryStream.Create;
    tmp:=$DA78;
    DecompressionStream.Write(tmp, 2);
    DecompressionStream.CopyFrom(InStream, InStream.Size-16);
    DecompressionStream.Seek(0, 0);
    DecompressZLib(0, DecompressionStream, OutStream);
    DecompressionStream.Free;
    bIsCPUSizeUnknown:=true;
  end;
 // OutStream.SaveToFile('C:\Users\Dageron\Desktop\zlib'); // temporary
end;

procedure SaveResource(CompressedFile: TMemoryStream; InStream: TStream);
var
  dwSignature, dwFlags, dwInSize, dwFlags1, dwFlags2: DWORD;
  isRSC7: boolean;
  isRSC7Compressed: boolean;
  TempStream:TMemoryStream;
begin
  isRSC7:=true;
  isRSC7Compressed:=true;
  CompressedFile.Seek(0, 0);
  CompressedFile.Read(dwSignature, 4);
  CompressedFile.Seek(8,0);
  if (dwSignature=$52534305) or (dwSignature=$05435352) or (dwSignature=$52534306) or (dwSignature=$06435352) then
    begin
      CompressedFile.Seek(12, 0);
      Compression.Zlib.ÑompressZlib(CompressedFile, InStream);
      isRSC7:=false;
      isRSC7Compressed:=false;
    end;
  if (dwSignature=$52534385) or (dwSignature=$85435352) then
    begin
      CompressedFile.Seek(16, 0);
      Compression.Zlib.ÑompressZlib(CompressedFile, InStream);
      isRSC7:=false;
      isRSC7Compressed:=false;
    end;
  if (dwSignature=$37435352) then // GTA V (uncompressed, with header)
    begin
      isRSC7:=true;
      isRSC7Compressed:=false;
      CompressedFile.Seek(8, 0);
      CompressedFile.Read(dwFlags1, 4);
      CompressedFile.Read(dwFlags2, 4);
      dwFlags1:=EndianChangeDword(dwFlags1);
      dwFlags2:=EndianChangeDword(dwFlags2);
      dwCPUSize:=GetValueRSC7(dwFlags1, $1000);
      dwGPUSize:=GetValueRSC7(dwFlags2, $1580);
      CompressedFile.Seek(16, 0);
      InStream.Seek(0, 0);
      CompressedFile.CopyFrom(InStream, InStream.Size);
    end;
  if (isRSC7Compressed) then  // GTA V (compressed, without header)
    begin
      CompressedFile.Seek(16, 0);
      InStream.Seek(0, 0);
      TempStream:=TMemoryStream.Create;
      Compression.Zlib.ÑompressZlib(TempStream, InStream);
      TempStream.Seek(2, 0);
      CompressedFile.CopyFrom(TempStream, TempStream.Size-2);
    end;
end;

procedure LoadCTD(InStream: TMemoryStream; iWorkMode: integer);
var
  i, j: integer;
  S: String;
  dwEndian, dwTextureType: DWORD;
  m_CTDHeader: CTDHeader;
  m_grcTextureCell: grcTextureCell;
  grcTextureCellOffset: DWORD;
  TextureAdress, Number: DWORD;
  filename: array [1..50] of AnsiChar;
  btMipMaps: byte;
begin
  MainForm.Names.Clear;
  tslGPUTextureDataOffsets.Clear;
  tslTextureListOffsets.Clear;
  tslWidths.Clear;
  tslHeights.Clear;
  tslTextureTypes.Clear;
  tslD3DBaseTextureOffsets.Clear;
  tslNameOffsets.Clear;
  tslEndians.Clear;
  tslMipMaps.Clear;
  InStream.Seek(0,0);
  if iWorkMode=1 then   //work mode: *.chm (in-game web)
    begin
      InStream.Seek(12, 0);
      InStream.Read(TextureAdress, 4);
      TextureAdress:=EndianChangeDWORD(TextureAdress);
      TextureAdress:=GetOffset(TextureAdress);
      InStream.Seek(TextureAdress, 0);
    end;
  with m_CTDHeader do   //texture dictionary header reading
    begin
      if iWorkMode=2 then   //work mode: *.cshp (some of Midnight Club: Los Angelos texture resources)
        begin
          InStream.Read(_vmt, 4);
          _vmt:=EndianChangeDWORD(_vmt);
          InStream.Read(dwOffsetMapOffset, 4);
          dwOffsetMapOffset:=EndianChangeDWORD(dwOffsetMapOffset);
          dwOffsetMapOffset:=GetOffset(dwOffsetMapOffset);
          InStream.Read(dwOffsetMapOffset,4);
          grcTextureCellOffset:=EndianChangeDWORD(grcTextureCellOffset);
          grcTextureCellOffset:=GetOffset(grcTextureCellOffset);
          tslTextureListOffsets.Add(IntToStr(grcTextureCellOffset));
          m_CTDHeader.dwTextureCount:=1;
        end;
      if (iWorkMode=0) or (iWorkMode=1) then    //usual *.ctd (basic texture resource) or *.chm (in-game web) - resource header reading
        begin
          InStream.Read(_vmt, 4); _vmt:=EndianChangeDWORD(_vmt);
          InStream.Read(dwOffsetMapOffset, 4); dwOffsetMapOffset:=EndianChangeDWORD(dwOffsetMapOffset); dwOffsetMapOffset:=GetOffset(dwOffsetMapOffset);
          InStream.Read(_fC, 4); _fC:=EndianChangeDWORD(_fC);
          InStream.Read(_f10, 4); _f10:=EndianChangeDWORD(_f10);
          InStream.Read(dwHashTableOffset, 4); dwHashTableOffset:=EndianChangeDWORD(dwHashTableOffset); dwHashTableOffset:=GetOffset(dwHashTableOffset);
          InStream.Read(dwTextureCount, 2); dwTextureCount:=EndianChangeWORD(dwTextureCount);
          InStream.Read(dwTextureCount2, 2); dwTextureCount2:=EndianChangeWORD(dwTextureCount2);
          InStream.Read(dwTextureListOffset, 4); dwTextureListOffset:=EndianChangeDWORD(dwTextureListOffset); dwTextureListOffset:=GetOffset(dwTextureListOffset);
          InStream.Read(dwTextureCount3, 2); dwTextureCount3:=EndianChangeWORD(dwTextureCount3);
          InStream.Read(dwTextureCount4, 2); dwTextureCount4:=EndianChangeWORD(dwTextureCount4);
      end;
    end;
  if (iWorkMode=0) or (IWorkMode=1) then    //usual *.ctd (basic texture resource) or *.chm (in-game web) - information offsets reading
    begin
      InStream.Seek(m_CTDHeader.dwTextureListOffset, 0);
        for I := 1 to m_CTDHeader.dwTextureCount do
          begin
            InStream.Read(grcTextureCellOffset,4);
            grcTextureCellOffset:=EndianChangeDWORD(grcTextureCellOffset);
            grcTextureCellOffset:=GetOffset(grcTextureCellOffset);
            tslTextureListOffsets.Add(IntToStr(grcTextureCellOffset));
          end;
    end;
  for i := 1 to m_CTDHeader.dwTextureCount do   //item information blocks reading
    begin
      inStream.Seek(StrToInt(tslTextureListOffsets[I-1]), 0);
      inStream.Read(m_grcTextureCell._vmt, 4);
      if (iWorkMode=2) or (m_grcTextureCell._vmt=5710932) then inStream.Seek(inStream.Position+20, 0) else  inStream.Seek(inStream.Position+16, 0);
      if (m_grcTextureCell._vmt=6157940) then inStream.Seek(inStream.Position+4,0);
      //texture type reading
      if (iWorkMode=2) or (m_grcTextureCell._vmt=5710932) then inStream.Seek(StrToInt(tslTextureListOffsets[I-1])+32, 0) else inStream.Seek(StrToInt(tslTextureListOffsets[I-1])+20, 0);
      if (m_grcTextureCell._vmt div 100000 = 90) or (m_grcTextureCell._vmt div 10000 = 906) then inStream.Seek(StrToInt(tslTextureListOffsets[I-1])+8, 0);  // GTA V  known: 9058428, 9066748, 9058932, 9063068...
      inStream.Read(dwTextureType,1);
      tslTextureTypes.Add(IntToStr(dwTextureType));
      if (iWorkMode=2) or (m_grcTextureCell._vmt=5710932) then inStream.Seek(StrToInt(tslTextureListOffsets[I-1])+24, 0) else inStream.Seek(StrToInt(tslTextureListOffsets[I-1])+44, 0);
      //texture name offset reading
      if (m_grcTextureCell._vmt div 100000 = 90) or (m_grcTextureCell._vmt div 10000 = 906) then inStream.Seek(StrToInt(tslTextureListOffsets[I-1])+32, 0);  // GTA V  known: 9058428, 9066748, 9058932, 9063068...
      inStream.Read(m_grcTextureCell.pszNamePtr, 4);
      m_grcTextureCell.pszNamePtr:=EndianChangeDWORD(m_grcTextureCell.pszNamePtr);
      m_grcTextureCell.pszNamePtr:=GetOffset(m_grcTextureCell.pszNamePtr);
      tslNameOffsets.Add(IntToStr(m_grcTextureCell.pszNamePtr));
      //Texture offset reading
       if (m_grcTextureCell._vmt div 100000 = 90) or (m_grcTextureCell._vmt div 10000 = 906) then inStream.Seek(StrToInt(tslTextureListOffsets[I-1])+28, 0);  // GTA V  known: 9058428, 9066748, 9058932, 9063068...
      if (iWorkMode=2) or (m_grcTextureCell._vmt=5710932) then inStream.Seek(StrToInt(tslTextureListOffsets[I-1])+52, 0);
      inStream.Read(m_grcTextureCell.dwTextureOffset, 4);
      m_grcTextureCell.dwTextureOffset:=EndianChangeDWORD(m_grcTextureCell.dwTextureOffset);
      m_grcTextureCell.dwTextureOffset:=GetOffset(m_grcTextureCell.dwTextureOffset);
      tslGPUTextureDataOffsets.Add(IntToStr(m_grcTextureCell.dwTextureOffset));
      if (iWorkMode=2) or (m_grcTextureCell._vmt=5710932) then inStream.Seek(StrToInt(tslTextureListOffsets[I-1])+40, 0) else inStream.Seek(StrToInt(tslTextureListOffsets[I-1])+28, 0);
      //texture width and height reading
       if (m_grcTextureCell._vmt div 100000 = 90) or (m_grcTextureCell._vmt div 10000 = 906) then inStream.Seek(StrToInt(tslTextureListOffsets[I-1])+16, 0);  // GTA V  known: 9058428, 9066748, 9058932, 9063068...
      m_grcTextureCell.dwWidth:=0;
      inStream.Read(m_grcTextureCell.dwWidth, 2);
      m_grcTextureCell.dwWidth:=EndianChangeWORD(m_grcTextureCell.dwWidth);
      tslWidths.Add(IntToStr(m_grcTextureCell.dwWidth));
      m_grcTextureCell.dwHeight:=0;
      inStream.Read(m_grcTextureCell.dwHeight, 2);
      m_grcTextureCell.dwHeight:=EndianChangeWORD(m_grcTextureCell.dwHeight);
      tslHeights.Add(IntToStr(m_grcTextureCell.dwHeight));
      inStream.Seek(inStream.Position-11, 0);
      inStream.Read(btMipMaps, 1);
      // MipMaps
      tslMipMaps.Add(IntToStr(btMipMaps));
      inStream.Seek(inStream.Position+10, 0);
      inStream.Seek(inStream.Position+32, 0);
    end;
  for i := 1 to m_CTDHeader.dwTextureCount do   //texture names reading
    begin
      InStream.Seek(StrToInt(tslNameOffsets[I-1]), 0);
      InStream.Read(FileName, 40);
      S:=FileName;
      MainForm.Names.Update;
      MainForm.Names.Items.Add(S);
      S:=MainForm.Names.Items[I-1];
      Number:=0;
      for J := 1 to length(S) do
        begin
          if S[J]='/' then Number:=J;
        end;
      Delete(S,1,number);
      MainForm.Names.Items[I-1]:=S;
      S:=MainForm.Names.Items[I-1];
      if (S[length(S)]<>'s') and (S[length(S)-1]<>'d') and (S[length(S)-2]<>'d') and (S[length(S)-3]<>'.') then S:=S+'.dds';
      if pos('.dds', s)=0 then S:=s+'.dds';
      MainForm.Names.Items[I-1]:=S;
    end;
end;



end.
