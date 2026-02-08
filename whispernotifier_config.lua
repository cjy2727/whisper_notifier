-- whispernotifier_config.lua
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
    L["VOLUME"] = "음량"
    L["CHANNEL"] = "출력 채널"
    L["CHANNEL_MASTER"] = "마스터"
    L["CHANNEL_SFX"] = "효과음"
    L["CHANNEL_MUSIC"] = "배경음악"
    L["CHANNEL_AMBIENCE"] = "환경음"
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
    L["VOLUME"] = "Volume"
    L["CHANNEL"] = "Channel"
    L["CHANNEL_MASTER"] = "Master"
    L["CHANNEL_SFX"] = "SFX"
    L["CHANNEL_MUSIC"] = "Music"
    L["CHANNEL_AMBIENCE"] = "Ambience"
end

local defaults = {
    fontSize = 42,
    posX = 0,
    posY = 880,
    alertMsg = L["DEFAULT_TEXT"],
	volume = 1,
	channel = "Master",
	mute = false
}

local FrameUtils = {}
function FrameUtils:CreateBaseFrame(name, width, height, parent)
    local frame = CreateFrame("Frame", name, parent or UIParent)
    frame:SetSize(width, height)
    frame:Hide()
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints(true)
    frame.bg:SetColorTexture(0, 0, 0, 0)
    return frame
end
function FrameUtils:CreateFontString(frame, text, font, size, color)
    local fontString = frame:CreateFontString(nil, "OVERLAY", font or "GameFontNormalHuge")
    fontString:SetPoint("CENTER")
    fontString:SetText(text)
    if color then
        fontString:SetTextColor(unpack(color))
    end
    if size then
        fontString:SetFont(fontString:GetFont(), size, "OUTLINE")
    end
    return fontString
end

WhisperNotifierConfig = {
    L = L,
    defaults = defaults,
    FrameUtils = FrameUtils
}

-- 옵션 UI 생성 함수
function WhisperNotifierConfig:CreateOptionsUI(frame, db)
    local options = CreateFrame("Frame", "WhisperNotifierOptions", UIParent)
    options.name = "WhisperNotifier"

    local title = options:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(self.L["TITLE"])

    local desc = options:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    desc:SetText(self.L["DESC"])

    return options
end
