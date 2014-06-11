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

unit Intro;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UI.Aero.Core, UI.Aero.Window, Vcl.StdCtrls,
  UI.Aero.Core.BaseControl, UI.Aero.Core.CustomControl.Animation,
  UI.Aero.Button.Custom, UI.Aero.Button.Theme, UI.Aero.black.GameButton,
  UI.Aero.Core.CustomControl, UI.Aero.Labels, ShellApi;

type
  TIntroForm = class(TForm)
    AeroWindow: TAeroWindow;
    BlackGameButton1: TBlackGameButton;
    BPPlabel: TAeroLabel;
    Label15: TAeroLabel;
    AeroLabel1: TAeroLabel;
    AeroLabel2: TAeroLabel;
    AeroLabel3: TAeroLabel;
    Label2: TAeroLabel;
    procedure BlackGameButton1Click(Sender: TObject);
    procedure Label15Click(Sender: TObject);
    procedure Label15MouseEnter(Sender: TObject);
    procedure Label15MouseLeave(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  IntroForm: TIntroForm;

implementation

{$R *.dfm}

procedure TIntroForm.BlackGameButton1Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PwideChar(Application.ExeName), nil, nil, SW_SHOWNORMAL);
  close;
end;

procedure TIntroForm.Label15Click(Sender: TObject);
begin
  If (Sender is TAeroLabel) then
  with (Sender as TAeroLabel) do
  ShellExecute(Application.Handle,PChar('open'),
  PChar(Hint),
  PChar(0),
  nil,
  SW_NORMAL);
end;

procedure TIntroForm.Label15MouseEnter(Sender: TObject);
begin
  label15.Font.Style:=[fsBold];
end;

procedure TIntroForm.Label15MouseLeave(Sender: TObject);
begin
  label15.Font.Style:=[fsBold, fsUnderline];
end;

end.
