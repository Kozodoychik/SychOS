local testWindow2 = window.create(term.native(), 25, 1, 25, 19)
local testWindow = window.create(term.native(), 1, 1, 24, 19)

os.threading.start(function() print("TestWindow 1") 
    while true do 
    local c = read()
    print(c)
    coroutine.yield() 
end end, testWindow)

os.threading.start(function() print("TestWindow 2")
    while true do 
    local c = read()
    print(c)
    coroutine.yield() 
end end, testWindow2)