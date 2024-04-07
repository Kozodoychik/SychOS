_G._KERNEL_VERSION = 0

local function valueInTable(value, tbl)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

local threads = {}
local currentWindow = term.current()
local currentWindowEvents = {"key", "key_up", "char"}
--os.pullEvent = os.pullEventRaw

fs.mount("/", "boot", fs.getNativeFsApi())

print("SychOS v.".._KERNEL_VERSION)

os.threading = {}

function os.threading.start(func, window)
    table.insert(threads, {window=window or term.current(), coro=coroutine.create(func)})
    return #threads
end

function os.threading.kill(id)
    threads[id] = nil
end

os.threading.start(function() dofile("init.lua") end)

while true do
    local timerId = os.startTimer(0.001)
    local event = {os.pullEvent()}
    
    for i=1,#threads,1 do
        local thread = threads[i]
        if thread then
            if coroutine.status(thread.coro) == "dead" then
                os.threading.kill(i)
            else
                term.redirect(thread.window)
                if event[1] == "mouse_click" then
                    local x, y = event[3], event[4]
                    local winX, winY = thread.window.getPosition()
                    local winW, winH = thread.window.getSize()
                    if (x >= winX and x < (winX+winW)) and (y >= winY and y < (winY+winH)) then
                        currentWindow = thread.window
                        term.write("")
                    end
                end
                if (not valueInTable(event[1], currentWindowEvents)) 
                or ((valueInTable(event[1], currentWindowEvents)) and thread.window == currentWindow) then
                    local ok, msg = coroutine.resume(thread.coro, table.unpack(event))
                    if not ok then
                        printError("Thread "..i..": "..msg)
                        os.threading.kill(i)
                    end
                    --term.redirect(term.native())
                end
            end
        end
    end
end