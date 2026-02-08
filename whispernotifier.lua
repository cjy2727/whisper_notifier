local addonName = ...

local L = WhisperNotifierConfig.L
local defaults = WhisperNotifierConfig.defaults
local FrameUtils = WhisperNotifierConfig.FrameUtils
local frame = FrameUtils:CreateBaseFrame("WhisperNotifierFrame", 400, 80, UIParent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("CHAT_MSG_BN_WHISPER")

local options = WhisperNotifierConfig:CreateOptionsUI(frame, WhisperNotifierDB2)

frame.bg = frame:CreateTexture(nil, "BACKGROUND")
frame.bg:SetAllPoints(true)
frame.bg:SetColorTexture(0, 0, 0, 0)

frame.text = FrameUtils:CreateFontString(frame, defaults.alertMsg, "GameFontNormalHuge", defaults.fontSize, {1, 1, 0, 1})
local fontPath = frame.text:GetFont()

frame.anim = frame.text:CreateAnimationGroup()
local fadeOut = frame.anim:CreateAnimation("Alpha")
fadeOut:SetFromAlpha(1)
fadeOut:SetToAlpha(0.2)
fadeOut:SetDuration(0.4)
fadeOut:SetOrder(1)

local fadeIn = frame.anim:CreateAnimation("Alpha")
fadeIn:SetFromAlpha(0.2)
fadeIn:SetToAlpha(1)
fadeIn:SetDuration(0.4)
fadeIn:SetOrder(2)

frame.anim:SetLooping("REPEAT")

local options = CreateFrame("Frame", "WhisperNotifierOptions", UIParent)
options.name = "WhisperNotifier"

local title = options:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText(L["TITLE"])

local desc = options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
desc:SetText(L["DESC"])

local function CreateNumberBox(parent, width)
    local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    box:SetSize(width, 20)
    box:SetAutoFocus(false)
    return box
end

local sizeSlider, ySlider, xSlider, msgLabel
local sizeEditBox, yEditBox, xEditBox, msgEditBox

msgLabel = options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
msgLabel:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -30)
msgLabel:SetText(L["MSG_LABEL"])
msgEditBox = CreateNumberBox(options, 200)
msgEditBox:SetPoint("LEFT", msgLabel, "RIGHT", 10, 0)
msgEditBox:SetScript("OnEnterPressed", function(self)
    local v = self:GetText()
    if v and v ~= "" then
        WhisperNotifierDB2.alertMsg = v
        frame.text:SetText(v)
    end
    self:ClearFocus()
end)

local muteCheckBox = CreateFrame("CheckButton", "WhisperNotifierMuteCheckBox", options, "ChatConfigCheckButtonTemplate")
muteCheckBox:SetPoint("LEFT", msgEditBox, "RIGHT", 10, 0)
muteCheckBox.Text:SetText(L["MUTE"])
muteCheckBox:SetChecked(false)
muteCheckBox:SetScript("OnClick", function(self)
    WhisperNotifierDB2.mute = self:GetChecked()
end)

sizeSlider = CreateFrame("Slider", "WhisperNotifierFontSize", options, "OptionsSliderTemplate")
sizeSlider:SetPoint("TOPLEFT", msgLabel, "BOTTOMLEFT", 0, -40)
sizeSlider:SetMinMaxValues(20, 80)
sizeSlider:SetValueStep(1)
sizeSlider:SetWidth(240)
_G[sizeSlider:GetName().."Low"]:SetText("20")
_G[sizeSlider:GetName().."High"]:SetText("80")
_G[sizeSlider:GetName().."Text"]:SetText(L["FONT_SIZE"])
sizeEditBox = CreateNumberBox(options, 50)
sizeEditBox:SetPoint("LEFT", sizeSlider, "RIGHT", 10, 0)
sizeSlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value)
    WhisperNotifierDB2.fontSize = value
    frame.text:SetFont(fontPath, value, "OUTLINE")
    sizeEditBox:SetText(value)
end)
sizeEditBox:SetScript("OnEnterPressed", function(self)
    local v = tonumber(self:GetText())
    if v then sizeSlider:SetValue(math.max(20, math.min(80, v))) end
    self:ClearFocus()
end)

