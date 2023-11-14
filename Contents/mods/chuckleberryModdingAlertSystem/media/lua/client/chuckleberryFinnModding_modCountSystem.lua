local modCountSystem = {}

modCountSystem.count = 0
modCountSystem.workshopIDs = {}
modCountSystem._workshopIDs = false
modCountSystem.__workshopIDs = {"2357915214", "3058279917", "3020685151", "3020684845", "3020684713",
                                "3020684587", "3020684454", "3013923320", "3004111200", "3003095456",
                                "2973043640", "2972504692", "2970229240", "2968026253", "2954181035",
                                "2928660831", "2911053472", "2909984178", "2906926438", "2896448697",
                                "2896041179", "2853615523", "2842179206", "2840527826", "2840487215",
                                "2832564154", "2832401837", "2831488837", "2830661685", "2830570280",
                                "2822983942", "2640451854", "2602853395", "2529746725", "2503622437",
                                "2398253681", "2366717227", "2365757229",}


function modCountSystem.assembleModIDs()
    if modCountSystem._workshopIDs then return end
    modCountSystem._workshopIDs = {}
    for _,id in pairs(modCountSystem.__workshopIDs) do
        modCountSystem._workshopIDs[id] = true
    end
end


function modCountSystem.pullCurrentFileModInfo()
    local coroutine = getCurrentCoroutine()
    local count = coroutine and getCallframeTop(coroutine)

    ---@type ChooseGameInfo.Mod
    local modInfo
    for i= count - 1, 0, -1 do
        ---@type LuaCallFrame
        local luaCallFrame = getCoroutineCallframeStack(coroutine,i)
        if luaCallFrame ~= nil and luaCallFrame then
            local fileDir = getFilenameOfCallframe(luaCallFrame)
            if fileDir then
                local modInfoDir = string.match(fileDir,"(.-)media/")
                if modInfoDir then modInfo = getModInfo(modInfoDir) end
            end
        end
    end

    return modInfo
end


function modCountSystem.addModID(modID) modCountSystem.workshopIDs[modID] = true end


function modCountSystem.pullAndAddModID()
    modCountSystem.assembleModIDs()

    ---@type ChooseGameInfo.Mod
    local modInfo = modCountSystem.pullCurrentFileModInfo()
    if not modInfo then return end

    local workshopID = modInfo:getWorkshopID()
    if not workshopID then return end

    if modCountSystem._workshopIDs[workshopID] then return end

    modCountSystem._workshopIDs[workshopID] = true
    modCountSystem.workshopIDs[workshopID] = modInfo

    modCountSystem.count = modCountSystem.count+1
end


function modCountSystem.countInstalled()
    modCountSystem.assembleModIDs()
    modCountSystem.count = 0

    local workshopIDs = getSteamWorkshopItemIDs()
    for i=0, workshopIDs:size()-1 do

        local workshopID = workshopIDs:get(i)
        local modInfos = getSteamWorkshopItemMods(workshopID)

        ---@type ChooseGameInfo.Mod
        local modInfo = modInfos and modInfos:get(0)
        if modInfo and modCountSystem._workshopIDs[workshopID] then
            modCountSystem.workshopIDs[workshopID] = modInfo
            modCountSystem.count = modCountSystem.count+1
        end
    end
end


return modCountSystem