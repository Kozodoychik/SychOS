ImageFs = {}
function ImageFs:new(data)
    local filesystem = {}
    local root = data

    local function getFile(path)
        local path = fs.combine(path, "")
        local directory = root
        local content = root
        for branch in string.gmatch(path, "[^\/]+") do
            if directory.content[branch] then
                if directory.content[branch].isDir then
                    directory = directory.content[branch]
                    content = directory
                else
                    content =  directory.content[branch]
                end
            else return nil end
        end
        return content
    end

    function filesystem.list(path)
        local dir = getFile(path)
        if not dir.isDir then return nil
        else
            local l = {}
            for key, _ in pairs(dir.content) do
                table.insert(l, key)
            end
            return l
        end
    end

    function filesystem.exists(path)
        local f = getFile(path)
        if f then return true
        else return false end
    end

    function filesystem.isDir(path)
        local f = getFile(path)
        if not f then return false end
        return f.isDir
    end

    function filesystem.isReadOnly(path)
        return true
    end

    function filesystem.getName(path)
        return fs.getName(path)
    end

    function filesystem.getDir(path)
        return fs.getDir(path)
    end

    function filesystem.open(path, mode)
        if mode == "w" or mode == "wb" or mode == "a" or mode == "ab" then
            --error("read-only filesystem!!!")
            return nil
        end

        local f = getFile(path)

        if mode == "r" then
            local handle = {
                _offset = 1,
                _data = f.content
            }
            handle.readLine = function()
                if handle._offset >= handle._data:len() then return nil end
                local data = string.match(handle._data, "[^\n]*\n?", handle._offset)
                handle._offset = handle._offset + data:len()
                return data
            end
            handle.readAll = function()
                return handle._data
            end
            handle.close = function()
                handle = nil
            end
            --handle.read = function(count)
            --    local data = string.match(handle._data, "[^\n]+", handle._offset)
            --    local c = count or 1
            --    data = string.sub(data, 1, c)
            --    return data
            --end
            return handle
        elseif mode == "rb" then
            local handle = {
                _offset = 1,
                _data = f.content
            }
            handle.read = function()
                local data = string.byte(string.match(handle._data, ".", handle._offset))
                handle._offset = handle._offset + 1
                return data
            end
            handle.close = function()
                handle = nil
            end

            return handle
        end

    end

    function filesystem.getDrive(path)
        local f = getFile(path)
        if f then return "imagefs"
        else return nil end
    end

    function filesystem.getFreeSpace(path)
        return 0
    end

    function filesystem.getSize(path)
        local f = getFile(path)
        if f then
            if not f.isDir then
                error(self:getName(path)..": No such file")
            end
            return f.content:len()
        end
        error(self:getName(path)..": No such file")
    end

    function filesystem.find(wildcard)
        error("ImageFs.find: not implemented")
    end

    function filesystem.makeDir(path)
        error("read-only filesystem!!!")
    end

    function filesystem.delete(path)
        error("read-only filesystem!!!")
    end

    setmetatable(filesystem, self)
    self.__index = self
    return filesystem
end