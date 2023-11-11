require "ISUI/ISPanelJoypad"
---@class alertSystem : ISPanelJoypad
local alertSystem = ISPanelJoypad:derive("alertSystem")

local modCountSystem = require "chuckleberryFinnModding_modCountSystem"

alertSystem.spiffoTextures = {"media/textures/spiffos/spiffoWatermelon.png"}
function alertSystem.addTexture(path) table.insert(alertSystem.spiffoTextures, path) end

alertSystem.alertSelected = 1
alertSystem.alertsLoaded = {false}
alertSystem.rateTexture = getTexture("media/textures/alert/rate.png")
alertSystem.expandTexture = getTexture("media/textures/alert/expand.png")
alertSystem.collapseTexture = getTexture("media/textures/alert/collapse.png")
alertSystem.alertTextureEmpty = getTexture("media/textures/alert/alertEmpty.png")
alertSystem.alertTextureFull = getTexture("media/textures/alert/alertFull.png")

function alertSystem:prerender()
    ISPanelJoypad.prerender(self)
    local collapseWidth = not self.collapsed and self.width or self.collapse.width*2
    self:drawRect(0, 0, collapseWidth, self.height, 0.5, 0, 0, 0)

    if not self.collapsed then
        local centerX = (self.width/2)
        self:drawTextCentre(alertSystem.header, centerX, alertSystem.headerYOffset, 1, 1, 1, 0.9, alertSystem.headerFont)
        self:drawTextCentre(alertSystem.body, centerX, alertSystem.bodyYOffset, 1, 1, 1, 0.8, alertSystem.bodyFont)
    end
    self:drawRectBorder(0, 0, collapseWidth, self.height, 0.6, 1, 1, 1)

    if not self.collapsed and self.alertSelected > 1 then
        self:drawRect(0, 0-75, self.width, 75, 0.5, 0, 0, 0)
        self:drawText(self.alertsLoaded[self.alertSelected], alertSystem.padding/4, 0-75+(alertSystem.padding/4), 1, 1, 1, 0.7, UIFont.AutoNormSmall)
        self:drawRectBorder(0, 0-75, self.width, 75, 0.4, 1, 1, 1)
    end
end


function alertSystem:render()
    ISPanelJoypad.render(self)
    if alertSystem.spiffoTexture and (not self.collapsed) then
        local textureYOffset = (self.height-alertSystem.spiffoTexture:getHeight())/2
        self:drawTexture(alertSystem.spiffoTexture, self.width-(alertSystem.padding*1.75), textureYOffset, 1, 1, 1, 1)
    end
end


function alertSystem:onClickDonate() openUrl("https://ko-fi.com/chuckleberryfinn") end
function alertSystem:onClickRate()
    local chucksWorkshop = "https://steamcommunity.com/id/Chuckleberry_Finn/myworkshopfiles/?appid=108600"
    local openThisURL = self.workshopID and "https://steamcommunity.com/sharedfiles/filedetails/?id="..self.workshopID or chucksWorkshop
    openUrl(openThisURL)
end


function alertSystem:collapseApply()
    self.rate:setVisible(not self.collapsed)
    self.donate:setVisible(not self.collapsed)

    if self.collapseTexture and self.expandTexture then
        self.collapse:setImage(self.collapsed and self.expandTexture or self.collapseTexture)
    end

    self:setX(not self.collapsed and self.originalX or getCore():getScreenWidth()-(self.collapse.width*2))
end


function alertSystem:onClickCollapse()
    self.collapsed = not self.collapsed

    local writer = getFileWriter("chuckleberryfinnalertSystem.txt", true, false)
    writer:write("collapsed="..tostring(self.collapsed))
    writer:close()

    self:collapseApply()
end


function alertSystem:onClickAlert()
    if #self.alertsLoaded <= 1 then return end

    if self.collapsed then
        self.collapsed = false
        self:collapseApply()
    end

    self.alertSelected = self.alertSelected+1
    if self.alertSelected > #self.alertsLoaded then self.alertSelected = 1 end
end


function alertSystem:receiveAlert(alertMessage) table.insert(self.alertsLoaded, alertMessage) end


