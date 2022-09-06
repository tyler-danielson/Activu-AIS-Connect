--defaults
----remove 'locals'
--********************************************************************************
--* Aliases
--********************************************************************************
editIPaddr = Controls.IPAddress
editAISPort = Controls.Port
btnDisabled = Controls.connect_disabled
btnReconnect = Controls.ais_reconnect
btnClrFb = Controls.ClearFeedback
editAISUser = Controls.Username
editAISPW = Controls.Password
txtDebug = Controls.debug
editSendStr = Controls.SendString
editStatus = Controls.Status
editFeedback = Controls.feedback
intCheckConnect = Properties["Connection Test Inteval"]
btnClear = Controls.ClearQueue
btnDisplay = Controls.Queue


--********************************************************************************
--* Constants
--********************************************************************************
INCORRECT_PASS = "-13"
INC_PASS_RESPONSE = "Incorrect Password"
USER_LOCKED = "-10"
USER_LOCK_RESP = "User Account Locked"
OK = "0"
DATA_ERROR = "-20"
LDAP_ERROR = "-5000"
MAX_RETRY_COUNT  = 3
DEBUG_WINDOW_SIZE = -1500
NOTIFICATIONS_LABEL = 'aisSend'
INTERVAL = intCheckConnect.Value*60


--********************************************************************************
--* Enumerated types
--********************************************************************************
CONN_COLOR   = {GREY = 0, RED = 1, YELLOW = 2, GREEN = 3}
              --Green   Orange           Red        Grey            Red          Blue
STATUS_STATE = {OK = 0, COMPROMISED = 1, FAULT = 2, NOTPRESENT = 3, MISSING = 4, INITIALIZING = 5}

--********************************************************************************
--* Global objects/variables
--********************************************************************************
feedback = ""
lastCommand = ""
tick = 0
timer = Timer.New()
QueueTimer = Timer.New()
Activu = TcpSocket.New()
Activu.ReadTimeout = 0
Activu.WriteTimeout = 0
Activu.ReconnectTimeout = 5
loginAttempts = 0
SendQueue = {}
DebugFunction=false




--********************************************************************************
--* Debug display/print functions
--********************************************************************************

--********************************************************************************
--* Function: Debug(response)
--* Description: prints data into console and debug window.
--********************************************************************************
function Debug(response)
  local newString = string.sub(txtDebug.String..'\r\r'..response, DEBUG_WINDOW_SIZE)
  txtDebug.String = newString
  print(response)
end


--********************************************************************************
--* Discovery Functions
--********************************************************************************

--********************************************************************************
--* General Functions
--********************************************************************************

--********************************************************************************
--* Function: RGBToStr(color)
--* Description: Converts RGB type color to string
--* credit:  Chris Lord (QSC)
--********************************************************************************
function RGBToStr(color)
  return string.format("#%.2x%.2x%.2x",color[1],color[2],color[3])
end


