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

-- TODO should be possible to use it from AceCore directly
-- TODO but haven't found the way yet
if not strsplit then
    function strsplit(delimiter, text)
        local result = {}
        local from = 1
        local delim_from, delim_to = string.find(text, delimiter, from)
        while delim_from do
            table.insert(result, string.sub(text, from, delim_from - 1))
            from = delim_to + 1
            delim_from, delim_to = string.find(text, delimiter, from)
        end
        table.insert(result, string.sub(text, from))
        return unpack(result)
    end
end

local RegionMixins = {}
local RegionOverrides = {}
local FrameMixins = {}
local FrameOverrides = {}

local function ApplyMixinsAndOverrides(self, mixins, overrides)
    if mixins then
        for k, v in pairs(mixins) do
            if not self[k] then
                self[k] = v
            end
        end
    end
    if overrides then
        for k, v in pairs(overrides) do
            if self[k] then
                self["_" .. k], self[k] = self[k], v
            end
        end
    end
end

function CreateFrame(frameType, name, parent, template)
    if UIParent.SetBackdrop and template == "BackdropTemplate" then
        template = nil
    end

    local frame = _G.CreateFrame(frameType, name, parent, template)
    -- TODO region mixins
    ApplyMixinsAndOverrides(frame, RegionMixins, RegionOverrides)
    ApplyMixinsAndOverrides(frame, FrameMixins, FrameOverrides)
    -- TODO hook frame
    --if hookFrame then
    --    hookFrame(frame)
    --end
    -- TODO models mixins and overrides
    --if frameType == "Model" or frameType == "PlayerModel" or frameType == "DressUpModel" then
    --    ApplyMixinsAndOverrides(frame, ModelMixins)
    --    if hookModel then
    --        hookModel(frame)
    --    end
    --end
    return frame
end

function RegionMixins:SetShown(shown)
    if (self.shown == nil or self.shown ~= shown) then
        self[shown] = shown
    end

    if shown then
        self:Show()
    else
        self:Hide()
    end
end

function RegionMixins:IsShown()
    if (self.shown == nil) then
        self[shown] = true
    end
    return self.shown
end

function RegionMixins:SetSize(width, height)
    self:SetWidth(width)
    self:SetHeight(height)
end

function RegionOverrides:SetPoint(point, region, relativeFrame, offsetX, offsetY)
    if region == nil and relativeFrame == nil and offsetX == nil and offsetY == nil then
        self:_SetPoint(point, 0, 0)
    else
        self:_SetPoint(point, region, relativeFrame, offsetX, offsetY)
    end
end

function FrameMixins:SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight)
    self:SetMinResize(minWidth, minHeight)
    if maxWidth and maxHeight then
        self:SetMaxResize(maxWidth, maxHeight)
    end
end

function FrameMixins:GetNormalTexture()
    return self._normalTexture
end

function FrameMixins:GetPushedTexture()
    return self._pushedTexture
end

function FrameMixins:GetDisabledTexture()
    return self._disabledTexture
end

function FrameMixins:GetHighlightTexture()
    return self._highlightTexture
end

function FrameMixins:HookScript(script, handler)
    local old = self:GetScript(script)
    self:_SetScript(script, script == "OnEvent"
        and function()
            if old then old() end
            handler(this, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
        end
        or function()
            if old then old() end
            handler(this, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
        end)
end

function FrameOverrides:SetScript(script, handler)
    self:_SetScript(script, script == "OnEvent"
        and function() handler(this, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) end
        or function() handler(this, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) end)
end

function FrameOverrides:HookScript(script, handler)
    if self:GetScript(script) then
        self:_HookScript(script, handler)
    else
        self:SetScript(script, handler)
    end
end

function FrameOverrides:CreateTexture(name, layer)
    local region = self:_CreateTexture(name, layer)
    ApplyMixinsAndOverrides(region, RegionMixins, RegionOverrides)
    return region
end

function FrameOverrides:CreateFontString(name, layer, template)
    local region = self:_CreateFontString(name, layer, template)
    ApplyMixinsAndOverrides(region, RegionMixins, RegionOverrides)
    ApplyMixinsAndOverrides(region, FontStringMixins)
    return region
end

function FrameOverrides:SetNormalTexture(file)
    local texture = self:CreateTexture(nil, "ARTWORK")
    local success = texture:SetTexture(file)
    texture:SetAllPoints()
    self._normalTexture = texture
    self:_SetNormalTexture(texture)
    return success
end

function FrameOverrides:SetPushedTexture(file)
    local texture = self:CreateTexture(nil, "ARTWORK")
    local success = texture:SetTexture(file)
    texture:SetAllPoints()
    self._pushedTexture = texture
    self:_SetPushedTexture(texture)
    return success
end

function FrameOverrides:SetDisabledTexture(file)
    local texture = self:CreateTexture(nil, "ARTWORK")
    local success = texture:SetTexture(file)
    texture:SetAllPoints()
    self._disabledTexture = texture
    self:_SetDisabledTexture(texture)
    return success
end

function FrameOverrides:SetHighlightTexture(file)
    local texture = self:CreateTexture(nil, "HIGHLIGHT")
    local success = texture:SetTexture(file)
    texture:SetAllPoints()
    self._highlightTexture = texture
    self:_SetHighlightTexture(texture)
    return success
end
