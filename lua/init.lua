print("*** Starting in 4 secs ***")
tmr.alarm(0, 4000, 0, function()
   print("Executing ...")
   dofile("player.lua")
end)