--********************************************************************************
--* Function: CheckIPValid(ip)
--* Description: Check validity of IP address
--********************************************************************************
function CheckIPValid(ip)
  local ipValid = true
  if type(ip) == "string" then
    -- check for format 1.11.111.111 for ipv4
    local chunks = {ip:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")}
    if #chunks == 4 then
      for _,v in pairs(chunks) do
        if tonumber(v) > 255 then
          ipValid = false
        end
      end
    else
      ipValid = false
    end
  else
    ipValid = false
  end
  return ipValid
end


--********************************************************************************
--* Function: SendCommand(commandString)
--* Description: Send string command to AIS
--********************************************************************************
function SendCommand(commandString)
  local i,j = "",""
  i, j = string.find(commandString,"[^,]+")
  lastCommand = string.sub(commandString, i,j)
  Activu:Write(commandString.."\n")
  Debug('TX: '..commandString:gsub( editAISPW.String, "*****")) --replace password string with Asterisks
  
end

--********************************************************************************
--* Function: TCPConnect()
--* Description: Enable TCP Connection
--********************************************************************************
function TCPConnect()
  local IPAddress = editIPaddr.String
  local port = editAISPort.Value
  ClearQueue()
  --if CheckIPValid(IPAddress) then
  if #IPAddress > 0 then
    InputValid(editIPaddr,true)
    Activu:Connect(IPAddress,port)
  else
    InputValid(editIPaddr,false)
  end
  
end

--********************************************************************************
--* Function: AIS_Login()
--* Description: Log in to the Activu AIS connection
--********************************************************************************
function AIS_Login()
  lastCommand = "Login"
  if #editAISUser.String < 2 then
    editAISUser.Color = "Red"
  elseif #editAISPW.String < 2 then
    editAISPW.Color = "Red"
  else
    editAISUser.Color = ""
    editAISPW.Color = ""
    if Activu.IsConnected then
      local username = editAISUser.String
      local password = editAISPW.String
      local loginString = "Login," .. username .. "," .. password
      ReportStatus("FAULT","Logging In")
      SendCommand(loginString)
    end
  end
end

--********************************************************************************
--* Function: CheckIPValid(ip)
--* Description: Check validity of IP address
--* credit:  Chris Lord (QSC)
--********************************************************************************
function CheckIPValid(ip)
  local ipValid = true
  if type(ip) == "string" then
    -- check for format 1.11.111.111 for ipv4
    local chunks = {ip:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")}
    if #chunks == 4 then
      for _,v in pairs(chunks) do
        if tonumber(v) > 255 then
          ipValid = false
        end
      end
    else
      ipValid = false
    end
  else
    ipValid = false
  end
  return ipValid
end


--********************************************************************************
--* Function: ClearFeedback()
--* Description: Clear Feedback window
--********************************************************************************
function ClearFeedback()
  txtDebug.String = ""
end

--********************************************************************************
--* Function: InputValid(control,boolean)
--* Description: Set text input block colors based on validity check
--********************************************************************************
function InputValid(control,boolean)
  if boolean then
    control.Color = ""
  else
    control.Color = "Red"
  end
end


--********************************************************************************
--* Function: RXHandler(name,data)
--* Description: Send received data from Notifications to AIS Send Block
--********************************************************************************
function RXHandler(name,data)
  Debug(string.format("Notification Name: \"%s\"\t \r Data: \"%s\"",name,data))
  AddToQueue(data)
  --SendCommand(data)
end


--********************************************************************************
--* TCP Connection Handlers
--********************************************************************************

--********************************************************************************
--* Function: dataHandler(connection)
--* Description: Send received data from Notifications to AIS Send Block
--********************************************************************************
function DataHandler(Activu)
  feedback = Activu:ReadLine(TcpSocket.EOL.CrLf)
  if feedback ~= nil then
    --local data = {}
    tick = 0 --reset timer
    --data['feedback'] = feedback
    --data['lastCommand'] = lastCommand
    --local output = qsc_json.encode(data)
    local output = lastCommand..":"..feedback
    editFeedback.String = output--'{\"feedback\":\"'..feedback..'\",\"lastCommand\":\"'..lastCommand..'\"}'
    Debug('RX: '..feedback)
    ErrorCheck(feedback)
    Notifications.Publish('aisFeedback',output)
  end

  if lastCommand == "IsConnected" then
    Debug(lastCommand.." | "..feedback)
    if feedback ~= "0" then
      if loginAttempts < 3 then
        AIS_Login()
      else
        btnDisabled.Boolean = true
      end
    end
  end
  --clear last command
  --lastCommand = ""
end

--********************************************************************************
--* Function: ConnectHandler(connection)
--* Description: What to do when TCP Connects
--********************************************************************************
function ConnectHandler(Activu)
  InputValid(editIPaddr,true)
  InputValid(editAISPort,true)
  Debug("TCP socket is connected")
  if not btnDisabled.Boolean then 
    AIS_Login()
  end
end

--********************************************************************************
--* Function: ReconectHandler(connection)
--* Description: What to do when TCP is Reconnecting
--********************************************************************************
function ReconectHandler(Activu)
  ReportStatus("FAULT","TCP Connection Reconnecting")
  Debug("TCP socket is reconnecting")
end

--********************************************************************************
--* Function: ClosedHandler(connection)
--* Description: What to do when TCP Closes
--********************************************************************************
function ClosedHandler(Activu)
  ReportStatus("FAULT","TCP Connection Closed")
  Debug("TCP socket was closed by the remote end")
end

--********************************************************************************
--* Function: ErrorHandler(connection)
--* Description: What to do when TCP has and Error
--********************************************************************************
function ErrorHandler(Activu,err)
  ReportStatus("FAULT","Connect Error",err)
  Debug("TCP socket had an error: "..err)
end

--********************************************************************************
--* Function: TimeoutHandler(connection)
--* Description: What to do when TCP times out
--********************************************************************************
function TimeoutHandler(Activu,err)
  ReportStatus("FAULT","TCP Connection Timeout")
  Debug("TCP socket timed out "..err)
end


--********************************************************************************
--* Function: ErrorCheck(data)
--* Description: Check AIS Feedback for error code
--********************************************************************************
function ErrorCheck(feedback)
  if feedback == INCORRECT_PASS then
    ReportStatus("FAULT",INC_PASS_RESPONSE)
    InputValid(editAISUser,false)
    InputValid(editAISPW,false)
    btnDisabled.Boolean = true
  elseif feedback == USER_LOCKED then
    ReportStatus("FAULT",USER_LOCK_RESP)
    InputValid(editAISUser,false)
    InputValid(editAISPW,false)
    btnDisabled.Boolean = true
  elseif feedback == DATA_ERROR then
    ReportStatus("FAULT","Cannot Retrieve Data")
    failedLogin()
  elseif feedback == LDAP_ERROR then
    ReportStatus("FAULT","LDAP Authentication Error")
    failedLogin()
    btnDisabled.Boolean = true
  elseif feedback == OK then
    ReportStatus("OK","Logged In")
  end
end

--********************************************************************************
--* Function: ReportStatus(state, msg, debugStr)
--* Description: Update status message and state to given values
--********************************************************************************
function ReportStatus(state, msg, debugStr)
  --first check to see if there is a login error warning
  if not LoginWarningCheck() then
    editStatus.Value = STATUS_STATE[state]
    editStatus.String = msg
    if (STATUS_STATE[state] > 0) then
      ClearQueue()
      if debugStr ~= nil then
        if debugStr ~= "" then
          print(debugStr.."-"..msg)
        else
          print(msg)
        end
      else
        print(msg)
      end
    end
  end
end

--********************************************************************************
--* Function: failedLogin()
--* Description: Update number of login attempts
--********************************************************************************
function failedLogin()
  loginAttempts = loginAttempts + 1
  ClearQueue()
end


--********************************************************************************
--* Function: LoginWarningCheck()
--* Description: Check to see if current Status has login error
--********************************************************************************
function LoginWarningCheck()
  local currentErr = editStatus.String
  Debug(currentErr)
  if currentErr == INC_PASS_RESPONSE or currentErr == USER_LOCK_RESP then
    return true
  else
    return false
  end
end


--********************************************************************************
--* First in First Out Queue
--********************************************************************************
 --Command Send Queue
 function UpdateQueue()
  if DebugFunction then print("UpdateQueue() Called") end
  btnDisplay.Choices = SendQueue
end

-- Queue management
function AddToQueue(cmd)
  if DebugFunction then print("AddToQueue() Called") end
  table.insert(SendQueue,cmd)
  UpdateQueue()
end

function QueueGet()
  if DebugFunction then print("QueueGet() Called") end
  local cmd = ""
  if #SendQueue > 0 then
    cmd = SendQueue[1]
    table.remove(SendQueue,1)
    UpdateQueue()
  end
  return cmd
end

function Queue()
  if DebugFunction then print("Queue() Called") end
  if #SendQueue > 0 then
    SendCommand(QueueGet())
  end
end

function ClearQueue()
  if DebugFunction then print("ClearQueue() Called") end
  SendQueue = {}
  UpdateQueue()
end

function SendingCommand()
  if DebugFunction then print("SendingCommand() Called") end
end



--********************************************************************************
--* Function: disableConnect(object)
--* Description: Reset number of loginAttempts and Reconnect to AIS
--********************************************************************************
function disableConnect(obj)
  if not obj.Boolean then
    AIS_Login()
    loginAttempts = 0
  else
    SendCommand("Logout")
    ReportStatus("NOTPRESENT","Connection Disabled")
  end
end


--********************************************************************************
--* Function: ConnectCheck()
--* Description: Regularly check connection status to AIS.  Resets on response
--********************************************************************************
function ConnectCheck()
  if #editAISUser.String>0 and #editAISPW.String>0 and #editIPaddr.String>0 and #editAISPort.String>0 and not btnDisabled.Boolean then
    tick = tick + 1
    --print(tick)
    if tick >= INTERVAL then
      local user = editAISUser.String
      tick = 0
      feedback = ""
      SendCommand("IsConnected,"..user)
    end
  else
    tick = 0
  end
end

--********************************************************************************
--* Function: Event Handler for Send String input block
--* Description: Send string from AIS send block to AIS
--********************************************************************************
function StringBlockSend(obj)
  if obj.String ~= " " then
    SendCommand(obj.String)
  end
end

--********************************************************************************
--* Event Handlers for Controls
--********************************************************************************

editIPaddr.EventHandler = TCPConnect
editAISPort.EventHandler = TCPConnect
btnReconnect.EventHandler = AIS_Login
editAISUser.EventHandler = AIS_Login
editAISPW.EventHandler = AIS_Login
btnClrFb.EventHandler = ClearFeedback
btnDisabled.EventHandler = disableConnect
timer.EventHandler = ConnectCheck
btnClear.EventHandler = ClearQueue
QueueTimer.EventHandler  = Queue
editSendStr.EventHandler = StringBlockSend


--********************************************************************************
--* Function: Initialize()
--* Description: Initialization code for the plugin
--********************************************************************************
function Initialize()
  IPAddress = editIPaddr.String
  Port = editAISPort.Value
  Activu:Connect(IPAddress,Port)
  Activu.Connected = ConnectHandler
  Activu.Reconnect = ReconectHandler
  Activu.Data = DataHandler
  Activu.Closed = ClosedHandler
  Activu.Error = ErrorHandler
  Activu.Timeout = TimeoutHandler

  timer:Start(1)


  QueueTimer:Start(0.5)--Time.Value)


  Notifications.Subscribe( NOTIFICATIONS_LABEL, RXHandler )
  TCPConnect()

end

Initialize()