ySlider = CreateFrame("Slider", "WhisperNotifierPosY", options, "OptionsSliderTemplate")
ySlider:SetPoint("TOPLEFT", sizeSlider, "BOTTOMLEFT", 0, -40)
ySlider:SetMinMaxValues(0, 1200)
ySlider:SetValueStep(5)
ySlider:SetWidth(240)
_G[ySlider:GetName().."Low"]:SetText("0")
_G[ySlider:GetName().."High"]:SetText("1200")
_G[ySlider:GetName().."Text"]:SetText(L["POS_Y"])
yEditBox = CreateNumberBox(options, 50)
yEditBox:SetPoint("LEFT", ySlider, "RIGHT", 10, 0)
ySlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value)
    WhisperNotifierDB2.posY = value
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "BOTTOM", WhisperNotifierDB2.posX, value)
    yEditBox:SetText(value)
end)
yEditBox:SetScript("OnEnterPressed", function(self)
    local v = tonumber(self:GetText())
    if v then ySlider:SetValue(math.max(0, math.min(1200, v))) end
    self:ClearFocus()
end)


xSlider = CreateFrame("Slider", "WhisperNotifierPosX", options, "OptionsSliderTemplate")
xSlider:SetPoint("TOPLEFT", ySlider, "BOTTOMLEFT", 0, -40)
xSlider:SetMinMaxValues(-800, 800)
xSlider:SetValueStep(5)
xSlider:SetWidth(240)
_G[xSlider:GetName().."Low"]:SetText("-800")
_G[xSlider:GetName().."High"]:SetText("800")
_G[xSlider:GetName().."Text"]:SetText(L["POS_X"])
xEditBox = CreateNumberBox(options, 50)
xEditBox:SetPoint("LEFT", xSlider, "RIGHT", 10, 0)
xSlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value)
    WhisperNotifierDB2.posX = value
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "BOTTOM", value, WhisperNotifierDB2.posY)
    xEditBox:SetText(value)
end)
xEditBox:SetScript("OnEnterPressed", function(self)
    local v = tonumber(self:GetText())
    if v then xSlider:SetValue(math.max(-800, math.min(800, v))) end
    self:ClearFocus()
end)

local volumeSlider = CreateFrame("Slider", "WhisperNotifierVolume", options, "OptionsSliderTemplate")
volumeSlider:SetPoint("TOPLEFT", xSlider, "BOTTOMLEFT", 0, -40)
volumeSlider:SetMinMaxValues(0, 100)
volumeSlider:SetValueStep(1)
volumeSlider:SetWidth(240)
_G[volumeSlider:GetName().."Low"]:SetText("0%")
_G[volumeSlider:GetName().."High"]:SetText("100%")
_G[volumeSlider:GetName().."Text"]:SetText(L["VOLUME"])
local volumeEditBox = CreateNumberBox(options, 50)
volumeEditBox:SetPoint("LEFT", volumeSlider, "RIGHT", 10, 0)
local function SetVolumePercent(percent)
    percent = math.max(0, math.min(100, math.floor(percent or 0)))
    WhisperNotifierDB2.volume = percent / 100
    if volumeSlider:GetValue() ~= percent then
        volumeSlider:SetValue(percent)
    end
    if tonumber(volumeEditBox:GetText()) ~= percent then
        volumeEditBox:SetText(percent)
    end
end
volumeSlider:SetScript("OnValueChanged", function(self, value)
    SetVolumePercent(value)
end)
volumeEditBox:SetScript("OnEnterPressed", function(self)
    local v = tonumber(self:GetText())
    SetVolumePercent(v)
    self:ClearFocus()
end)

local channelDropdown = CreateFrame("Frame", "WhisperNotifierChannelDropdown", options, "UIDropDownMenuTemplate")
channelDropdown:SetPoint("LEFT", volumeEditBox, "RIGHT", 10, 0)
local channels = {
    {text=L["CHANNEL_MASTER"], value="Master"},
    {text=L["CHANNEL_SFX"], value="SFX"},
    {text=L["CHANNEL_MUSIC"], value="Music"},
    {text=L["CHANNEL_AMBIENCE"], value="Ambience"}
}
local function ChannelDropdown_OnClick(self)
    WhisperNotifierDB2.channel = self.value
    UIDropDownMenu_SetSelectedValue(channelDropdown, self.value)
