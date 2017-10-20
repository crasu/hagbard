print("*** Starting in 4 secs ***")
tmr.alarm(0, 1000, 0, function()
   print("Executing ...")
   dofile("player.lua")
end)

