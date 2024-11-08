DEFAULT_CHAT_FRAME:AddMessage("init.lua is loading")

setfenv(1, MyAuraTracker)
-- Namespace
--local addonName
--local core = {}
--core.Config = {}


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
end

function core:init(event, name)
    -- self in case of calling from OnEvent from frame refers to that frame !!
    if (name ~= "MyAuraTracker") then
        return
    end

    -- to be able to use left and right arrows in the edit box
    -- without rotating your character
    for i = 1, NUM_CHAT_WINDOWS do
        --todo something wrong with this indexing
        --_G["ChatFrame" .. i .. "EditBox"]:SetAltArrowKeyMode(false)
        local frame = getglobal("ChatFrame" .. i .. "EditBox")
        if frame then
            print("setting alt arrow key mode")
            frame:SetAltArrowKeyMode(false)
        else
            --print("frame was not found")
        end
        --print(i)
    end

    --------------------------------------------------------
    -- Register Slash Commands!
    --------------------------------------------------------
    -- new slash command for reloading UI
    SLASH_RELOADUI1 = "/rl" -- for quicker reloading
    SlashCmdList.RELOADUI = ReloadUI

    -- new slash command for showing framestack tool
    SLASH_FRAMESTK1 = "/fs"
    SlashCmdList.FRAMESTK = function()
        LoadAddon('Blizzard_DebugTools')
        FrameStackTooltip_Toggle()
    end

    -- 1..X naming of AuraTracker are actually different ways to do this command
    -- basically aliases
    SLASH_AuraTracker1 = "/at"
    SlashCmdList.AuraTracker = HandleSlashCommands;

    core:Print("Welcome back", UnitName("player") .. "!")
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", core.init)

-- create generic frame
--local myFrame = CreateFrame("Frame");

--local texture = myFrame:CreateTexture(nil, "BACKGROUND");

--local fontString = myFrame:CreateFontString(nil, "BACKGROUND");


-- layers (from lower to upper):
--background
--border
--artwork
--overlay
--highlight

-- frames can have children frames and have only one parent frame
-- frames have those layers mentioned above

-- frame can be all widgets that exclude regions
-- and there is actual widget call frame that do not inherit anything
-- frame is basically a base class to other widgets
-- - check button, button, slider,...and more

-- frame functions
--frame:setPoint
--frame:setSize
--frame:show
--frame:hide


print("helllooo")

local _G = getglobal



---------------------------------------------------------------

local UIConfig = CreateFrame("Frame", "MyAuraTracker", UIParent)

--[[
   CreateFrame Arguments
   1. type of frame - "Frame"
   2. The global frame name - "MUI_BuffFrame"
   3. The Parent frame (NOT a string!!!) - UIParent
   4. A comma separated LIST (string list) of XML templates to inherit from
   (templates are stored in XML environments in BlizzardInterfaceCode folder)
    - this does not need to be a a comma separated list, you can use only 1
--]]

UIConfig:SetWidth(260)
UIConfig:SetHeight(400)

-- point relativeFrame, relativePoint, xOffset, yOffset
UIConfig:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

--from chat gpt in order to show a frame
UIConfig:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- Background texture
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",   -- Border texture
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})

-- Set the backdrop color to make it visible
UIConfig:SetBackdropColor(0, 0, 0, 1)

-- Create the title for the frame
--local title = UIConfig:CreateFontString(nil, "OVERLAY", "GameFontNormal")  -- Use a predefined font
--title:SetPoint("TOP", frame, "TOP", 0, -10)  -- Position it at the top of the frame with a slight offset
--title:SetText("My Frame Title")  -- Set the title text

-- Optional: Create a texture to mimic the title background
--local titleBg = frame:CreateTexture(nil, "BACKGROUND")
--titleBg:SetColorTexture(0.1, 0.1, 0.1, 0.8)  -- Dark background with slight transparency
--titleBg:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
--titleBg:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -10)
--titleBg:SetHeight(20)  -- Set a reasonable height for the title background


-- point and relativePoint ("CENTER") could have been any of the following
--[[
    "TOPLEFT"
    "TOP"
    "TOPRIGHT"
    "LEFT"
    "CENTER"
    "RIGHT"
    "BOTTOMLEFT"
    "BOTTOM"
    "BOTTOMRIGHT"
]] --

-- chat gpt stop

-- Title background (using a separate frame as a workaround)
local titleBg = CreateFrame("Frame", nil, UIConfig)
titleBg:SetWidth(280)                            -- Slightly smaller width than main frame
titleBg:SetHeight(20)                            -- Height for the title background
titleBg:SetPoint("TOP", UIConfig, "TOP", 0, -10) -- Position at the top of the main frame

-- Add backdrop to the title background
titleBg:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Foreground",
    edgeFile = nil,
    tile = true,
    tileSize = 16
})
titleBg:SetBackdropColor(0.1, 0.1, 0.1, 0.8) -- Dark background with slight transparency

UIConfig.title = UIConfig:CreateFontString(nil, "OVERLAY")

--causes your font to interit font properties - color, size, shadow effects, outline stiles,...
UIConfig.title:SetFontObject("GameFontHighlight")
UIConfig.title:SetPoint("TOP", UIConfig, "TOP", 0, -10)
UIConfig.title:SetText("A My Addon")


--another way to set font is to call SetFont function
local successful = UIConfig.title:SetFont("Fonts\\FRIZQT__.ttf", 11, "OUTLINE, THICKOUTLINE, MONOCHROME")

if (not successful) then
    print("SetFont failed")
end

-- add 3 buttons !

