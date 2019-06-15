--use sjson
_G.cjson = sjson
--modify DEVICEID INPUTID APIKEY

DEVICEID = "7394"
APIKEY = "837f97fbf"
INPUTID = "6526"
host = "www.bigiot.net"
port = 8181
LED = 4

kaiguan = 2

isConnect = false

firstConnect = true

gpio.mode(LED,gpio.OUTPUT)
gpio.mode(kaiguan,gpio.OUTPUT)

gpio.write(kaiguan, gpio.HIGH)

uart.setup(0, 9600, 8, 0, 1, 1 )

local function run()

  local cu = net.createConnection(net.TCP)
  
  cu:on("receive", function(cu, c) 
  
    print(c)
    isConnect = true
    r = cjson.decode(c)
    
    if r.M == "checkinok" then
        --if firstConnect == true then
        gpio.write(LED, gpio.LOW)
        --firstConnect=false
        --end
        
    end
    
    if r.M == "say" then
      if r.C == "play" then   
        gpio.write(LED, gpio.HIGH)
        gpio.write(kaiguan, gpio.HIGH)
        uart.write( 0, "L")
        
        ok, played = pcall(cjson.encode, {M="say",ID=r.ID,C="LED turn on!"})
        cu:send( played.."\n" )
      end
      if r.C == "stop" then   
        gpio.write(LED, gpio.LOW)
        gpio.write(kaiguan, gpio.LOW)

        uart.write( 0, "H")
        
        ok, stoped = pcall(cjson.encode, {M="say",ID=r.ID,C="LED turn off!"})
        cu:send( stoped.."\n" ) 
      end
    end
  end)

  
  cu:on('disconnection',function(scu)

    print("---disconnect---")

    node.restart()
  
    cu = nil
    isConnect = false
    
    tmr.stop(1)
    
    tmr.alarm(6, 5000, 0, run)
    
  end)

  
  cu:connect(port, host)

  
  ok, s = pcall(cjson.encode, {M="checkin",ID=DEVICEID,K=APIKEY})
  
  if ok then
    print(s)
  else
    print("failed to encode!")
  end
  
  if isConnect then
      cu:send(s.."\n")
  end

  tmr.alarm(1, 5000,1, function()
  
    --if wifi.sta.getip()== nil then
      --    print("wifi is fail")
    --end
    
    if isConnect then
      cu:send(s.."\n")
    else
      tmr.stop(1)
    end
  end)
  
  
end

run()
