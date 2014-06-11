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

unit TextureEditor.CPUSizeManual;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus;

type
  TFormCPUSizeManual = class(TForm)
    CPUSegmentSize: TRadioGroup;
    btnOK: TButton;
    edtCustomSize: TEdit;
    procedure btnOKClick(Sender: TObject);
    procedure CPUSegmentSizeClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormCPUSizeManual: TFormCPUSizeManual;

implementation

uses MainUnit;

{$R *.dfm}

procedure TFormCPUSizeManual.btnOKClick(Sender: TObject);
begin
  case CPUSegmentSize.ItemIndex of
    0: dwCPUSize:=1024;
    1: dwCPUSize:=2048;
    2: dwCPUSize:=4096;
    3: dwCPUSize:=8192;
    4: dwCPUSize:=16348;
    5: dwCPUSize:=StrToInt(edtCustomSize.Text);
  end;
  Close;
end;

procedure TFormCPUSizeManual.CPUSegmentSizeClick(Sender: TObject);
begin
  if CPUSegmentSize.ItemIndex = 5 then edtCustomSize.Enabled:=true else edtCustomSize.Enabled:=false;
end;

procedure TFormCPUSizeManual.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  btnOKClick(Sender);
end;

end.
