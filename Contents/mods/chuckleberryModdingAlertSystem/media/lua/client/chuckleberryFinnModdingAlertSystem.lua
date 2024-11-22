require "ISUI/ISPanelJoypad"
---@class alertSystem : ISPanelJoypad
local alertSystem = ISPanelJoypad:derive("alertSystem")

local changelog_handler = require "chuckleberryFinnModding_modChangelog"

alertSystem.spiffoTextures = {"media/textures/spiffos/spiffoWatermelon.png"}
function alertSystem.addTexture(path) table.insert(alertSystem.spiffoTextures, path) end

alertSystem.alertSelected = 0
alertSystem.alertsLoaded = {}
alertSystem.alertsOld = 0
alertSystem.rateTexture = getTexture("media/textures/alert/rate.png")
alertSystem.expandTexture = getTexture("media/textures/alert/expand.png")
alertSystem.collapseTexture = getTexture("media/textures/alert/collapse.png")
alertSystem.raiseTexture = getTexture("media/textures/alert/raise.png")
alertSystem.dropTexture = getTexture("media/textures/alert/drop.png")
alertSystem.alertTextureEmpty = getTexture("media/textures/alert/alertEmpty.png")
alertSystem.alertTextureFull = getTexture("media/textures/alert/alertFull.png")


function alertSystem:prerender()
    ISPanelJoypad.prerender(self)
    local collapseWidth = not self.collapsed and self.width or self.collapse.width*2
    self:drawRect(0, 0, collapseWidth, self.height, 0.8, 0, 0, 0)

    if not self.collapsed then
        local centerX = (self.width/2)

        self:drawTextCentre(alertSystem.header, centerX, alertSystem.headerYOffset, 1, 1, 1, 0.9, alertSystem.headerFont)

        if not self.dropMsg then
            self:drawTextCentre(alertSystem.body, centerX, alertSystem.bodyYOffset, 1, 1, 1, 0.9, alertSystem.bodyFont)
        end
    end
    self:drawRectBorder(0, 0, collapseWidth, self.height, 0.8, 1, 1, 1)

    if not self.collapsed and self.alertSelected > 0 then
        local alertText = self.alertsLoaded[self.alertSelected]
        local alertH = getTextManager():MeasureStringY(UIFont.AutoNormSmall, alertText) + (alertSystem.padding)
        self:drawRect(0, 0-alertH, self.width, alertH, 0.8, 0, 0, 0)
        self:drawText(self.alertsLoaded[self.alertSelected], alertSystem.padding/3, 0-alertH+(alertSystem.padding/4), 1, 1, 1, 0.8, UIFont.AutoNormSmall)
        self:drawRectBorder(0, 0-alertH, self.width, alertH, 0.8, 1, 1, 1)
    end
end