-- save button
UIConfig.saveButton = CreateFrame("Button", nil, UIConfig, "GameMenuButtonTemplate")
UIConfig.saveButton:SetPoint("CENTER", UIConfig, "TOP", 0, -70)
UIConfig.saveButton:SetHeight(40)
UIConfig.saveButton:SetWidth(140)
UIConfig.saveButton:SetText("Save")
UIConfig.saveButton:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
UIConfig.saveButton:SetHighlightFontObject("GameFontNormalLarge")

-- works for pushed state of button by mouse
--UIConfig.saveButton:SetPushedFontObject("")
--UIConfig.saveButton:SetDisabledFontObject("")

-- reset button
UIConfig.resetButton = CreateFrame("Button", nil, UIConfig, "GameMenuButtonTemplate")
UIConfig.resetButton:SetPoint("TOP", UIConfig.saveButton, "BOTTOM", 0, -10)
UIConfig.resetButton:SetHeight(40)
UIConfig.resetButton:SetWidth(140)
UIConfig.resetButton:SetText("Reset")
UIConfig.resetButton:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
UIConfig.resetButton:SetHighlightFontObject("GameFontNormalLarge")

-- load button
UIConfig.loadButton = CreateFrame("Button", nil, UIConfig, "GameMenuButtonTemplate")
UIConfig.loadButton:SetPoint("TOP", UIConfig.resetButton, "BOTTOM", 0, -10)
UIConfig.loadButton:SetHeight(40)
UIConfig.loadButton:SetWidth(140)
UIConfig.loadButton:SetText("Load")
UIConfig.loadButton:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
UIConfig.loadButton:SetHighlightFontObject("GameFontNormalLarge")


-- SLIDERS !

-- Slider 1
UIConfig.slider1 = CreateFrame("Slider", nil, UIConfig, "OptionsSliderTemplate")
UIConfig.slider1:SetPoint("TOP", UIConfig.loadButton, "BOTTOM", 0, -20)
UIConfig.slider1:SetMinMaxValues(1, 100)
UIConfig.slider1:SetValueStep(30)
UIConfig.slider1:SetValue(50)
--UIConfig.slider1:SetOrientation("VERTICAL")

-- this doesnt exists in 1.12
--UIConfig.slider1:SetObeyStepOnDrag(true)
-- using this instead
-- Adjust the slider to obey steps during drag
UIConfig.slider1:SetScript("OnValueChanged", function(self, value)
    -- Check if self is not nil
    if self then
        local step = self:GetValueStep() -- Get the step size
        -- Round to the nearest step
        local roundedValue = math.floor((value + step / 2) / step) * step
        self:SetValue(roundedValue) -- Set the slider to the adjusted value
    end
end)

-- Slider 2
UIConfig.slider2 = CreateFrame("Slider", nil, UIConfig, "OptionsSliderTemplate")
UIConfig.slider2:SetPoint("TOP", UIConfig.slider1, "BOTTOM", 0, -20)
UIConfig.slider2:SetMinMaxValues(1, 100)
UIConfig.slider2:SetValue(40)
UIConfig.slider2:SetValueStep(1)

-- this doesnt exists in 1.12
--UIConfig.slider1:SetObeyStepOnDrag(true)
-- using this instead
-- Adjust the slider to obey steps during drag
UIConfig.slider2:SetScript("OnValueChanged", function(self, value)
    -- Check if self is not nil
    if self then
        local step = self:GetValueStep() -- Get the step size
        -- Round to the nearest step
        local roundedValue = math.floor((value + step / 2) / step) * step
        self:SetValue(roundedValue) -- Set the slider to the adjusted value
    end
end)

-- CHECK BUTTONS !!

-- Check button 1
UIConfig.checkButton1 = CreateFrame("CheckButton", nil, UIConfig, "UICheckButtonTemplate")
UIConfig.checkButton1:SetPoint("TOPLEFT", UIConfig.slider2, "BOTTOMLEFT", -10, -40)

-- this doesnt work on it's own on 1.12, added later, so we cannot use it
--UIConfig.checkButton1.text:SetText("My Check Button 1!")

-- Create a font string to hold the text
-- we have to create text for check button manually (1.12 thing)
UIConfig.checkButton1.text = UIConfig.checkButton1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
UIConfig.checkButton1.text:SetPoint("LEFT", UIConfig.checkButton1, "RIGHT", 5, 0) -- Position the text to the right of the checkbox
UIConfig.checkButton1.text:SetText("My Check Button 1!")                          -- Set the text for the checkbox


-- Check button 2
UIConfig.checkButton2 = CreateFrame("CheckButton", nil, UIConfig, "UICheckButtonTemplate")
UIConfig.checkButton2:SetPoint("TOPLEFT", UIConfig.checkButton1, "BOTTOMLEFT", 0, -10)

-- this doesnt work on it's own on 1.12, added later, so we cannot use it
--UIConfig.checkButton1.text:SetText("My Check Button 1!")

-- Create a font string to hold the text
-- we have to create text for check button manually (1.12 thing)
UIConfig.checkButton2.text = UIConfig.checkButton2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
UIConfig.checkButton2.text:SetPoint("LEFT", UIConfig.checkButton2, "RIGHT", 5, 0) -- Position the text to the right of the checkbox
UIConfig.checkButton2.text:SetText("My Check Button 2!")                          -- Set the text for the checkbox
UIConfig.checkButton2:SetChecked(true)


-- NAMESPACES
-- they are just a variable that spawns across the entire addony ONLY
-- you can add things on addon namespace in order to share variables
-- between files
-- => if you have multiple lua files, they own SHARED namespace

-- config and timer .lua files will just store object and functions that we will use
