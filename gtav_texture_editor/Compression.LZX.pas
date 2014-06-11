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

unit Compression.LZX;

interface

uses SysUtils, Classes, Windows, Global.Endian;

type
  XMEMCODEC_TYPE = ( XMEMCODEC_DEFAULT = 0, XMEMCODEC_LZX = 1 );

  XMEMCODEC_PARAMETERS_LZX = packed record
    Flags: Integer;
    WindowSize: Integer;
    CompressionPartitionSize: Integer;
  end;

  function XMemCreateDecompressionContext(CodecType: XMEMCODEC_TYPE; pCodecParams: Pointer; Flags: Integer; pContext: PInteger): HRESULT; stdcall; external 'xcompress.dll' name 'XMemCreateDecompressionContext';
  procedure XMemDestroyDecompressionContext(Context: Integer); stdcall; external 'xcompress.dll' name 'XMemDestroyDecompressionContext';
  function XMemResetDecompressionContext(Context: Integer): HRESULT; stdcall; external 'xcompress.dll' name 'XMemResetDecompressionContext';
  function XMemDecompress(Context: Integer; pDestination: Pointer; pDestSize: PInteger; pSource: Pointer; SrcSize: Integer): HRESULT; stdcall; external 'xcompress.dll' name 'XMemDecompress';
  function XMemDecompressStream(Context: Integer; pDestination: Pointer; pDestSize: PInteger; pSource: Pointer; pSrcSize: PInteger): HRESULT; stdcall; external 'xcompress.dll' name 'XMemDecompressStream';

  function XMemCreateCompressionContext(CodecType: XMEMCODEC_TYPE; pCodecParams: Pointer; Flags: Integer; pContext: PInteger): HRESULT; stdcall; external 'xcompress.dll' name 'XMemCreateCompressionContext';
  procedure XMemDestroyCompressionContext(Context: Integer); stdcall; external 'xcompress.dll' name 'XMemDestroyCompressionContext';
  function XMemResetCompressionContext(Context: Integer): HRESULT; stdcall; external 'xcompress.dll' name 'XMemResetCompressionContext';
  function XMemCompress(Context: Integer; pDestination: Pointer; pDestSize: PInteger; pSource: Pointer; pSrcSie: Integer): HRESULT; stdcall; external 'xcompress.dll' name 'XMemCompress';
  function XMemCompressStream(Context: Integer; pDestination: Pointer; pDestSize: PInteger; pSource: Pointer; pSrcSize: PInteger): HRESULT; stdcall; external 'xcompress.dll' name 'XMemCompressStream';

  procedure DecompressLZX(dwOffset, dwInSize, dwOutSize: DWORD; inStream, outStream: TStream; Codec: integer);
  procedure CompressLZX(dwOffset, dwInSize, dwOutSize: DWORD; inStream, outStream: TStream; Codec: integer);

  function xDecompress(pSource: Pointer; pSize: DWORD; pDest: Pointer; pOSize: PInteger; pFlags: Integer): Integer; cdecl; external 'xcompress_open.dll' name 'xDecompress';
  function xCompress(pSource: Pointer; pSize: DWORD; pDest: Pointer; pOSize: PInteger; pFlags: Integer): Integer; cdecl; external 'xcompress_open.dll' name 'xCompress';


  function LZXinit(window: integer): Integer; cdecl; external 'xcompress_cpp.dll' name 'LZXinit';
  function LZXdecompress(inData: PAnsiChar;  inlen: integer;  outdata: PAnsiChar;  outlen: integer): integer; cdecl; external 'xcompress_cpp.dll' name 'LZXdecompress';
const
  XMEMCOMPRESS_STREAM = $00000001;

implementation

// Now LZX compression/uncompression methods are too complicated, so we need to use 3 separate *.dll's for different purposes

procedure DecompressLZX(dwOffset, dwInSize, dwOutSize: DWORD; inStream, outStream: TStream; Codec: integer);
type
  LZXBlockSize = record
    UnCompressedSize,
    CompressedSize: WORD;
  end;
var
 Contex: Integer;
 Result: HRESULT;
 pSource, pDest: Pointer;
 pDataIn, pDataOut: PAnsiChar;
 tmp: integer;
 BlockSize: LZXBlockSize;
 codec_parameters: XMEMCODEC_PARAMETERS_LZX;
function ReadBlockSize(Stream: TStream): LZXBlockSize;
var
  b0, b1, b2, b3, b4: Byte;
begin
 Stream.Read(b0,1);
 if b0 = $FF then
  begin
   Stream.Read(b1,1);
   Stream.Read(b2,1);
   Stream.Read(b3,1);
   Stream.Read(b4,1);
   Result.UnCompressedSize:= b2 or b1 shl 8; //(b1 shl 8)+b2;
   Result.CompressedSize:= b4 or b3 shl 8; //(b3 shl 8)+b4;
  end
 else
  begin
   Stream.Read(b1,1);
   Result.UnCompressedSize:= $8000;
   Result.CompressedSize:= b1 or b0 shl 8; //(b0 shl 8)+b1;
  end;
