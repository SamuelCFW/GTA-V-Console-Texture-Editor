object FormCPUSizeManual: TFormCPUSizeManual
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'CPU segment size'
  ClientHeight = 240
  ClientWidth = 238
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object CPUSegmentSize: TRadioGroup
    Left = 8
    Top = 8
    Width = 217
    Height = 193
    Caption = 'Please choose the CPU segment size'
    ItemIndex = 3
    Items.Strings = (
      '1024'
      '2048'
      '4096'
      '8192'
      '16348'
      'other')
    TabOrder = 1
    OnClick = CPUSegmentSizeClick
  end
  object btnOK: TButton
    Left = 150
    Top = 207
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 0
    OnClick = btnOKClick
  end
  object edtCustomSize: TEdit
    Left = 80
    Top = 172
    Width = 113
    Height = 21
    Enabled = False
    TabOrder = 2
    Text = '32768'
  end
end
