local frame = CreateFrame("FRAME")
local myName = UnitName("player")
local enableDebug = true
local canSend = true

function debug(msg)
	if enableDebug then
		print(msg)
	end
end

frame:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
frame:RegisterEvent("CHAT_MSG_GUILD")

local defaultConfig = {
	frequency = 0.5,	-- 0 to 1, higher being more frequent
	baseWait = 5,
	waitDiff = 3,
	enableAG = true,
	CombatMute = false,
	grats_list = {"congrats!","congrats","grats","Grats!","Grats"}
}

local function sendDelay(sentence)
-- send chat and unlock canSend
	if GJ_Config.CombatMute then
		if not UnitAffectingCombat(myName) then
			SendChatMessage(sentence,"GUILD")
			debug("line 23 grats with word "..sentence)
		end
	else
		SendChatMessage(sentence,"GUILD")
		debug("Send grats:" .. sentence)
	end
	canSend = true
end

local function sendGrats(playerName)
	-- BEGIN of auto congrats
		debug("sendGrats():")
		local sentences = GJ_Config.grats_list

		if table.getn(sentences) == 0 then
			debug("nothing in the grats list!")
			do return end
		end

		local roll = math.random(table.getn(sentences))
		local sentence = sentences[roll]
		if math.random() < (1 - GJ_Config.frequency) then
			debug("No grats")
			do return end
		else
			debug("Yes grats")
		end
		
		local name,realm = strsplit("-",playerName)
		debug("canSend  " .. tostring(canSend) .. "  IsAFK:" .. tostring(UnitIsAFK)	 .. "  Name:" .. name)
		if canSend and not UnitIsAFK(myName) and name ~= myName then
			debug("pending send")
			canSend = false -- prevent the other events from firing
			if GJ_Config.waitDiff == 0 then
				debug("no diff")
				C_Timer.After((GJ_Config.baseWait), function() sendDelay(sentence) end)
			else
				debug("with diff") 
				C_Timer.After((GJ_Config.baseWait+math.random(GJ_Config.waitDiff)), function() sendDelay(sentence) end)
			end
		end
	-- END of auto congrats
end

-- event listener
function frame:OnEvent(event, arg1, arg2, arg3, arg4, ...)
	if evenet == "ADDON_LOADED" and arg1 == "GJ" then
		if not GJ_Config then
			GJ_Config = defaultConfig
		end
		debug("GJ_Config set")
	elseif event=="CHAT_MSG_GUILD_ACHIEVEMENT" then
		if not GJ_Config then
			GJ_Config = defaultConfig
		end
		if GJ_Config.enableAG then
			sendGrats(arg2)
    	end
    end
end

frame:SetScript("OnEvent", frame.OnEvent)

