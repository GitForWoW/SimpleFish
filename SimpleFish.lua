-- Tabla de cañas de pescar conocidas por ID
local fishingRods = {
    [6256] = "Fishing Pole",
    [6365] = "Strong Fishing Pole",
    [6366] = "Darkwood Fishing Pole",
    [6367] = "Big Iron Fishing Pole",
    [12225] = "Blump Family Fishing Pole",
    [19022] = "Nat Pagle's Extreme Angler FC-5000",
}

-- Tabla de lures conocidos y sus bonus
local lures = {
    [6533] = 75,  -- Bright Baubles
    [6532] = 50,  -- Aquadynamic Fish Attractor
    [6811] = 25,  -- Aquadynamic Fish Lens
    [6529] = 25,  -- Shiny Bauble
    [6530] = 50,  -- Nightcrawlers
}

-- Extraer el itemID desde un item link usando string.find (más compatible)
local function GetItemIDFromLink(link)
    if not link then return nil end
    local _, _, itemID = string.find(link, "item:(%d+):")
    return tonumber(itemID)
end

-- Verifica si tienes una caña equipada
local function IsFishingRodEquipped()
    local link = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))
    local itemID = GetItemIDFromLink(link)
    return itemID and fishingRods[itemID]
end

-- Intenta equipar una caña de pescar
local function EquipFishingRod()
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            local itemID = GetItemIDFromLink(link)
            if itemID and fishingRods[itemID] then
                UseContainerItem(bag, slot)
                return true
            end
        end
    end
    return false
end

-- Devuelve el mejor lure disponible
local function GetBestLure()
    local bestBonus = 0
    local bestLure = nil

    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            local itemID = GetItemIDFromLink(link)
            if itemID and lures[itemID] and lures[itemID] > bestBonus then
                bestBonus = lures[itemID]
                bestLure = {bag = bag, slot = slot}
            end
        end
    end

    return bestLure
end

-- Aplica el mejor lure a la caña equipada
local function ApplyLure()
    -- Primero verifica si tenemos un lure disponible
    local lure = GetBestLure()
    if not lure then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff5555[SimpleFish]|r No tienes ningun lure disponible.")
        return
    end

    -- Luego verifica la caña
    local hadRodEquipped = IsFishingRodEquipped()
    if not hadRodEquipped then
        if not EquipFishingRod() then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff5555[SimpleFish]|r No tienes una caña de pescar en tus bolsas.")
            return
        end
    end

    -- Solo mostrar el mensaje si teniamos caña equipada desde el principio
    -- o si logramos equipar una y tenemos lure
    local lureLink = GetContainerItemLink(lure.bag, lure.slot)
    local rodLink = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))

    UseContainerItem(lure.bag, lure.slot)
    PickupInventoryItem(GetInventorySlotInfo("MainHandSlot")) -- Aplica el lure

    if hadRodEquipped then
        DEFAULT_CHAT_FRAME:AddMessage(
            string.format("|cff55ff55[SimpleFish]|r Aplicando Lure: %s -> %s", lureLink or "¿?", rodLink or "¿?")
        )
    end
end

-- Slash command
SLASH_SIMPLEFISH1 = "/simplefish"
SLASH_SIMPLEFISH2 = "/sfish"
SlashCmdList["SIMPLEFISH"] = function()
    ApplyLure()
end

-- Mensaje de carga
DEFAULT_CHAT_FRAME:AddMessage("|cff55ff55[SimpleFish]|r Addon cargado. Usa /simplefish o /sfish para aplicar lures.")