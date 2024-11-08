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
        print(" ")
        core:Print("List of slash commands:")
        core:Print("|cff00cc66/at config|r - shows config menu")
        core:Print("|cff00cc66/at help|r - shows help info")
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

    -- Iterate through `arg`, converting each item to a string and adding it to `message`
    for i = 1, table.getn(arg) do
        message = message .. tostring(arg[i]) .. " "
    end

    -- Trim the trailing space and print the message to the chat frame
    message = string.match(message, "^(.-)%s*$")
    --message:match("^(.-)%s*$")  -- Remove trailing space
    DEFAULT_CHAT_FRAME:AddMessage(message)
end

function core:Print(...)
    local hex = select(4, self.Config:GetThemeColor())
    local prefix = string.format("|cff%s%s|r", string.upper(hex), "My Aura Tracker:")
    local packedArgs = { prefix }

    for i = 1, table.getn(arg) do
        table.insert(packedArgs, tostring(arg[i]))
    end

    print(unpack(packedArgs))
end

local function HandleSlashCommands(str)
    print("calling HandleSlashCommands")
    if (str.length == 0) then
        -- User just entered "/at" with no additional args.
        core.commands.help()
        return
    end

    -- What we will iterate over using for loop (arguments).
    local args = {}
    for _, arg in pairs({ string.split(' ', str) }) do
        -- if string length is greater than 0.
        if (arg.length > 0) then
            table.insert(args, arg)
        end
    end

    local path = core.commands;  -- required for updating found table.
    for id, arg in pairs(args) do
        if (arg.length > 0) then -- if string length is greater than 0.
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
    --SLASH_RELOADUI1 = "/rl" -- for quicker reloading
    --SlashCmdList.RELOADUI = ReloadUI

    -- new slash command for showing framestack tool
    --SLASH_FRAMESTK1 = "/fs"
    --SlashCmdList.FRAMESTK = function()
    --    LoadAddon('Blizzard_DebugTools')
    --    FrameStackTooltip_Toggle()
    --end

    -- 1..X naming of AuraTracker are actually different ways to do this command
    -- basically aliases
    --SLASH_AuraTracker1 = "/at"
    --SlashCmdList.AuraTracker = HandleSlashCommands;
    print("SLASH command init start")
    SLASH_MYADDON1 = "/myaddon"
    SlashCmdList["MYADDON"] = function() DEFAULT_CHAT_FRAME:AddMessage("Command received") end
    print("SLASH command init finished")

    --SlashCmdList.WIM = function()
    --    DEFAULT_CHAT_FRAME:AddMessage("WIM command")
    --end
    --SLASH_WIM1 = "/wim";

    core:Print("Welcome back", UnitName("player") .. "!")
end

local events = CreateFrame("Frame", "MyAddonEventsFrame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function()
    -- event is accessible like event, arg1 is name
    local name = arg1

    SLASH_DPSMatek1 = "/dps1"
    SlashCmdList["DPSMatek"] = function(msg)
        core:Print("Welcome back XDDDDDD!!!!", UnitName("player") .. "!")
    end

    core:init(event, arg1)
end)
