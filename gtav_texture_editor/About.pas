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

unit About;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SHELLAPI, ImagingComponents, ExtCtrls;

type
  TAboutForm = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Image1: TImage;
    Label12: TLabel;
    Label15: TLabel;
    Label2: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure Label15Click(Sender: TObject);
    procedure Label15MouseEnter(Sender: TObject);
    procedure Label15MouseLeave(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

// Please, do not change licence agreement. Thanks :)

{$R *.dfm}

procedure TAboutForm.Button1Click(Sender: TObject);
begin
close;
end;

procedure TAboutForm.Label15Click(Sender: TObject);
begin
If (Sender is TLabel) then
with (Sender as Tlabel) do
ShellExecute(Application.Handle,PChar('open'),
PChar(Hint),
PChar(0),
nil,
SW_NORMAL);
end;

procedure TAboutForm.Label15MouseEnter(Sender: TObject);
begin
label15.Font.Style:=[fsBold];
end;

procedure TAboutForm.Label15MouseLeave(Sender: TObject);
begin
label15.Font.Style:=[fsBold, fsUnderline];
end;

procedure TAboutForm.Label5Click(Sender: TObject);
begin
If (Sender is TLabel) then
with (Sender as Tlabel) do
ShellExecute(Application.Handle,PChar('open'),
PChar(Hint),
PChar(0),
nil,
SW_NORMAL);
end;

end.