function alertSystem:initialise()
    ISPanelJoypad.initialise(self)

    local btnHgt = alertSystem.btnHgt
    local btnWid = alertSystem.btnWid

    self.collapse = ISButton:new(5, self:getHeight()-20, 10, 16, "", self, alertSystem.onClickCollapse)
    self.collapse:setImage(alertSystem.collapseTexture)
    self.collapse.borderColor = {r=0, g=0, b=0, a=0}
    self.collapse.backgroundColor = {r=0, g=0, b=0, a=0}
    self.collapse.backgroundColorMouseOver = {r=0, g=0, b=0, a=0}
    self.collapse:initialise()
    self.collapse:instantiate()
    self:addChild(self.collapse)

    self.alertButton = ISButton:new(0, 0, btnHgt, btnHgt, "", self, alertSystem.onClickAlert)
    local alertImage = #alertSystem.alertsLoaded>1 and alertSystem.alertTextureFull or alertSystem.alertTextureEmpty
    self.alertButton:setImage(alertImage)
    self.alertButton.borderColor = {r=0, g=0, b=0, a=0}
    self.alertButton.backgroundColor = {r=0, g=0, b=0, a=0}
    self.alertButton.backgroundColorMouseOver = {r=0, g=0, b=0, a=0}
    self.alertButton:initialise()
    self.alertButton:instantiate()
    self:addChild(self.alertButton)

    self.donate = ISButton:new(((self.width-btnWid)/2), alertSystem.buttonsYOffset-btnHgt, btnWid, btnHgt, "Go to Chuck's Kofi", self, alertSystem.onClickDonate)
    self.donate.borderColor = {r=0.64, g=0.8, b=0.02, a=0.9}
    self.donate.backgroundColor = {r=0, g=0, b=0, a=0.6}
    self.donate.textColor = {r=0.64, g=0.8, b=0.02, a=1}
    self.donate:initialise()
    self.donate:instantiate()
    self:addChild(self.donate)

    self.rate = ISButton:new(self.donate.x-btnHgt-6, alertSystem.buttonsYOffset-btnHgt, btnHgt, btnHgt, "", self, alertSystem.onClickRate)
    self.rate:setImage(alertSystem.rateTexture)
    self.rate.borderColor = {r=0.39, g=0.66, b=0.3, a=0.9}
    self.rate.backgroundColor = {r=0.07, g=0.13, b=0.19, a=1}
    self.rate:initialise()
    self.rate:instantiate()
    self:addChild(self.rate)
end


function alertSystem.display(visible)

    modCountSystem.countInstalled()

    local alert = MainScreen.instance.donateAlert
    if not MainScreen.instance.donateAlert then

        if (not alertSystem.spiffoTexture) and alertSystem.spiffoTextures and #alertSystem.spiffoTextures>0 then
            local rand = ZombRand(#alertSystem.spiffoTextures)+1
            alertSystem.spiffoTexture = getTexture(alertSystem.spiffoTextures[rand])
        end

        local textManager = getTextManager()
        alertSystem.headerFont = UIFont.NewLarge
        alertSystem.bodyFont = UIFont.AutoNormSmall

        alertSystem.bodyFontH = textManager:getFontHeight(alertSystem.bodyFont)

        alertSystem.padding = 24
        alertSystem.btnWid = 100
        alertSystem.btnHgt = 20

        if alertSystem.modName==nil then
            local workshopID = modCountSystem._workshopIDs and modCountSystem._workshopIDs[1]
            ---@type ChooseGameInfo.Mod
            local modInfo = workshopID and modCountSystem.workshopIDs[workshopID]
            alertSystem.modName = modInfo and modInfo:getName() or false
        end
        alertSystem.header = alertSystem.modName and "Thank you for using "..alertSystem.modName.."!" or "Hey there!"

        if modCountSystem.count > 1 then
            alertSystem.header = "Hey there, did you know you're\nusing "..modCountSystem.count.." mods made by Chuck?"
        end

        alertSystem.headerW = textManager:MeasureStringX(alertSystem.headerFont, alertSystem.header)
        alertSystem.headerH = textManager:MeasureStringY(alertSystem.headerFont, alertSystem.header)
        alertSystem.headerYOffset = alertSystem.padding*0.6

        alertSystem.body = "If you enjoy Chuckleberry Finn's work,\nconsider showing your support."
        alertSystem.bodyW = textManager:MeasureStringX(alertSystem.bodyFont, alertSystem.body)
        alertSystem.bodyH = textManager:MeasureStringY(alertSystem.bodyFont, alertSystem.body)*2
        alertSystem.bodyYOffset = alertSystem.headerYOffset+alertSystem.headerH+(alertSystem.padding*0.5)

        alertSystem.buttonsYOffset = alertSystem.bodyYOffset+alertSystem.bodyH+(alertSystem.padding*0.5)

        local textureW = alertSystem.spiffoTexture and alertSystem.spiffoTexture:getWidth() or 0
        local textureH = alertSystem.spiffoTexture and alertSystem.spiffoTexture:getHeight() or 0

        local windowW = (math.max(alertSystem.headerW,alertSystem.bodyW)+(alertSystem.padding*2.5))
        local windowH = alertSystem.buttonsYOffset + alertSystem.btnHgt

        local x = getCore():getScreenWidth() - windowW - (alertSystem.padding*1.5) - (textureW>0 and (textureW-(alertSystem.padding*2)) or 0)
        local y = getCore():getScreenHeight() - math.max(windowH,textureH) - 80 - alertSystem.padding

        alert = alertSystem:new(x, y, windowW, windowH)
        alert:initialise()
        MainScreen.instance.donateAlert = alert
        MainScreen.instance:addChild(alert)
    end

    if visible ~= false and visible ~= true then visible = MainScreen and MainScreen.instance and MainScreen.instance:isVisible() end
    alert:setVisible(visible)

    local reader = getFileReader("chuckleberryfinnalertSystem.txt", false)
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
    end
end


function alertSystem:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor, o.backgroundColor = {r=0, g=0, b=0, a=0}, {r=0, g=0, b=0, a=0}
    o.originalX = x
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