require "OptionScreens/WorkshopSubmitScreen"
local changelog_handler = require "chuckleberryFinnModding_modChangelog"

---@param workshopItem SteamWorkshopItem
local function WorkshopSubmitScreen_generateChangelog(workshopItem)
    if not workshopItem or workshopItem:getChangeNote() ~= "" then return end

    local desc = workshopItem:getSubmitDescription()
    local mod_ids = {}

    for line in desc:gmatch("[^\r\n]+") do
        local mod_id = line:match("^Mod ID:%s*(.+)$")
        if mod_id then
            table.insert(mod_ids, mod_id)
        end
    end

    local latest = changelog_handler.fetchAllModsLatest()

    local latestChangeLog = ""

    for _, modID in ipairs(mod_ids) do
        local modChangeLogData = latest[modID]

        local latestAlert = modChangeLogData and modChangeLogData.alerts[#modChangeLogData.alerts]
        if latestAlert then
            latestChangeLog = latestChangeLog..latestAlert.contents.."\n"
        end

        ---latest[modID] = {modName = modName, alerts = alerts}
        ------alerts = {title = title, contents = contents}
    end

    if latestChangeLog:match("^%s*\n") then latestChangeLog = latestChangeLog:gsub("^%s*\n", "", 1) end

    workshopItem:setChangeNote(latestChangeLog)
end


local original_create = WorkshopSubmitScreen.create

function WorkshopSubmitScreen:create()
    original_create(self)

    local pg2 = self.page2
    local original_setWorkshopItem = pg2.setWorkshopItem
    pg2.setWorkshopItem = function(self, item)
        original_setWorkshopItem(self, item)
        WorkshopSubmitScreen_generateChangelog(self.parent.item)
    end
end