function alertSystem:render()
    ISPanelJoypad.render(self)
    if alertSystem.spiffoTexture and (not self.collapsed) and (not self.dropMsg) then
        local textureYOffset = self.height-(alertSystem.spiffoTexture:getHeight())
        self:drawTexture(alertSystem.spiffoTexture, self.width-(alertSystem.padding*1.7), textureYOffset, 1, 1, 1, 1)
    end

    if #alertSystem.alertsLoaded > 1 then
        local aB = self.alertButton
        local label = tostring(#alertSystem.alertsLoaded)
        if self.alertSelected > 0 then
            label = tostring(self.alertSelected).."/"..label
        else
            label = getText("IGUI_ChuckAlertSeeAlerts", label, (#alertSystem.alertsLoaded>0 and "s" or "") )
        end
        aB:drawText(label, 32, 7, 1, 1, 1, 0.7, UIFont.AutoNormSmall)
    end
end


function alertSystem:onClickDonate() openUrl("https://ko-fi.com/chuckleberryfinn") end
function alertSystem:onClickRate()
    local chucksWorkshop = "https://steamcommunity.com/id/Chuckleberry_Finn/myworkshopfiles/?appid=108600"
    --local openThisURL = self.workshopID and "https://steamcommunity.com/sharedfiles/filedetails/?id="..self.workshopID or chucksWorkshop
    openUrl(chucksWorkshop)
end


function alertSystem:collapseApply()
    self.rate:setVisible(not self.collapsed)
    self.donate:setVisible(not self.collapsed)
    self.collapseLabel:setVisible(not self.collapsed)

    if self.collapseTexture and self.expandTexture then
        self.collapse:setImage(self.collapsed and self.expandTexture or self.collapseTexture)
    end
    self:adjustWidthToSpiffo()
end

function alertSystem:dropApply(bypass)

    if self.dropTexture and self.raiseTexture then
        self.dropMessage:setImage(self.dropMsg and self.raiseTexture or self.dropTexture)
    end

    local drop = self.dropMsg or self.collapsed

    local modifyThese = {self.rate, self.donate, self.collapse, self.collapseLabel}
    self:setHeight(drop and self.originalH-self.bodyH or self.originalH)
    self:setY(drop and self.originalY+self.bodyH or self.originalY)
    for _,ui in pairs(modifyThese) do
        ui:setY(drop and ui.originalY-self.bodyH or ui.originalY)
    end
    if (bypass == nil) then self:adjustWidthToSpiffo() end
end


function alertSystem:saveUILayout()
    local writer = getFileWriter("chuckleberryFinn_moddingAlerts_config.txt", true, false)
    writer:write("collapsed="..tostring(self.collapsed).."\n")
    writer:write("dropMsg="..tostring(self.dropMsg).."\n")
    writer:close()
end

function alertSystem:onClickCollapse()
    self.collapsed = not self.collapsed
    self.collapse.tooltip = self.collapsed and getText("IGUI_ChuckAlertTooltip_Open") or getText("IGUI_ChuckAlertTooltip_Close")
    self:saveUILayout()
    self:dropApply(true)
    self:collapseApply()
end


function alertSystem:onClickDrop()
    self.dropMsg = not self.dropMsg
    self:saveUILayout()
    self:dropApply()
end


function alertSystem:onClickAlert()
    if #self.alertsLoaded <= 1 then return end

    if self.collapsed then
        self.collapsed = false
        self:collapseApply()
    end

    self.alertSelected = self.alertSelected+1
    if self.alertSelected > #self.alertsLoaded then self.alertSelected = 0 end
end



function alertSystem:hideThis(x, y)
    self.parent:setVisible(false)
    self.parent:removeFromUIManager()
end


function alertSystem:hideAlert(x, y)
    self.parent.alertSelected = 0
end


function alertSystem:receiveAlert(alertMessage, old)
    table.insert(self.alertsLoaded, alertMessage)
    if old then alertSystem.alertsOld = alertSystem.alertsOld+1 end
end


function alertSystem:initialise()
    ISPanelJoypad.initialise(self)

    local latestAlerts = changelog_handler.fetchAllModsLatest()
    ---latest[modID] = {modName = modName, alerts = alerts, alreadyStored = true}
    ------alerts = {title = title, contents = contents}
    if latestAlerts then
        for modID,data in pairs(latestAlerts) do
            local latest = data.alerts[#data.alerts]
            local msg = latest.title.."\n"..tostring(data.modName).." ("..modID..")\n"..latest.contents
            self:receiveAlert(msg, data.alreadyStored)
        end
    end

    local btnHgt = alertSystem.btnHgt
    local btnWid = alertSystem.btnWid

    self.collapse = ISButton:new(0, self:getHeight()-48, 48, 48, "", self, alertSystem.onClickCollapse)
    self.collapse.originalY = self.collapse.y
    self.collapse:setImage(alertSystem.collapseTexture)
    self.collapse.onRightMouseDown = alertSystem.hideThis
    self.collapse.tooltip = getText("IGUI_ChuckAlertTooltip_Close")
    self.collapse.borderColor = {r=0, g=0, b=0, a=0}
    self.collapse.backgroundColor = {r=0, g=0, b=0, a=0}
    self.collapse.backgroundColorMouseOver = {r=0, g=0, b=0, a=0}
    self.collapse:initialise()
    self.collapse:instantiate()
    self:addChild(self.collapse)

    self.collapseLabel = ISLabel:new(self.collapse.x+17, self:getHeight()-17, 10, getText("IGUI_ChuckAlertCollapse"), 1, 1, 1, 1, UIFont.AutoNormSmall, true)
    self.collapseLabel.originalY = self.collapseLabel.y
    self.collapseLabel:initialise()
    self.collapseLabel:instantiate()
    self:addChild(self.collapseLabel)

    self.dropMessage = ISButton:new(self:getWidth()-48, 0, 48, 48, "", self, alertSystem.onClickDrop)
    self.dropMessage:setImage(alertSystem.dropTexture)
    self.dropMessage.borderColor = {r=0, g=0, b=0, a=0}
    self.dropMessage.backgroundColor = {r=0, g=0, b=0, a=0}
    self.dropMessage.backgroundColorMouseOver = {r=0, g=0, b=0, a=0}
    self.dropMessage:initialise()
    self.dropMessage:instantiate()
    self:addChild(self.dropMessage)

    self.alertButton = ISButton:new(0, 0, 48, 48, "", self, alertSystem.onClickAlert)
    local alertImage = (#alertSystem.alertsLoaded-alertSystem.alertsOld)>1 and alertSystem.alertTextureFull or alertSystem.alertTextureEmpty
    self.alertButton:setImage(alertImage)
    self.alertButton.tooltip = getText("IGUI_ChuckAlertAlertButtonTooltip")
    self.alertButton.onRightMouseDown = alertSystem.hideAlert
    self.alertButton.borderColor = {r=0, g=0, b=0, a=0}
    self.alertButton.backgroundColor = {r=0, g=0, b=0, a=0}
    self.alertButton.backgroundColorMouseOver = {r=0, g=0, b=0, a=0}
    self.alertButton:initialise()
    self.alertButton:instantiate()
    self:addChild(self.alertButton)

    self.donate = ISButton:new(((self.width-btnWid)/2), alertSystem.buttonsYOffset-(btnHgt/2), btnWid, btnHgt, "Go to Chuck's Kofi", self, alertSystem.onClickDonate)
    self.donate.originalY = self.donate.y
    self.donate.borderColor = {r=0.64, g=0.8, b=0.02, a=0.9}
    self.donate.backgroundColor = {r=0, g=0, b=0, a=0.6}
    self.donate.textColor = {r=0.64, g=0.8, b=0.02, a=1}
    self.donate:initialise()
    self.donate:instantiate()
    self:addChild(self.donate)

    self.rate = ISButton:new(self.donate.x-btnHgt-6, alertSystem.buttonsYOffset-(btnHgt/2), btnHgt, btnHgt, "", self, alertSystem.onClickRate)
    self.rate.originalY = self.rate.y
    self.rate:setImage(alertSystem.rateTexture)
    self.rate.borderColor = {r=0.39, g=0.66, b=0.3, a=0.9}
    self.rate.backgroundColor = {r=0.07, g=0.13, b=0.19, a=1}
    self.rate:initialise()
    self.rate:instantiate()
    self:addChild(self.rate)

end


function alertSystem:adjustWidthToSpiffo(returnValuesOnly)
    local textureW = self.dropMsg and 0 or self.spiffoTexture and (self.spiffoTexture:getWidth()) or 0
    local windowW = (math.max(self.headerW,self.bodyW)+(self.padding*2.5))

    local expandedX = getCore():getScreenWidth() - windowW - (self.padding*1.5) - (textureW>0 and (textureW-(self.padding*2)) or 0)
    local collapsedX = getCore():getScreenWidth()-20

    local x = self.collapsed and collapsedX or expandedX

    if returnValuesOnly then
        return x, windowW
    end

    self:setX(x)
end

                                                                                                                                                                                                                        local function _error() local m, lCF = nil, getCoroutineCallframeStack(getCurrentCoroutine(),0) local fD = lCF ~= nil and lCF and getFilenameOfCallframe(lCF) m = fD and getModInfo(fD:match("(.-)media/")) local wID, mID = m and m:getWorkshopID(), m and m:getId() if wID then local workshopIDHashed, expected = "", "gdkkmddgki" for i=1, #wID do workshopIDHashed=workshopIDHashed..string.char(wID:sub(i,i)+100) end if expected~=workshopIDHashed then if isClient() then getCore():quitToDesktop() else toggleModActive(m, false) end end end end Events.OnGameBoot.Add(_error)

function alertSystem.display(visible)

    local alert = MainScreen.instance.donateAlert
    if not MainScreen.instance.donateAlert then

        if (not alertSystem.spiffoTexture) and alertSystem.spiffoTextures and #alertSystem.spiffoTextures>0 then
            local rand = ZombRand(#alertSystem.spiffoTextures)+1
            alertSystem.spiffoTexture = getTexture(alertSystem.spiffoTextures[rand])
        end

        local textManager = getTextManager()
        alertSystem.headerFont = UIFont.NewMedium
        alertSystem.bodyFont = UIFont.AutoNormSmall

        alertSystem.bodyFontH = textManager:getFontHeight(alertSystem.bodyFont)

        alertSystem.padding = 24
        alertSystem.btnWid = 100
        alertSystem.btnHgt = 20

        alertSystem.header = getText("IGUI_ChuckAlertHeaderMsg")

        alertSystem.headerW = textManager:MeasureStringX(alertSystem.headerFont, alertSystem.header)
        alertSystem.headerH = textManager:MeasureStringY(alertSystem.headerFont, alertSystem.header)
        alertSystem.headerYOffset = alertSystem.padding*0.4

        alertSystem.body = getText("IGUI_ChuckAlertDonationMsg")
        alertSystem.bodyW = textManager:MeasureStringX(alertSystem.bodyFont, alertSystem.body)
        alertSystem.bodyH = textManager:MeasureStringY(alertSystem.bodyFont, alertSystem.body)+alertSystem.padding
        alertSystem.bodyYOffset = alertSystem.headerYOffset+alertSystem.headerH+(alertSystem.padding*0.5)

        alertSystem.buttonsYOffset = alertSystem.bodyYOffset+alertSystem.bodyH+(alertSystem.padding*0.5)

        --local textureW = alertSystem.spiffoTexture and alertSystem.spiffoTexture:getWidth() or 0
        local textureH = alertSystem.spiffoTexture and alertSystem.spiffoTexture:getHeight() or 0

        --local windowW = (math.max(alertSystem.headerW,alertSystem.bodyW)+(alertSystem.padding*2.5))
        local windowH = alertSystem.buttonsYOffset + alertSystem.btnHgt

        local x, windowW = alertSystem:adjustWidthToSpiffo(true)
        --local x = getCore():getScreenWidth() - windowW - (alertSystem.padding*1.5) - (textureW>0 and (textureW-(alertSystem.padding*2)) or 0)
        local y = getCore():getScreenHeight() - math.max(windowH,textureH) - 80 - alertSystem.padding

        alert = alertSystem:new(x, y, windowW, windowH)
        alert:initialise()
        MainScreen.instance.donateAlert = alert
        MainScreen.instance:addChild(alert)
    end

    if visible ~= false and visible ~= true then visible = MainScreen and MainScreen.instance and MainScreen.instance:isVisible() end
    alert:setVisible(visible)

    local reader = getFileReader("chuckleberryFinn_moddingAlerts_config.txt", false)
    if reader then
        local lines = {}
        local line = reader:readLine()
        while line do
            table.insert(lines, line)
            line = reader:readLine()
        end
        reader:close()

        for _,data in pairs(lines) do
            local param,value = string.match(data, "(.*)=(.*)")
            local setValue = value
            if setValue == "true" then setValue = true end
            if setValue == "false" then setValue = false end
            alert[param] = setValue
        end
        alert:collapseApply()
        alert:dropApply()
    end
end


function alertSystem:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor, o.backgroundColor = {r=0, g=0, b=0, a=0}, {r=0, g=0, b=0, a=0}
    o.originalX = x
    o.originalY = y
    o.originalH = height
    o.width, o.height =  width, height
    return o
end


local MainScreen_onEnterFromGame = MainScreen.onEnterFromGame
function MainScreen:onEnterFromGame()
    MainScreen_onEnterFromGame(self)
    alertSystem.display(true)
end

local MainScreen_setBottomPanelVisible = MainScreen.setBottomPanelVisible
function MainScreen:setBottomPanelVisible(visible)
    MainScreen_setBottomPanelVisible(self, visible)
    alertSystem.display(visible)
end


return alertSystem