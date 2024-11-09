DEFAULT_CHAT_FRAME:AddMessage("init.lua is loading")

-- Namespace setup
setfenv(1, MyAuraTracker)

--------------------------------------------------------
-- Custom Slash Command
--------------------------------------------------------

core.commands = {
    -- this is a function, you can use wrapper function, but better is to use function address directly
    ["config"] = core.Config.Toggle,

    -- this is a wrapper function
    ["help"] = function()
        --print("calling help function")
        print(" ")
        core:PrintWithPrefix("List of slash commands:")
        core:PrintWithPrefix("|cff00cc66/at config|r - shows config menu")
        core:PrintWithPrefix("|cff00cc66/at help|r - shows help info")
        print(" ")
    end,

    ["example"] = {
        ["test"] = function(value)
            core:Print("My Value:", value)
        end
    }
}

function core:Print(...)
    local message = ""
    --print("calling print")
    -- Iterate through `arg`, converting each item to a string and adding it to `message`
    for i = 1, arg.n do
        message = message .. (i >= 1 and " " or "") .. tostring(arg[i])
        --print("current message " .. message)
    end

    -- Trim the trailing space and print the message to the chat frame
    -- trim both start and end spaces
    message = string.match(message, "^%s*(.-)%s*$")
    --message:match("^(.-)%s*$")  -- Remove trailing space
    print(message)
end

function core:PrintWithPrefix(...)
    local hex = select(4, self.Config:GetThemeColor())
    local prefix = string.format("|cff%s%s|r", string.upper(hex), "My Aura Tracker:")
    local packedArgs = { prefix }

    --for i = 1, table.getn(arg) do
    --    table.insert(packedArgs, tostring(arg[i]))
    --end
    --print("print prefix " .. prefix)

    for i = 1, arg.n do
        --n = n + 1
        local stringArg = tostring(arg[i])
        --print("collecting args " .. i .. stringArg)

        table.insert(packedArgs, tostring(arg[i]))
        --tmp[n] = tostring(select(i, ...))
    end
    --frame:AddMessage(tconcat(tmp, " ", 1, n))

    --print("count of args " .. arg.n)
    --print("first of packed args " .. packedArgs[1])
    --print("second of packed args " .. packedArgs[2])
    --print("third of packed args " .. packedArgs[3])

    self:Print(unpack(packedArgs))
end

local function HandleSlashCommands(str)
    print("calling HandleSlashCommands")
    if (not str or string.len(str) == 0) then
        -- User just entered "/at" with no additional args.
        core.commands.help()
        return
    end

    -- What we will iterate over using for loop (arguments).
    local args = {}
    for _, arg in pairs({ strsplit(" ", str) }) do
        -- if string length is greater than 0.
        if (string.len(arg) > 0) then
            table.insert(args, arg)
        end
    end

    local path = core.commands;       -- required for updating found table.
    for id, arg in pairs(args) do
        if (string.len(arg) > 0) then -- if string length is greater than 0.
            arg = string.lower(arg);
            if (path[arg]) then
                if (type(path[arg]) == "function") then
                    -- all remaining args passed to our function!
                    path[arg](select(id + 1, unpack(args)));
                    return;
                elseif (type(path[arg]) == "table") then
                    path = path[arg]; -- another sub-table found!
                end
            else
                -- does not exist!
                core.commands.help();
                return;
            end
        else
            -- does not exist!
            core.commands.help();
            return;
        end
    end
end

function core:init(event, name)
    -- self in case of calling from OnEvent from frame refers to that frame !!
    if (name ~= "MyAuraTracker") then
        --print("initialized addon is ", name)
        return
    end

    --print("2 initialized addon is ", name)

    -- to be able to use left and right arrows in the edit box
    -- without rotating your character
    --for i = 1, NUM_CHAT_WINDOWS do
    --    --todo something wrong with this indexing
    --    --_G["ChatFrame" .. i .. "EditBox"]:SetAltArrowKeyMode(false)
    --    local frame = getglobal("ChatFrame" .. i .. "EditBox")
    --    if frame then
    --        print("setting alt arrow key mode")
    --        frame:SetAltArrowKeyMode(false)
    --    else
    --        --print("frame was not found")
    --    end
    --    --print(i)
    --end

    --------------------------------------------------------
    -- Register Slash Commands!
    --------------------------------------------------------
    -- new slash command for reloading UI

    -- HINT FROM TURTLE WOW DISCORD
    -- use /run DEFAULT_CHAT_FRAME:AddMessage(SLASH_MyAddon1 or "nil")
    -- to check whether your slash command is defined.
    -- if it's not defined,
    -- use /run DEFAULT_CHAT_FRAME:AddMessage(SlashCmdList["MyAddon"] and "defined" or "nil").
    -- both undefined: your code is not being run
    -- if only SlashCmdList["MyAddon"] is defined it means you're not
    -- setting SLASH_MyAddon1 in global scope,
    -- use setglobal("SLASH_MyAddon1", function() DEFAULT_CHAT_FRAME:AddMessage("Command received") end)

    --SLASH_RELOADUI1 = "/rl" -- for quicker reloading
    --SlashCmdList.RELOADUI = ReloadUI

    -- new slash command for showing framestack tool
    -- WARNING: THESE tools do not exist in 1.12 version of wow
    --SLASH_FRAMESTK1 = "/fs"
    --SlashCmdList.FRAMESTK = function()
    --    LoadAddon('Blizzard_DebugTools')
    --    FrameStackTooltip_Toggle()
    --end
    --self.Addon:RegisterChatCommand("fs", function()
    --    LoadAddon("Blizzard_DebugTools")
    --    FrameStackTooltip_Toggle()
    --end)

    -- 1..X naming of AuraTracker are actually different ways to do this command
    -- basically aliases
    --SLASH_AuraTracker1 = "/at"
    --SlashCmdList.AuraTracker = HandleSlashCommands;
    --print("SLASH command init start")
    self.Addon:RegisterChatCommand("at", HandleSlashCommands)

    --print("SLASH command init finished")

    core:PrintWithPrefix("Welcome back", UnitName("player") .. "!")
end

local events = CreateFrame("Frame", "MyAddonEventsFrame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function()
    -- event is accessible like event, arg1 is name
    local name = arg1

    core:init(event, arg1)
end)
