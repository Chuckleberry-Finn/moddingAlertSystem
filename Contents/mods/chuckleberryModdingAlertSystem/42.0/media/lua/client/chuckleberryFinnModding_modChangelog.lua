local changelog_handler = {}

changelog_handler.scannedMods = nil--{}
changelog_handler.freshAlerts = nil--{}

function changelog_handler.scanMods()
    changelog_handler.scannedMods = {}
    local reader = getFileReader("chuckleberryFinn_moddingAlerts.txt", true)
    if reader then
        local lines = {}
        local line = reader:readLine()
        while line do
            table.insert(lines, line)
            line = reader:readLine()
        end
        reader:close()

        for _, line in ipairs(lines) do
            local key, value = string.match(line, "([a-zA-Z0-9_-]+)%s*=%s*(.+)")
            if key and value then
                changelog_handler.scannedMods[key] = value
            end
        end
    end
end


function changelog_handler.fetchAllModsLatest()
    if not changelog_handler.scannedMods then changelog_handler.scanMods() end

    local latest = nil--{}

    local writer = getFileWriter("chuckleberryFinn_moddingAlerts.txt", true, false)

    local activeModIDs = getActivatedMods()
    for i=1,activeModIDs:size() do
        local modID = activeModIDs:get(i-1)
        local modInfo = getModInfoByID(modID)
        local modName = modInfo:getName()
        local latestTitleStored = changelog_handler.scannedMods[modID]
        local alerts = changelog_handler.fetchMod(modID, latestTitleStored)
        if alerts then
            local latestCurrent = alerts[#alerts]
            local lCTitle = latestCurrent and latestCurrent.title

            latest = latest or {}
            latest[modID] = {modName = modName, alerts = alerts}

            print("modID:",modID,"   latestTitleStored:",latestTitleStored,"   lCTitle:",lCTitle)
            if latestTitleStored and latestTitleStored == lCTitle then
                latest[modID].alreadyStored = true
            end

            if lCTitle then writer:write(modID.." = "..lCTitle.."\n") end
        end
    end

    writer:close()

    return latest
end


function changelog_handler.fetchMod(modID, latest)

    local reader = getModFileReader(modID, getFileSeparator().."media"..getFileSeparator().."ChangeLog.txt", false)
    if not reader then return end

    local lines = {}
    local line = reader:readLine()
    while line do
        table.insert(lines, line)
        line = reader:readLine()
    end
    reader:close()

    local completeText = table.concat(lines, "\n")

    local alerts = {}
    local pattern = "%[ ([%d/]+.-)% ](.-)%[ ------ %]"

    for title, contents in string.gmatch(completeText, pattern) do
        table.insert(alerts, {title = title, contents = contents})
    end

    if latest then
        local splitHere
        for i, alert in ipairs(alerts) do
            if alert.title == latest then
                splitHere = i
                break
            end
        end

        if splitHere then
            local newAlerts = {}
            for i = splitHere, #alerts do
                table.insert(newAlerts, alerts[i])
            end
            alerts = newAlerts
        end
    end

    if #alerts == 0 then return end
    return alerts
end


return changelog_handler