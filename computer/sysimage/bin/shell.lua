local testWindow2 = window.create(term.native(), 25, 1, 25, 9)
local testWindow3 = window.create(term.native(), 25, 10, 25, 18)
local testWindow = window.create(term.native(), 1, 1, 24, 18)

os.threading.start(function() print("TestWindow 1") 
    while true do 
    local c = read()
    print(c)
    coroutine.yield() 
end end, testWindow2)

os.threading.start(function() print("TestWindow 2")
    while true do 
    local c = read()
    print(c)
    coroutine.yield() 
end end, testWindow3)

os.threading.start(function() dofile("rom/programs/shell.lua") end, testWindow)