-- man if only i know how to write stuff in xml
local function showGUI()
	local GUI = CreateFrame("Frame", "GJ_GUI", UIParent, "BasicFrameTemplateWithInset");
	GUI:SetSize(680, 480);
	GUI:SetPoint("CENTER"); -- Doesn't need to be ("CENTER", UIParent, "CENTER")
	GUI.title = GUI:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	GUI.title:SetPoint("LEFT", GUI.TitleBg, "LEFT", 5, 0);
	GUI.title:SetText("GoodJob configuration");

	GUI.AGToggle = CreateFrame("Button", nil, GUI, "GameMenuButtonTemplate");
	GUI.AGToggle:SetPoint("LEFT", GUI, "TOP", -240, -70);
	GUI.AGToggle:SetSize(140, 40);


	if GJ_Config.enableAG then
		GUI.AGToggle:SetText("Enabled")
	else
		GUI.AGToggle:SetText("Disabled")
	end

	GUI.AGToggle:SetScript("OnClick", function(self)
		GJ_Config.enableAG = not GJ_Config.enableAG
		if GJ_Config.enableAG then
			GUI.AGToggle:SetText("Enabled")
		else
			GUI.AGToggle:SetText("Disabled")
		end
	end)

	GUI.AGToggle:SetNormalFontObject("GameFontNormalLarge");
	GUI.AGToggle:SetHighlightFontObject("GameFontHighlightLarge");


 	local baseTimeText = GUI:CreateFontString("GJ_baseTimeFontString", "ARTWORK", "GameFontNormal")
 	baseTimeText:SetText("Base wait time:")
	baseTimeText:SetPoint("CENTER", GUI.AGToggle, "TOP", -30, -70)
	baseTimeText:SetJustifyH("LEFT")
	baseTimeText:SetHeight(20)

	baseTimeNumber = GUI:CreateFontString("GJ_baseTimeFontString", "ARTWORK", "GameFontNormal")
 	baseTimeNumber:SetText(tostring(GJ_Config.baseWait))
	baseTimeNumber:SetPoint("CENTER", baseTimeText, "RIGHT", 40, 0)
	baseTimeNumber:SetJustifyH("LEFT")
	baseTimeNumber:SetHeight(18)

	GUI.baseTimeSlider = CreateFrame("Slider", nil, GUI, "OptionsSliderTemplate")
	GUI.baseTimeSlider:SetPoint("CENTER",GUI.AGToggle, "TOP", 0, -120);
	GUI.baseTimeSlider:SetSize(280, 30);
	GUI.baseTimeSlider:SetOrientation('HORIZONTAL')
	GUI.baseTimeSlider:SetMinMaxValues(0, 15);
	GUI.baseTimeSlider:SetValueStep(0.5)
	GUI.baseTimeSlider:SetValue(GJ_Config.baseWait)
	GUI.baseTimeSlider:SetObeyStepOnDrag(true)
	GUI.baseTimeSlider:SetScript("OnValueChanged",function(self,arg1)
		debug(arg1)
		GJ_Config.baseWait = arg1
		baseTimeNumber:SetText(tostring(arg1))
	end)

	local variableTimeText = GUI:CreateFontString("GJ_variableTimeString", "ARTWORK", "GameFontNormal")
	variableTimeText:SetText("Additional random time variance:")
	variableTimeText:SetPoint("CENTER", GUI.baseTimeSlider, "TOP", -30, -70)
	variableTimeText:SetJustifyH("LEFT")
	variableTimeText:SetHeight(20)

	variableTimeNumber = GUI:CreateFontString("GJ_baseTimeFontString", "ARTWORK", "GameFontNormal")
 	variableTimeNumber:SetText(tostring(GJ_Config.waitDiff))
	variableTimeNumber:SetPoint("CENTER", variableTimeText, "RIGHT", 40, 0)
	variableTimeNumber:SetJustifyH("LEFT")
	variableTimeNumber:SetHeight(18)

	GUI.variableTimeSlider = CreateFrame("Slider", nil, GUI, "OptionsSliderTemplate")
	GUI.variableTimeSlider:SetPoint("CENTER",GUI.baseTimeSlider, "TOP", 0, -120);
	GUI.variableTimeSlider:SetSize(280, 30);
	GUI.variableTimeSlider:SetOrientation('HORIZONTAL')
	GUI.variableTimeSlider:SetMinMaxValues(0, 15);
	GUI.variableTimeSlider:SetValueStep(0.5)
	GUI.variableTimeSlider:SetValue(GJ_Config.waitDiff)
	GUI.variableTimeSlider:SetObeyStepOnDrag(true)
	GUI.variableTimeSlider:SetScript("OnValueChanged",function(self,arg1)
		debug(arg1)
		GJ_Config.waitDiff = arg1
		variableTimeNumber:SetText(tostring(arg1))
	end)

	local probablityText = GUI:CreateFontString("GJ_probablityString", "ARTWORK", "GameFontNormal")
	probablityText:SetText("Chance of sending message:")
	probablityText:SetPoint("CENTER", GUI.variableTimeSlider, "TOP", -30, -70)
	probablityText:SetJustifyH("LEFT")
	probablityText:SetHeight(20)

	probablityNumber = GUI:CreateFontString("GJ_baseTimeFontString", "ARTWORK", "GameFontNormal")
 	probablityNumber:SetText(tostring(GJ_Config.frequency*100) .. "%")
	probablityNumber:SetPoint("CENTER", probablityText, "RIGHT", 40, 0)
	probablityNumber:SetJustifyH("LEFT")
	probablityNumber:SetHeight(18)

	GUI.probablitySlider = CreateFrame("Slider", nil, GUI, "OptionsSliderTemplate")
	GUI.probablitySlider:SetPoint("CENTER",GUI.variableTimeSlider, "TOP", 0, -120);
	GUI.probablitySlider:SetSize(280, 30);
	GUI.probablitySlider:SetOrientation('HORIZONTAL')
	GUI.probablitySlider:SetMinMaxValues(0, 100);
	GUI.probablitySlider:SetValueStep(5)
	GUI.probablitySlider:SetValue(GJ_Config.frequency*100)
	GUI.probablitySlider:SetObeyStepOnDrag(true)
	GUI.probablitySlider:SetScript("OnValueChanged",function(self,arg1)
		debug(arg1)
		GJ_Config.frequency = arg1/100
		probablityNumber:SetText(tostring(arg1) .. "%")
	end)

	GUI.battleMuteButton = CreateFrame("CheckButton",nil, GUI, "ChatConfigCheckButtonTemplate")
	GUI.battleMuteButton:SetPoint("CENTER",GUI.probablitySlider, "TOP", -135, -80);
	GUI.battleMuteButton:SetScript("OnClick",function(self)
		GJ_Config.CombatMute = GUI.battleMuteButton:GetChecked()
	end)

	local battleMuteText = GUI:CreateFontString("GJ_battleMuteString", "ARTWORK", "GameFontNormal")
	battleMuteText:SetText("Mute GJ while in combat")
	battleMuteText:SetPoint("CENTER", GUI.battleMuteButton, "RIGHT", 120, 0)
	battleMuteText:SetJustifyH("LEFT")
	battleMuteText:SetHeight(20)

	local gratsText = GUI:CreateFontString("GJ_probablityString", "ARTWORK", "GameFontNormal")
	gratsText:SetText("Messages to send (separated by new line):")
	gratsText:SetPoint("RIGHT", GUI, "CENTER", 270, 170)
	gratsText:SetJustifyH("LEFT")
	gratsText:SetHeight(20)


	local msgScroll = CreateFrame("ScrollFrame", "msgScrollFrame", GUI, "UIPanelScrollFrameTemplate")
	msgScroll:SetPoint("CENTER",gratsText, "TOP", 0, -200);
	msgScroll:SetSize(280, 280);

	local msgBox = CreateFrame("EditBox", "msgBox", msgScrollFrame)
    msgBox:SetSize(msgScroll:GetSize())
    msgBox:SetMultiLine(true)
    msgBox:SetAutoFocus(false) -- dont automatically focus
    msgBox:SetFontObject("ChatFontNormal")
    msgBox:SetScript("OnEscapePressed", function() GUI:Hide() end)
    msgBox:SetScript("OnTextChanged", function() 
    	gratsList = msgBox:GetText()

    	-- tempTable = gratsList:gsub(".",function(c) table.insert(t,c) end)
		lines = {}
		for s in gratsList:gmatch("[^\n]+") do
		    table.insert(lines, s)
		end

    	GJ_Config.grats_list = lines
    	debug(gratsList)

     end)
    msgScroll:SetScrollChild(msgBox)

    gratsList = ""
    for i,v in ipairs(GJ_Config.grats_list) do
    	gratsList = gratsList .. "\n" .. v
	end
	msgBox:SetText(gratsList)
    
end


SLASH_GJ1 = '/gj';
function SlashCmdList.GJ(msg)
	if not GJ_Config then
		GJ_Config = defaultConfig
	end
	if string.len(msg) < 1 then
			showGUI()
		-- change state based on msg
	end
end

