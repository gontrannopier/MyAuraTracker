DEFAULT_CHAT_FRAME:AddMessage("config.lua is loading")

setfenv(1, MyAuraTracker)
--------------------------------------------------------
-- Namespaces
--------------------------------------------------------
-- _ is name for dummy variable, otherwise it would be used as addon name
-- second name - core is name of namespace, it's shared between lua files
--local _
--core = {}
--core.Config = {}

local Config = core.Config
local UIConfig

--------------------------------------------------------
-- Defaults (usually a database!)
--------------------------------------------------------
local defaults = {
    theme = {
        r = 0,
        g = 0.8, -- 204/255
        b = 1,
        hex = "00ccff"
    }
}

--------------------------------------------------------
-- Config functions
--------------------------------------------------------
function Config:Toggle()
    if (not UIConfig) then
        UIConfig = Config:CreateMenu()
    end
    UIConfig:SetShown(not UIConfig:IsShown())
end

function Config:GetThemeColor()
    local c = defaults.theme;
    return c.r, c.g, c.b, c.hex;
end

function Config:CreateButton(parentFrame, point, relativeFrame, relativePoint, yOffset, text)
    local button = CreateFrame("Button", nil, parentFrame, "GameMenuButtonTemplate")
    button:SetPoint(point, relativeFrame, relativePoint, 0, yOffset)
    button:SetSize(140, 40)
    button:SetText(text)
    button:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    button:SetHighlightFontObject("GameFontNormalLarge")

    -- works for pushed state of button by mouse
    --button:SetPushedFontObject("")
    --button:SetDisabledFontObject("")

    return button
end

function Config:CreateSlider(parentFrame, point, relativeFrame, relativePoint, yOffset, value, valueStep)
    local slider = CreateFrame("Slider", nil, parentFrame, "OptionsSliderTemplate")
    slider:SetPoint(point, relativeFrame, relativePoint, 0, yOffset)
    slider:SetMinMaxValues(1, 100)
    slider:SetValueStep(valueStep)
    slider:SetValue(value)
    --UIConfig.slider1:SetOrientation("VERTICAL")

    -- this doesnt exists in 1.12
    --UIConfig.slider1:SetObeyStepOnDrag(true)
    -- using this instead
    -- Adjust the slider to obey steps during drag
    slider:SetScript("OnValueChanged", function(self, newValue)
        -- Check if self is not nil
        if (self) then
            local step = self:GetValueStep() -- Get the step size
            -- Round to the nearest step
            local roundedValue = math.floor((newValue + step / 2) / step) * step
            self:SetValue(roundedValue) -- Set the slider to the adjusted value
        end
    end)
    return slider
end

function Config:CreateMenu()
    local UIConfig = CreateFrame("Frame", "MyAuraTrackerConfig", UIParent)

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
        DEFAULT_CHAT_FRAME:AddMessage("SetFont failed")
    end

    -- add 3 buttons !

    -- save button
    UIConfig.saveButton = self:CreateButton(UIConfig, "CENTER", UIConfig, "TOP", -70, "Save")
    -- reset button
    UIConfig.resetButton = self:CreateButton(UIConfig, "TOP", UIConfig.saveButton, "BOTTOM", -10, "Reset")
    -- load button
    UIConfig.loadButton = self:CreateButton(UIConfig, "TOP", UIConfig.resetButton, "BOTTOM", -10, "Save")


    -- SLIDERS !

    -- Slider 1
    UIConfig.slider1 = self:CreateSlider(UIConfig, "TOP", UIConfig.loadButton, "BOTTOM", -20, 50, 30)
    -- Slider 2
    UIConfig.slider2 = self:CreateSlider(UIConfig, "TOP", UIConfig.slider1, "BOTTOM", -20, 40, 1)

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

    UIConfig:Hide()
    return UIConfig
end
