setfenv(1, MyAuraTracker)

DEFAULT_CHAT_FRAME:AddMessage("functions.lua is loading")

if not string.match then
    local function getargs(s, e, ...)
        return unpack(arg)
    end
    function string.match(str, pattern)
        return getargs(string.find(str, pattern))
    end
end

if not print then
    function print(...)
        local message = ""

        -- Iterate through `arg`, converting each item to a string and adding it to `message`
        for i = 1, table.getn(arg) do
            message = message .. tostring(arg[i]) .. " "
        end

        -- Trim the trailing space and print the message to the chat frame
        message = string.match(message, "^(.-)%s*$")
        --message:match("^(.-)%s*$")  -- Remove trailing space
        DEFAULT_CHAT_FRAME:AddMessage(message)
    end
end

if not select then
    function select(index, ...)
        if index == "#" then
            return arg.n
        else
            local result = {}
            for i = index, arg.n do
                table.insert(result, arg[i])
            end
            return unpack(result)
        end
    end
end
