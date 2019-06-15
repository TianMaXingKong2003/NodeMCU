--init.lua
print("Welcome TianMaXingKong !")

wifi.setmode(wifi.STATIONAP)

wifi.sta.config("TP-LINK_25F5","94025357abc")

wifi.sta.connect()

tmr.alarm(1, 1000, 1, function()
        if wifi.sta.getip()== nil then
        print("IP unavaiable, Waiting...")
        else
        tmr.stop(1)
        print("Config done, IP is "..wifi.sta.getip())
        dofile("kaiguan.lua")
        end
end)
