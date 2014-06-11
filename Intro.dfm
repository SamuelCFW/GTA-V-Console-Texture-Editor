object IntroForm: TIntroForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'GTA V Console Texture Editor'
  ClientHeight = 221
  ClientWidth = 435
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  GlassFrame.Enabled = True
  GlassFrame.SheetOfGlass = True
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    435
    221)
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TAeroLabel
    Left = 161
    Top = 61
    Width = 115
    Height = 13
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGreen
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Caption = #169' 2009 - 2014 Dageron'
  end
  object BlackGameButton1: TBlackGameButton
    Left = 112
    Top = 135
    Width = 217
    Height = 41
    OnClick = BlackGameButton1Click
    ThemeClassName = 'BUTTON'
    State.PartNormal = 6
    State.PartHightLight = 6
    State.PartFocused = 6
    State.PartDown = 6
    State.PartDisabled = 6
    State.StateNormal = 1
    State.StateHightLight = 2
    State.StateFocused = 5
    State.StateDown = 3
    State.StateDisabled = 4
    Caption = 'Continue'
    Image.PartHeight = 64
    Image.PartWidth = 64
  end
  object BPPlabel: TAeroLabel
    Left = 39
    Top = 189
    Width = 364
    Height = 24
    Anchors = [akLeft, akBottom]
    Caption = 
      '   This message is only displayed on the first time you load the' +
      ' application.'
    AutoSize = False
    TextGlow = True
    Layout = tlCenter
  end
  object Label15: TAeroLabel
    Left = 168
    Top = 111
    Width = 105
    Height = 13
    Cursor = crHandPoint
    Hint = 'www.Dageron.com'
    Anchors = [akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHotLight
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold, fsUnderline]
    OnClick = Label15Click
    OnMouseEnter = Label15MouseEnter
    OnMouseLeave = Label15MouseLeave
    Caption = 'www.Dageron.com'
  end
  object AeroLabel1: TAeroLabel
    Left = 55
    Top = 85
    Width = 329
    Height = 24
    Anchors = [akLeft, akBottom]
    Caption = 
      '   For news, updates and other useful info, please visit officia' +
      'l site:'
    AutoSize = False
    TextGlow = True
    Layout = tlCenter
  end
  object AeroLabel2: TAeroLabel
    Left = 34
    Top = 3
    Width = 375
    Height = 33
    Anchors = [akLeft, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Segoe UI'
    Font.Style = []
    Caption = '  GTA V Console Texture Editor  '
    AutoSize = False
    TextGlow = True
    Layout = tlCenter
  end
  object AeroLabel3: TAeroLabel
    Left = 171
    Top = 36
    Width = 92
    Height = 24
    Anchors = [akLeft, akBottom]
    Caption = '       Version: 1.4'
    AutoSize = False
    TextGlow = True
    Layout = tlCenter
  end
  object AeroWindow: TAeroWindow
    ShowInTaskBar = False
    ShowCaptionBar = False
    LinesCount = 0
    Left = 48
    Top = 128
  end
end
