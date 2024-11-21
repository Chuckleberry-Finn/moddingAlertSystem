local changelog_handler = {}

changelog_handler.scannedMods = nil--{}

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
            local key, value = string.match(line, "(%w+)%s*=%s*(.+)")
            if key and value then
                changelog_handler.scannedMods[key] = value
            end
        end
    end

    --[[
    local writer = getFileWriter("chuckleberryFinn_moddingAlerts.txt", true, true)
    writer:write("modID = title")
    writer:close()
    --]]
end


function changelog_handler.fetchAllModsLatest()
    if not changelog_handler.scannedMods then changelog_handler.scanMods() end

    local latest = {}

    local activeModIDs = getActivatedMods()
    for i=1,activeModIDs:size() do
        local modID = activeModIDs:get(i-1)
        local modInfo = getModInfoByID(modID)
        local modName = modInfo:getName()
        local latestTitle = changelog_handler.scannedMods[modID]
        local alerts = changelog_handler.fetchMod(modID, latestTitle)
        if alerts then
            latest[modID] = {modName = modName, alerts = alerts}
        end
    end

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
            for i = splitHere + 1, #alerts do
                table.insert(newAlerts, alerts[i])
            end
            alerts = newAlerts
        end
    end

    return alerts
end


return changelog_handler