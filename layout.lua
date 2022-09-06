local COMMON_WIDTH = 185
local COMMON_HEIGHT = 60
local COMMON_MARGIN = 4

local CurrentPage = PageNames[props["page_index"].Value]
--AIS Setup Page
if CurrentPage == "Setup" then
  --*********************
  --* Activu Logo *
  --*********************
  Logo = "--[[ #encode "activu-logo.png" ]]"
  table.insert(graphics,{
    Type="Image",
    Image=Logo,
    Position={COMMON_MARGIN,4},
    Size={COMMON_WIDTH,COMMON_HEIGHT},
  })

  --*********************
  --* TCP Connect Block *
  --*********************
  table.insert(graphics,{Type = "GroupBox",Text = "Connection Setup",CornerRadius = 8,StrokeColor = Colors.Yellow,Fill = Colors.DarkGrey,StrokeWidth = 1,Position = {COMMON_MARGIN,69},Size = {185,65},FontSize = 10})
  table.insert(graphics,{Type = "Text",Text = "AIS IP Address:",Position = {COMMON_MARGIN+5,91},Size = {74,16},FontSize = 9,HTextAlign = "Right"})
  layout["IPAddress"] = {PrettyName = "Input IP Address of Activu ASM",Style = "Text",Position = {89,91},Size = {90,16},FontSize = 10,HTextAlign = "Left"}
  table.insert(graphics,{Type = "Text",Text = "Port #:",Position = {COMMON_MARGIN+5,112},Size = {74,16},FontSize = 10,HTextAlign = "Right"})
  layout["Port"] = {PrettyName = "Default: 59095",ControlType = "Knob",ControlUnit = "Integer",Min = 0,Max = 65535,Value = 59095, Position = {89,112},Size = {40,16},FontSize = 10,HTextAlign = "Left"}


  --*********************
  --* AIS Connect Block *
  --*********************
  table.insert(graphics,{Type = "GroupBox",Text = "AIS Setup",CornerRadius = 8,StrokeColor = Colors.Yellow,Fill = Colors.DarkGrey,StrokeWidth = 1,Position = {COMMON_MARGIN,139},Size = {185,122},FontSize = 10})
  table.insert(graphics,{Type = "Text",Text = "Username:",Position = {COMMON_MARGIN+5,160},Size = {62,16},FontSize = 10,HTextAlign = "Right"})
  table.insert(graphics,{Type = "Text",Text = "Password:",Position = {COMMON_MARGIN+5,182},Size = {62,16},FontSize = 10,HTextAlign = "Right"})
  layout["Username"] = {PrettyName = "AIS Username",Style = "Text",Position = {72,160},Size = {107,16},FontSize = 10}
  layout["Password"] = {PrettyName = "AIS Password",Style = "Text",Position = {72,182},Size = {107,16},FontSize = 6}
  layout["ais_reconnect"] = {PrettyName = "Reconnect",Style = "Button",Position = {41,202},Size = {50,16},Legend = "Reconnect"}
  layout["connect_disabled"] = {PrettyName = "Disabled",Style = "Button",Position = {105,202},Size = {50,16},Legend = "Disabled"}
  layout["Status"] = {PrettyName="Status",Style = "Indicator",Position = {13,226},Size = {169,25},FontSize = 9}

  --******************
  --*   Send block   *
  --******************
  table.insert(graphics,{Type = "GroupBox",Text = "AIS Send",Fill = Colors.DarkGrey,StrokeWidth = 1,CornerRadius = 8,StrokeColor = Colors.Yellow,Position = {197,5},Size = {282,60} })
  table.insert(graphics,{Type = "Text",Text = "Hit Enter to Send Command",Position = {203,52},Size = {270,10},FontSize = 8,HTextAlign = "Center"})
  layout["SendString"] = {PrettyName = "SendString",Style = "Text",Position = {203,27},Size = {270,25},FontSize = 10}
  
  --******************
  --* feedback block *
  --******************
  table.insert(graphics,{Type = "GroupBox",Text = "Feedback",Fill = Colors.DarkGrey,StrokeWidth = 1,CornerRadius = 8,StrokeColor = Colors.Yellow,Position = {197,70},Size = {282,60}})
  layout["feedback"] = {PrettyName = "AIS Response",Style = "Text",Position = {203,94},Size = {269,21},FontSize = 8,Color = Colors.Black}

  --*****************
  --*  debug block  *
  --*****************
  table.insert(graphics,{Type = "GroupBox",Text = "Debug",Fill = Colors.DarkGrey,StrokeWidth = 1,CornerRadius = 8,StrokeColor = Colors.Yellow,Position = {197,134},Size = {282,127}})
  layout["debug"] = {PrettyName = "feedback",Style = "Indicator",Position = {203,155},Size = {270,96},FontSize = 9,HTextAlign = "Left",VTextAlign = "Bottom"}
  layout["ClearFeedback"] = {PrettyName = "Clear Feedback",Style = "Button",Position = {423,136},Size = {50,18},FontSize = 9,Color = Colors.Red,Legend = "CLEAR"}

elseif CurrentPage == "Command Queue" then
  layout["ClearQueue"] = {PrettyName = "Queue~Clear Queue",Style = "Button",ButtonStyle = "Trigger",Legend="Clear",ButtonVisualStyle = "Gloss",Position = {200,COMMON_MARGIN},Size = {50,20}}
  layout["Queue"] = {PrettyName = "Queue~Queue",Style = "ListBox",TextBoxStyle = "Normal",IsReadOnly = true,Fill = Colors.White,HTextAlign = "Center",Position = {COMMON_MARGIN,COMMON_MARGIN+25},Size = {250,100}}
end