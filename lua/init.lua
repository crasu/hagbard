print("*** Starting in 300 msecs ***")
tmr.alarm(0, 1500, 0, function()
   print("Executing ...")
   dofile("player.lua")
end)