end
UIDropDownMenu_Initialize(channelDropdown, function(self, level)
    for _, ch in ipairs(channels) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = ch.text
        info.value = ch.value
        info.func = ChannelDropdown_OnClick
        UIDropDownMenu_AddButton(info)
    end
end)
UIDropDownMenu_SetWidth(channelDropdown, 100)
UIDropDownMenu_SetSelectedValue(channelDropdown, WhisperNotifierDB2 and WhisperNotifierDB2.channel or "Master")

local testBtn = CreateFrame("Button", nil, options, "UIPanelButtonTemplate")
testBtn:SetPoint("TOPLEFT", volumeSlider, "BOTTOMLEFT", 0, -24)
testBtn:SetSize(140, 26)
testBtn:SetText(L["TEST_BTN"])
testBtn:SetScript("OnClick", function()
    frame:GetScript("OnEvent")(frame, "TEST")
end)

local function RefreshOptionsUI()
    if not WhisperNotifierDB2 then return end
    sizeSlider:SetValue(WhisperNotifierDB2.fontSize)
    ySlider:SetValue(WhisperNotifierDB2.posY)
    xSlider:SetValue(WhisperNotifierDB2.posX)
    sizeEditBox:SetText(WhisperNotifierDB2.fontSize)
    yEditBox:SetText(WhisperNotifierDB2.posY)
    xEditBox:SetText(WhisperNotifierDB2.posX)
    msgEditBox:SetText(WhisperNotifierDB2.alertMsg)
    muteCheckBox:SetChecked(WhisperNotifierDB2.mute or false)
    local percent = math.floor((WhisperNotifierDB2.volume or 1) * 100 + 0.5)
    volumeSlider:SetValue(percent)
    volumeEditBox:SetText(percent)
    UIDropDownMenu_SetSelectedValue(channelDropdown, WhisperNotifierDB2.channel or "Master")
end

options:SetScript("OnShow", RefreshOptionsUI)

if Settings and Settings.RegisterCanvasLayoutCategory then
    local category = Settings.RegisterCanvasLayoutCategory(options, "WhisperNotifier")
    Settings.RegisterAddOnCategory(category)
else
    InterfaceOptions_AddCategory(options)
end

local hideTimer

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        WhisperNotifierDB2 = WhisperNotifierDB2 or {}
        for k, v in pairs(defaults) do
            if WhisperNotifierDB2[k] == nil then
                WhisperNotifierDB2[k] = v
            end
        end
        frame.text:SetFont(fontPath, WhisperNotifierDB2.fontSize, "OUTLINE")
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "BOTTOM", WhisperNotifierDB2.posX, WhisperNotifierDB2.posY)
        return
    end
    if event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_BN_WHISPER" or event == "TEST" then
        if hideTimer then hideTimer:Cancel() end
        self:Show()
        if not self.anim:IsPlaying() then self.anim:Play() end
        local playSound = not (WhisperNotifierDB2 and WhisperNotifierDB2.mute)
        if playSound then
            local channel = WhisperNotifierDB2.channel or "Master"
			local cvarName = "Sound_MasterVolume"
			if channel == "SFX" then cvarName = "Sound_SFXVolume"
			elseif channel == "Music" then cvarName = "Sound_MusicVolume"
			elseif channel == "Ambience" then cvarName = "Sound_AmbienceVolume" end
			local prevVolume = tonumber(GetCVar(cvarName)) or 1
			local addonVolume = WhisperNotifierDB2.volume or 1
			local tempVolume = prevVolume * addonVolume
			SetCVar(cvarName, tempVolume)
			PlaySound(15273, channel)
			C_Timer.After(0.5, function()
				SetCVar(cvarName, prevVolume)
			end)
        end
        hideTimer = C_Timer.NewTimer(3, function()
            self.anim:Stop()
            self.text:SetAlpha(1)
            self:Hide()
        end)
    end
end)