end;
begin
 if Codec = 0 then
 begin
    inStream.Seek(dwOffset, 0);
    LZXinit(17);
    while (outStream.Size <> dwOutSize) do
    begin
     BlockSize:= ReadBlockSize(inStream);
     GetMem(pDataIn, BlockSize.CompressedSize);
     GetMem(pDataOut, BlockSize.UnCompressedSize);
     inStream.ReadBuffer(pDataIn^,BlockSize.CompressedSize);
     LZXdecompress(pDataIn, BlockSize.CompressedSize, pDataOut, BlockSize.UnCompressedSize);
     outStream.WriteBuffer(pDataOut^,BlockSize.UnCompressedSize);
     FreeMem(pDataIn, BlockSize.CompressedSize);
     FreeMem(pDataOut, BlockSize.UnCompressedSize);
    end;
    outStream.Seek(0, 0);
    outStream.Position := 0;

   {Contex:=0;
   Result:= XMemCreateDecompressionContext(XMEMCODEC_LZX, @codec_parameters, XMEMCOMPRESS_STREAM, @Contex);
   if Succeeded(Result) then
    begin
      Result:= XMemResetDecompressionContext(Contex);
      inStream.Seek(dwOffset, 0);
      GetMem(pSource, dwInSize);
      ZeroMemory(pSource, dwInSize);
      inStream.Read(pSource^, dwInSize);
      pDest:= GetMemory(dwOutSize);
      ZeroMemory(pDest, dwOutSize);
      tmp:=dwOutSize;
      Result:= XMemDecompressStream(Contex, pDest, @dwOutSize, pSource, @dwInSize);
      if Succeeded(Result) then
        begin
          dwOutSize:=tmp;
          outStream.Write(pDest^, dwOutSize);
          FreeMemory(pDest);
          FreeMemory(pSource);
        end;
      XMemDestroyDecompressionContext(Contex);
    end;         }
  end
  else
  begin
    inStream.Seek(dwOffset, 0);
    GetMem(pSource, dwInSize);
    ZeroMemory(pSource, dwInSize);
    inStream.Read(pSource^, dwInSize);
    dwOutSize := 0;
    GetMem(pDest, dwOutSize);
    ZeroMemory(pDest, dwOutSize);
    xDecompress(pSource, dwInSize, @pDest, @dwOutSize, 1);
    FreeMem(pSource);
    outStream.Seek(0, 0);
    outStream.Write(pDest^, dwOutSize);
    outStream.Position := 0;
    ZeroMemory(pDest, dwOutSize);
  end;
end;

procedure CompressLZX(dwOffset, dwInSize, dwOutSize: DWORD; inStream, outStream: TStream; Codec: integer);
var
 Contex: Integer;
 Result: HRESULT;
 pSource, pDest: Pointer;
 dwOutSize1, dwOutSize2: DWORD;
begin
if Codec = 0 then
  begin
    Contex:=0;
    Result:= XMemCreateCompressionContext(XMEMCODEC_LZX, nil, XMEMCOMPRESS_STREAM, @Contex);
    if Succeeded(Result) then
     begin
       Result:= XMemResetCompressionContext(Contex);
       outStream.Seek(dwOffset, 0);
       inStream.Seek(0, 0);
       GetMem(pSource, dwInSize);
       ZeroMemory(pSource, dwInSize);
       inStream.Read(pSource^, dwInSize);
       dwOutSize2:=dwInSize*2;
       pDest:=GetMemory(dwOutSize2);
       ZeroMemory(pDest, dwOutSize2);
       dwOutSize1:=EndianChangeDWORD(dwOutSize);
       Result:= XMemCompress(Contex, pDest, @dwOutSize2, pSource, dwInSize);
         if Succeeded(Result) then
           begin
             dwInSize:=$EF12F50F;
             outStream.Write(dwInSize, 4);
             dwOutSize2:=EndianChangeDWORD(dwOutSize2);
             outStream.Write(dwOutSize2, 4);
             dwOutSize2:=EndianChangeDWORD(dwOutSize2);
             outStream.Write(pDest^, dwOutSize2);
           end;
         XMemDestroyCompressionContext(Contex);
     end;
  end
  else
  begin
    dwOutSize := 0;
    GetMem(pDest, dwOutSize);
    ZeroMemory(pDest, dwOutSize);
    GetMem(pSource, dwInSize);
    ZeroMemory(pSource, dwInSize);
    inStream.Read(pSource^, dwInSize);
    xCompress(pSource, dwInSize, @pDest, @dwOutSize, 1);
    outStream.Seek(dwOffset, 0);
    outStream.Write(pDest^, dwOutSize);
  end;
end;

end.
