os.loadAPI("drivers/imagefs.lua")

local defaultFs = {}
local mountPoints = {}

for name, func in pairs(fs) do
    defaultFs[name] = func
end

function fs.getNativeFsApi()
    return defaultFs
end

function fs.mount(src, dest, driver)
    local dest = fs.combine(dest, "")

    if not fs.exists(src) then
        error("cannot mount "..src)
    end
    if mountPoints[dest] or not fs.exists(dest) then
        error("cannot mount to "..dest)
    end

    if dest == "" or dest == "/" then dest = "%root%" end

    if not fs.isDir(src) and not driver then
        local data = textutils.unserialise(fs.open(src, "r").readAll())
        driver = imagefs.ImageFs:new(data)
    end

    mountPoints[dest] = {
        dir = src,
        driver = driver
    }
    --if dest == "" or dest == "/" then
    --    if not fs.isDir(src) then
    --        local f = fs.open(src, "r")
    --        local data = textutils.unserialise(f.readAll())
    --        mountPoints["%root%"] = {}
    --        mountPoints["%root%"].dir = ""
    --        mountPoints["%root%"].driver = imagefs.ImageFs:new(data)
    --        
    --    else
    --        mountPoints["%root%"] = {}
    --        mountPoints["%root%"].dir = src
    --    end
    --else
    --    mountPoints[dest] = {dir=src}
    --    if not fs.isDir(src) then
    --        local data = textutils.unserialise(fs.open(src, "r").readAll())
    --        mountPoints[dest].driver = imagefs.ImageFs:new(data)
    --    end
    --end
end

function fs.umount(path)
    local path = fs.combine(path, "")
    if path == "" or path == "/" then
        mountPoints["%root%"] = nil
    elseif mountPoints[path] then
        mountPoints[path] = nil
    else
        error(path.." is not mounted")
    end
end

fs.unmount = fs.umount

function fs.getMountPoints()
    return mountPoints
end

local function fsFuncWrapper(func, path, ...)
    local orig_path = fs.combine(path, "")
    local driver

    for key, value in pairs(mountPoints) do
        if string.match(path, "^(\/?rom\/?)") then
            return defaultFs[func](orig_path, ...)
        end
        if string.match(path, "^(\/?"..key..")") then
            orig_path = string.gsub(path, "^(\/?"..key..")", value.dir)
            driver = value.driver
            break
        end
    end

    if mountPoints["%root%"] then
        if not mountPoints["%root%"].driver then
            orig_path = fs.combine(mountPoints["%root%"].dir, orig_path)
            driver = defaultFs
        end
        driver = driver or mountPoints["%root%"].driver
    end

    driver = driver or defaultFs

    --if func == "list" then
    --    print(textutils.serialise(driver.list("")))
    --end

    return driver[func](orig_path, ...)
end

_G["fs"]["list"] = function(path, ...) return fsFuncWrapper("list", path, ...) end
_G["fs"]["exists"] = function(path, ...) return fsFuncWrapper("exists", path, ...) end
_G["fs"]["isDir"] = function(path, ...) 
    if path == ".." then return false end
    return fsFuncWrapper("isDir", path, ...)
end
_G["fs"]["isReadOnly"] = function(path, ...) return fsFuncWrapper("isReadOnly", path, ...) end
_G["fs"]["getDrive"] = function(path, ...) return fsFuncWrapper("getDrive", path, ...) end
_G["fs"]["getSize"] = function(path, ...) return fsFuncWrapper("getSize", path, ...) end
_G["fs"]["getFreeSpace"] = function(path, ...) return fsFuncWrapper("getFreeSpace", path, ...) end
_G["fs"]["makeDir"] = function(path, ...) return fsFuncWrapper("makeDir", path, ...) end
_G["fs"]["find"] = function(path, ...)
    local data = fsFuncWrapper("find", path, ...)
    if mountPoints["%root%"] then
        for i, value in ipairs(data) do
            data[i] = string.gsub(value, "^(\/?"..mountPoints["%root%"].dir..")", "")
        end
    end
    return data
end
_G["fs"]["open"] = function(path, ...) return fsFuncWrapper("open", path, ...) end
_G["fs"]["delete"] = function(path, ...) return fsFuncWrapper("delete", path, ...) end
