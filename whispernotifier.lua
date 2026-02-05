local addonName = ...

local L = {}
local locale = GetLocale()

if locale == "koKR" then
    L["TITLE"] = "WhisperNotifier"
    L["DESC"] = "귓말 수신 시 화면 알림과 사운드를 표시합니다."
    L["MSG_LABEL"] = "알림 메시지"
    L["FONT_SIZE"] = "글자 크기"
    L["POS_Y"] = "세로 위치 (Y)"
    L["POS_X"] = "가로 위치 (X)"
    L["TEST_BTN"] = "테스트 알림"
    L["DEFAULT_TEXT"] = "귓말 확인하기!"
    L["MUTE"] = "음소거"
else
    L["TITLE"] = "WhisperNotifier"
    L["DESC"] = "Show an on-screen alert and play a sound when you receive a whisper."
	L["MSG_LABEL"] = "Alert Message"
    L["FONT_SIZE"] = "Font Size"
    L["POS_Y"] = "Vertical Position (Y)"
    L["POS_X"] = "Horizontal Position (X)"
    L["TEST_BTN"] = "Test Alert"
    L["DEFAULT_TEXT"] = "Check Whispers!"
    L["MUTE"] = "Mute"
end

local defaults = {
    fontSize = 42,
    posX = 0,
    posY = 880,
    alertMsg = L["DEFAULT_TEXT"],
}

local frame = CreateFrame("Frame", "WhisperNotifierFrame", UIParent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("CHAT_MSG_BN_WHISPER")
frame:SetSize(400, 80)
frame:Hide()

frame.bg = frame:CreateTexture(nil, "BACKGROUND")
frame.bg:SetAllPoints(true)
frame.bg:SetColorTexture(0, 0, 0, 0)

frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
frame.text:SetPoint("CENTER")
frame.text:SetText(defaults.alertMsg)
frame.text:SetTextColor(1, 1, 0, 1)

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
        WhisperNotifierDB.alertMsg = v
        frame.text:SetText(v)
    end
    self:ClearFocus()
end)

-- 음소거 체크박스 추가
local muteCheckBox = CreateFrame("CheckButton", "WhisperNotifierMuteCheckBox", options, "ChatConfigCheckButtonTemplate")
muteCheckBox:SetPoint("LEFT", msgEditBox, "RIGHT", 10, 0)
muteCheckBox.Text:SetText(L["MUTE"])
muteCheckBox:SetChecked(false)
muteCheckBox:SetScript("OnClick", function(self)
    WhisperNotifierDB.mute = self:GetChecked()
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
    WhisperNotifierDB.fontSize = value
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
    WhisperNotifierDB.posY = value
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "BOTTOM", WhisperNotifierDB.posX, value)
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
    WhisperNotifierDB.posX = value
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "BOTTOM", value, WhisperNotifierDB.posY)
    xEditBox:SetText(value)
end)
xEditBox:SetScript("OnEnterPressed", function(self)
    local v = tonumber(self:GetText())
    if v then xSlider:SetValue(math.max(-800, math.min(800, v))) end
    self:ClearFocus()
end)

local testBtn = CreateFrame("Button", nil, options, "UIPanelButtonTemplate")
testBtn:SetPoint("TOPLEFT", xSlider, "BOTTOMLEFT", 0, -60)
testBtn:SetSize(140, 26)
testBtn:SetText(L["TEST_BTN"])
testBtn:SetScript("OnClick", function()
    frame:GetScript("OnEvent")(frame, "TEST")
end)

local function RefreshOptionsUI()
    if not WhisperNotifierDB then return end
    sizeSlider:SetValue(WhisperNotifierDB.fontSize)
    ySlider:SetValue(WhisperNotifierDB.posY)
    xSlider:SetValue(WhisperNotifierDB.posX)
    sizeEditBox:SetText(WhisperNotifierDB.fontSize)
    yEditBox:SetText(WhisperNotifierDB.posY)
    xEditBox:SetText(WhisperNotifierDB.posX)
    msgEditBox:SetText(WhisperNotifierDB.alertMsg)
    muteCheckBox:SetChecked(WhisperNotifierDB.mute or false)
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
        WhisperNotifierDB = WhisperNotifierDB or {}
        for k, v in pairs(defaults) do
            if WhisperNotifierDB[k] == nil then
                WhisperNotifierDB[k] = v
            end
        end
        frame.text:SetFont(fontPath, WhisperNotifierDB.fontSize, "OUTLINE")
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "BOTTOM", WhisperNotifierDB.posX, WhisperNotifierDB.posY)
        return
    end
    if event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_BN_WHISPER" or event == "TEST" then
        if hideTimer then hideTimer:Cancel() end
        self:Show()
        if not self.anim:IsPlaying() then self.anim:Play() end
            if not (WhisperNotifierDB and WhisperNotifierDB.mute) then
                PlaySound(15273, "Master")
            end
        hideTimer = C_Timer.NewTimer(3, function()
            self.anim:Stop()
            self.text:SetAlpha(1)
            self:Hide()
        end)
    end
end)
