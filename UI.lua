----------------------------------------------------------------------
-- VoidLayer: the window, the layer under the minimap, slash commands (WoW Forever)
--
-- The network itself is VoidLayerCore.lua (the same file VoidSweep carries; one copy runs).
-- Here: your layer under the minimap (click it for the window), and the window: your layer,
-- the other layers Void players are on in this zone (Hop), rares up here and on which layer
-- (Hop there), Hop to any layer, Refresh, what a hop is doing, and the options.
----------------------------------------------------------------------
local ADDON, ns = ...

-- Borders are one screen pixel (tools/cmd/pixelfix, 2026-11-09). WoW snaps each border
-- piece to the pixel grid, and a thin line on a fractional position can snap to 0 px: a side
-- of a box vanishes. VoidPX() asks for one real pixel, and the hook below (installed once, by
-- the first Void addon loaded) turns snapping off on the edges of flat WHITE8X8 borders, like
-- Blizzard's NineSliceUtil.DisableSharpening, so a 1 px line always covers a pixel. It also
-- moves the border 1/8 px up-left: a side sitting exactly on a pixel's middle (a box centred
-- in an odd-width window) covered no pixel and vanished (2026-11-12).
local function VoidPX()
    local s = UIParent and UIParent:GetEffectiveScale()
    if s and s > 0 and PixelUtil and PixelUtil.GetPixelToUIUnitFactor then return PixelUtil.GetPixelToUIUnitFactor() / s end
    return 1
end
if not _G.__VoidBorderHook2 and hooksecurefunc and NineSliceUtil and NineSliceUtil.ApplyLayout then
    _G.__VoidBorderHook2 = true
    local EDGES = { "TopEdge", "BottomEdge", "LeftEdge", "RightEdge",
                    "TopLeftCorner", "TopRightCorner", "BottomLeftCorner", "BottomRightCorner" }
    hooksecurefunc(NineSliceUtil, "ApplyLayout", function(c)
        local i = type(c) == "table" and c.backdropInfo
        local e = i and i.edgeFile
        if type(e) ~= "string" or not e:lower():find("white8x8", 1, true) or (tonumber(i.edgeSize) or 0) > 3 then return end
        for _, k in ipairs(EDGES) do
            local t = c[k]
            if t and t.SetSnapToPixelGrid then
                t:SetSnapToPixelGrid(false)
                t:SetTexelSnappingBias(0)
            end
        end
        -- the corners hold the box's own points; the edges and the background hang off them
        local sc = c.GetEffectiveScale and c:GetEffectiveScale()
        if not (sc and sc > 0 and PixelUtil and PixelUtil.GetPixelToUIUnitFactor) then return end
        local d = PixelUtil.GetPixelToUIUnitFactor() / sc / 8
        for n = 5, 8 do
            local t = c[EDGES[n]]
            if t and t.GetNumPoints and t:GetNumPoints() == 1 then
                local p, rel, rp, x, y = t:GetPoint(1)
                if rel == c then
                    t:ClearAllPoints()
                    t:SetPoint(p, c, rp, (x or 0) - d, (y or 0) + d)
                end
            end
        end
    end)
end

local A = { 0, 0.78, 1 }   -- Void cyan
-- small on purpose (the user, 2026-11-21: "that box cant grow that way, it will get way to big"): at most 4 layers
-- (only ones someone can bring you to) and 3 rares you can walk to
local W, ROW_H, LAYER_ROWS, RARE_ROWS = 320, 20, 4, 3

local function forever() return RegionalUniqueNamesEnabled ~= nil and RegionalUniqueNamesEnabled() == true end
local function core() return _G.VoidLayerCore end
local function db() VoidLayerDB = VoidLayerDB or {}; return VoidLayerDB end
local function char() VoidLayerCharDB = VoidLayerCharDB or {}; return VoidLayerCharDB end
local function say(msg) print("|cff00c7ffVoidLayer|r: " .. msg) end

-- Settings live per character (VoidLayerCharDB); the core reads them from here.
ns.LayerCoreSettings(2, "VoidLayer", char)

local function ago(s)
    s = math.floor(s)
    if s < 60 then return s .. "s" end
    return math.floor(s / 60) .. "m"
end

local function zoneName(zone)
    local info = zone and C_Map.GetMapInfo(zone)
    return info and info.name or "this zone"
end

----------------------------------------------------------------------
-- Widgets
----------------------------------------------------------------------
local function button(parent, text, w)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(w, 20)
    b:SetText(text)
    return b
end

local function tip(frame, title, body)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(title, 1, 1, 1)
        if body then GameTooltip:AddLine(body, 0.8, 0.8, 0.8, true) end
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function header(parent, text)
    local h = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    h:SetTextColor(A[1], A[2], A[3])
    h:SetText(text)
    return h
end

local function row(parent)
    local r = CreateFrame("Frame", nil, parent)
    r:SetSize(W - 20, ROW_H)
    r.bg = r:CreateTexture(nil, "BACKGROUND")
    r.bg:SetAllPoints()
    r.a = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    r.a:SetPoint("LEFT", 4, 0)
    r.a:SetJustifyH("LEFT")
    r.a:SetWordWrap(false)
    r.b = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    r.b:SetJustifyH("LEFT")
    r.b:SetWordWrap(false)
    r.hop = button(r, "Hop", 50)
    r.hop:SetPoint("RIGHT", 0, 0)
    r:EnableMouse(true)
    r:Hide()
    return r
end

----------------------------------------------------------------------
-- The window
----------------------------------------------------------------------
local win
local UI_Update   -- the window refresh (below)

----------------------------------------------------------------------
-- The game's "world refresh" (2026-11-14): "The world around you will refresh in 9 Minutes ...
-- Refresh Now". It moves you to another layer: measured in Stonetalon, solo, no zone change,
-- 6831-95 -> 7051-96. SHARD_TRANSFER_IMMINENT starts it (GetEvictionTimeRemaining = seconds
-- left), SHARD_TRANSFER_CANCELLED stops it, SHARD_TRANSFER is the move. "New layer now" calls
-- what the game's Refresh Now calls (C_PlayerInteractionManager.ShardTransferConfirm), only
-- from a click, only while one is pending: a solo layer change, no group needed.
----------------------------------------------------------------------
local refreshAt     -- GetTime() when the game moves you; nil = none coming
local cancelledAt   -- GetTime() of the last SHARD_TRANSFER_CANCELLED (Refresh Now sends it before the move)
local function refreshLeft()
    if not refreshAt then return nil end
    -- the move never came (logged out of it, the event lost): stop showing it 15 minutes past due
    if GetTime() - refreshAt > 900 then refreshAt = nil; return nil end
    return math.max(0, refreshAt - GetTime())
end
-- a /reload during the countdown: the warning doesn't fire again, the time left still counts
local function restoreRefresh()
    local left = GetEvictionTimeRemaining and GetEvictionTimeRemaining()
    if type(left) == "number" and left > 0 and left < 3600 then refreshAt = GetTime() + left end
end
function ns.RefreshLeft() return refreshLeft() end
local function mmss(s) return ("%d:%02d"):format(math.floor(s / 60), math.floor(s % 60)) end
local function canRefreshNow()
    return refreshAt ~= nil and C_PlayerInteractionManager and C_PlayerInteractionManager.ShardTransferConfirm ~= nil
        and not UnitAffectingCombat("player")
end
function ns.RefreshNow()
    if not refreshAt then say("no world refresh coming right now; the game offers one now and then.") return end
    if UnitAffectingCombat("player") then say("not in combat: the game only refreshes you out of combat.") return end
    if C_PlayerInteractionManager and C_PlayerInteractionManager.ShardTransferConfirm then
        C_PlayerInteractionManager.ShardTransferConfirm()
    end
end

----------------------------------------------------------------------
-- Players seen on your layer (the user, 2026-11-14: "is there a way for a player to see how many
-- players are on their layer"). The game has no count, and /who has no layer field. But you only
-- see players on your own layer, so every player your nameplates, target or mouseover pick up is
-- on it: a real count, as a minimum. Kept 15 minutes; starts over when your layer or zone changes.
----------------------------------------------------------------------
local SEEN_LIVE = 900
local seenPlayers = {}   -- [guid] = { t, enemy }
local myFaction
local function notePlayer(unit)
    if not (UnitExists(unit) and UnitIsPlayer(unit)) or UnitIsUnit(unit, "player") then return end
    -- seen in the world, not just named: a party member targeted from the party frames can be on
    -- another layer (Sol review); UnitIsVisible is false for them
    local vis = UnitIsVisible and UnitIsVisible(unit)
    if not vis or (issecretvalue and issecretvalue(vis)) then return end
    local g = UnitGUID(unit)
    if type(g) ~= "string" or (issecretvalue and issecretvalue(g)) then return end
    local fac = UnitFactionGroup(unit)
    if issecretvalue and issecretvalue(fac) then fac = nil end
    myFaction = myFaction or UnitFactionGroup("player")
    seenPlayers[g] = { t = GetTime(), enemy = fac ~= nil and myFaction ~= nil and fac ~= myFaction }
end
-- players seen on your layer: total, other faction, the other faction's name
function ns.PlayersSeen()
    local n, e, now = 0, 0, GetTime()
    for g, s in pairs(seenPlayers) do
        if now - s.t > SEEN_LIVE then seenPlayers[g] = nil
        else n = n + 1; if s.enemy then e = e + 1 end end
    end
    myFaction = myFaction or UnitFactionGroup("player")
    return n, e, myFaction == "Horde" and "Alliance" or "Horde"
end
-- the network asks VoidLayer for this count when it answers a layer question (VoidLayerCore "S")
_G.VoidLayerSeenCount = function() return (ns.PlayersSeen()) end

-- The quietest layer of this zone we know of (the user, 2026-11-14: "what if under that we had layer
-- with least amount of seen players"): each Void player on another layer sends its own count with
-- its census answer; the highest count per layer is used (each is a minimum). Yours wins a tie.
-- Layers no Void player counted are unknown, not empty. nil when there's nothing to compare.
function ns.Quietest(c, zone, cur)
    local counts = c and c.SeenCounts and c:SeenCounts(zone) or {}
    local best, bn
    for pair, n in pairs(counts) do
        if pair ~= cur and (not bn or n < bn or (n == bn and pair < best)) then best, bn = pair, n end
    end
    if not best then return nil end
    local mine = ns.PlayersSeen()
    if mine <= bn then return "yours", mine, bn end
    return best, bn, mine
end

local function seenText(long, c, zone, cur)
    local n, e, other = ns.PlayersSeen()
    local q, qn = ns.Quietest(c, zone, cur)
    local quiet = q and (q == "yours" and " · quietest: |cff33ff33yours|r"
        or (" · quietest: |cffffd200%s|r (%d)"):format(c:Label(zone, q), qn)) or ""
    if n == 0 then return long and ("Players seen: none yet" .. quiet) or nil end
    return ("Players seen: |cffffffff%d|r%s%s"):format(n,
        e > 0 and (" (|cffff6060%d %s|r)"):format(e, other) or "", quiet)
end
-- "Same layer as The Barrens 88": your layer's numbers in other zones, from YOUR zone crossings
-- (VoidLayerCore section 4). Other Void players' crossings follow, grey: true for them, and the game
-- keeps each player's number per zone, so yours may differ. nil when none is known.
function ns.SpanText(c, zone, cur)
    local list = c.SameLayer and c:SameLayer(zone, cur) or {}
    if #list == 0 then return nil end
    table.sort(list, function(a, b) return zoneName(a.zone) < zoneName(b.zone) end)
    local mine, theirs = {}, {}
    for _, x in ipairs(list) do
        local t = zoneName(x.zone) .. " " .. c:Label(x.zone, x.pair):gsub("^Layer ", "")
        if x.sure then mine[#mine + 1] = t else theirs[#theirs + 1] = t end
    end
    local function few(t) return table.concat(t, " · ", 1, math.min(3, #t)) .. (#t > 3 and (" +%d"):format(#t - 3) or "") end
    local out = #mine > 0 and ("Same layer as " .. few(mine)) or nil
    if #theirs > 0 then
        local hint = ("|cff777777Other Void players went on to %s (yours may differ)|r"):format(few(theirs))
        out = out and (out .. "\n" .. hint) or hint
    end
    return out
end

local playerEv = CreateFrame("Frame")
for _, e in ipairs({ "NAME_PLATE_UNIT_ADDED", "PLAYER_TARGET_CHANGED", "UPDATE_MOUSEOVER_UNIT" }) do
    pcall(playerEv.RegisterEvent, playerEv, e)
end
playerEv:SetScript("OnEvent", function(_, ev, unit)
    if not forever() then return end
    unit = ev == "PLAYER_TARGET_CHANGED" and "target" or ev == "UPDATE_MOUSEOVER_UNIT" and "mouseover" or unit
    if unit then pcall(notePlayer, unit) end
end)
-- players still on screen stay counted (their nameplate was added long ago)
C_Timer.NewTicker(30, function()
    if not forever() then return end
    ns.PlayersSeen()   -- drops the ones older than 15 minutes, window open or not (Sol review)
    for i = 1, 40 do
        local u = "nameplate" .. i
        if UnitExists(u) then pcall(notePlayer, u) end
    end
end)
-- a new layer (a hop, a world refresh, a group change) or a new zone: start over
if ns.Layer and ns.Layer.OnChange then ns.Layer:OnChange(function() wipe(seenPlayers) end) end

local refreshEv = CreateFrame("Frame")
for _, e in ipairs({ "SHARD_TRANSFER_IMMINENT", "SHARD_TRANSFER_CANCELLED", "SHARD_TRANSFER" }) do
    pcall(refreshEv.RegisterEvent, refreshEv, e)
end
refreshEv:SetScript("OnEvent", function(_, ev)
    if not forever() then return end
    if ev == "SHARD_TRANSFER_IMMINENT" then
        local left = GetEvictionTimeRemaining and GetEvictionTimeRemaining()
        if type(left) ~= "number" or left <= 0 then left = 0 end
        refreshAt = GetTime() + left
        local c = core()
        -- a hop in the last 5 minutes (its cooldown is running) or under way: that's what gets lost
        local hopped = c and ((c.CooldownLeft and (c:CooldownLeft() or 0) > 0) or (c.Busy and c:Busy()))
        say(("the game will move you to another layer in %s (world refresh)%s. |cffffd200New layer now|r in the VoidLayer window does it right away, solo, no group needed.")
            :format(left > 0 and mmss(left) or "a moment", hopped and ": |cffff8040your hop won't hold after that|r" or ""))
    elseif ev == "SHARD_TRANSFER_CANCELLED" then
        refreshAt, cancelledAt = nil, GetTime()
    else   -- SHARD_TRANSFER: moved. Layer.lua starts reading again; the label updates when it knows.
        -- It also fires on every zone change, no warning first (live 11-14, Barrens -> Ashenvale):
        -- only a refresh that was announced gets the chat line. Refresh Now / New layer now sends
        -- CANCELLED first, then the move (live 11-14), so a move right after a cancel counts too.
        local was = refreshAt or (cancelledAt and GetTime() - cancelledAt < 5)
        refreshAt, cancelledAt = nil, nil
        if was then say("world refresh done: reading your new layer from the NPCs around you.") end
    end
    ns.UpdateLabel()
    if UI_Update then UI_Update() end
end)

local function build()
    local f = CreateFrame("Frame", "VoidLayerFrame", UIParent, "BackdropTemplate")
    f:SetSize(W, 200)
    f:SetFrameStrata("MEDIUM")
    f:SetClampedToScreen(true)
    f:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = VoidPX() })
    f:SetBackdropColor(0.04, 0.04, 0.07, 0.92)
    f:SetBackdropBorderColor(A[1], A[2], A[3], 0.6)
    local p = db().pos
    if p then f:SetPoint(p[1], UIParent, p[2], p[3], p[4]) else f:SetPoint("CENTER", UIParent, "CENTER", 300, 80) end
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local pt, _, rel, x, y = self:GetPoint()
        db().pos = { pt, rel, x, y }
    end)

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("TOPLEFT", 10, -8)
    f.title:SetTextColor(A[1], A[2], A[3])
    f.title:SetJustifyH("LEFT")
    f.title:SetWidth(W - 60)   -- room for the gear and the close button
    f.title:SetWordWrap(false)
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetSize(22, 22)
    close:SetPoint("TOPRIGHT", 1, 1)
    close:SetScript("OnClick", function() f:Hide() end)

    f.mine = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.mine:SetPoint("TOPLEFT", 10, -28)
    f.mine:SetJustifyH("LEFT")
    f.mine:SetWidth(W - 20)
    -- players seen on your layer (a hover explains it's a minimum)
    f.seenBox = CreateFrame("Frame", nil, f)
    f.seenBox:SetSize(W - 20, 14)
    -- hover only: motion events, so a drag on this line still moves the window
    if f.seenBox.EnableMouseMotion then f.seenBox:EnableMouseMotion(true) else f.seenBox:EnableMouse(true) end
    f.seen = f.seenBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.seen:SetPoint("TOPLEFT")
    f.seen:SetJustifyH("LEFT")
    f.seen:SetWidth(W - 20)
    f.seen:SetTextColor(0.8, 0.8, 0.8)
    -- the same layer in other zones (it has a different number in each)
    f.span = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    f.span:SetJustifyH("LEFT")
    f.span:SetWidth(W - 20)
    tip(f.seenBox, "Players seen on this layer",
        "Every player your nameplates, target or mouseover picked up in the last 15 minutes: you only ever see players on your own layer, so they're all on it. A minimum, not everyone: the game gives addons no full count. Turn on friendly player nameplates to count more. Starts over when your layer or zone changes.\n\nQuietest: the Void players on other layers of this zone send their own count when you Refresh; the layer with the fewest players seen. Only layers with a Void player on them can be compared.")

    -- world refresh coming: the countdown and "New layer now" (only shown while one is pending)
    f.wr = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.wr:SetJustifyH("LEFT")
    f.wr:SetWidth(W - 130)
    f.wr:SetTextColor(1, 0.55, 0.25)
    f.wrBtn = button(f, "New layer now", 110)
    f.wrBtn:SetScript("OnClick", function() ns.RefreshNow() end)

    -- in a group, not on the leader's layer: Rejoin (leave + the leader re-invites you onto theirs)
    f.grp = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.grp:SetJustifyH("LEFT")
    f.grp:SetWidth(W - 100)
    f.grp:SetTextColor(1, 0.55, 0.25)
    f.grpBtn = button(f, "Rejoin", 80)
    f.grpBtn:SetScript("OnClick", function() local c = core(); if c and c.Rejoin then c:Rejoin() end end)
    tip(f.grpBtn, "Rejoin the group",
        "Joining a group puts you on its leader's layer. This leaves the group and gets you re-invited: with VoidLayer on the leader it happens by itself in a second or two; without it, the leader gets a whisper asking for the invite. Only you leave, the group stays. Not in combat or inside dungeons.")
    tip(f.wrBtn, "New layer now",
        "The game has a world refresh coming for you, which moves you to another layer. This does it right away: solo, no group or host needed. The game picks the layer. Out of combat only.")

    f.layersH = header(f, "Other layers here")
    f.layerRows = {}
    for i = 1, LAYER_ROWS do
        local r = row(f)
        r.a:SetWidth(80)
        r.b:SetPoint("LEFT", r.a, "RIGHT", 4, 0)
        r.b:SetWidth(150)
        r.bg:SetColorTexture(1, 1, 1, i % 2 == 0 and 0.04 or 0)
        r.hop:SetScript("OnClick", function(self) local c = core(); if c and self.pair then c:Start(self.pair) end end)
        tip(r.hop, "Hop to this layer", "A Void player there sends you a quick group invite; you're moved to their layer and leave the group again.")
        f.layerRows[i] = r
    end
    f.layersEmpty = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    f.layersEmpty:SetJustifyH("LEFT")
    f.layersEmpty:SetWidth(W - 28)

    f.raresH = header(f, "Rares on your layer")
    f.rareRows = {}
    for i = 1, RARE_ROWS do
        local r = row(f)
        r.a:SetWidth(130)
        r.b:SetPoint("LEFT", r.a, "RIGHT", 4, 0)
        r.b:SetWidth(110)
        r.bg:SetColorTexture(1, 1, 1, i % 2 == 0 and 0.04 or 0)
        r.hop:SetText("Hop")
        r.hop:SetScript("OnClick", function(self)
            local c = core()
            if c and self.pair then c:Start(self.pair, self.zone, self.prefer) end
        end)
        tip(r.hop, "Hop to this rare's layer", "The player who saw it (or another Void player on that layer) sends you a quick group invite.")
        f.rareRows[i] = r
    end
    f.raresEmpty = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    f.raresEmpty:SetJustifyH("LEFT")
    f.raresEmpty:SetWidth(W - 28)

    -- one row of three (the user, 2026-11-14: "the box is growing, we need to clean it up")
    local BW = math.floor((W - 26) / 3)
    -- Group hop (the user, 2026-11-15: "a group hop which is tied only to the group your in, or a
    -- raid", replacing "Hop to any", which "Fresh layer" now covers): onto your group leader's layer
    f.any = button(f, "Group hop", BW)
    f.any:SetScript("OnClick", function() local c = core(); if c and c.Rejoin then c:Rejoin() end end)
    f.any:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Group hop", 1, 1, 1)
        GameTooltip:AddLine("Onto your group's layer, in a party or a raid: joining a group puts you on its leader's layer, so this leaves the group and gets you re-invited. With VoidLayer on the leader it happens by itself in a second or two; without it, the leader gets a whisper asking for the invite. Only you leave, the group stays. Not in combat or inside dungeons.", 0.8, 0.8, 0.8, true)
        local why = self.why
        if why then GameTooltip:AddLine(why, 1, 0.82, 0, true) end
        GameTooltip:Show()
    end)
    f.any:SetScript("OnLeave", function() GameTooltip:Hide() end)
    -- fresh camp (VoidLayerCore section 5): a layer where the spot you're standing on wasn't cleared lately
    f.fresh = button(f, "Fresh layer", BW)
    -- in a party it's Move group (core 10, 2026-11-24): the whole party to a fresh layer; while one is
    -- under way (moving it, or following someone who is), Cancel
    f.fresh:SetScript("OnClick", function(self)
        local c = core()
        if not c then return end
        if self.mode == "cancel" then c:MoveGroupCancel()
        elseif self.mode == "group" then c:MoveGroup()
        elseif c.StartFresh then c:StartFresh() end
    end)
    f.fresh:SetScript("OnEnter", function(self)
        local c = core()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if self.mode == "cancel" then
            GameTooltip:AddLine("Cancel the group move", 1, 1, 1)
            GameTooltip:AddLine("Moving it: stops the hop and invites everyone back to where you are. Following: you stop waiting for the invite (it still shows up as usual).", 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
            return
        elseif self.mode == "group" then
            GameTooltip:AddLine("Move group", 1, 1, 1)
            GameTooltip:AddLine("Takes your whole party to a fresh layer: the others leave the group, you hop (like Fresh layer) and invite them back. Joining puts them on your layer, so everyone lands there. With VoidLayer they leave and accept by themselves; without it they get a whisper. Anyone in the party can start it.", 0.8, 0.8, 0.8, true)
            GameTooltip:AddLine("Nobody leaves until a Void player on another layer is found. If the hop fails, you invite them back anyway.", 0.8, 0.8, 0.8, true)
            if self.why then GameTooltip:AddLine(self.why, 1, 0.82, 0, true) end
            GameTooltip:Show()
            return
        end
        GameTooltip:AddLine("Fresh layer here", 1, 1, 1)
        GameTooltip:AddLine("Hops you to another layer: the one where the mobs around you are most likely up. With no reports, any layer a Void player can bring you to (it was Hop to any).", 0.9, 0.9, 0.9, true)
        GameTooltip:AddLine("Cleared this spot? A hop doesn't move you: the world around you becomes the other layer's copy, where these mobs may still be up. This picks the layer where nobody reported clearing this spot, or reported it longest ago, and skips one you cleared it on yourself in the last 10 minutes. Not a promise: only Void players report clears.", 0.8, 0.8, 0.8, true)
        local cur, zone
        if c then cur, zone = c:Here() end
        if c and cur and c.SpotCleared then
            local age = c:SpotCleared(zone, cur)
            GameTooltip:AddLine(age and ("This spot on your layer: cleared %s ago."):format(ago(age)) or "This spot on your layer: no clear seen yet.", 1, 0.82, 0, true)
        end
        GameTooltip:Show()
    end)
    f.fresh:SetScript("OnLeave", function() GameTooltip:Hide() end)
    f.refresh = button(f, "Refresh", BW)
    f.refresh:SetScript("OnClick", function()
        local c = core()
        local zone; if c then zone = select(2, c:Here()) end
        if zone and c:Ask(zone) then f.asking = GetTime() end
        UI_Update()
    end)
    tip(f.refresh, "Ask the Void players in this zone which layer they're on", "Once every 2 minutes per zone, to keep the chatter down.")

    f.status = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.status:SetJustifyH("LEFT")
    f.status:SetWidth(W - 20)

    -- the four settings live behind the gear in the title bar now (they took four rows every time
    -- the window opened; the user, 2026-11-14: "clean it up and tighten it")
    f.opts = {
        { label = "Help others change layer",
          body = "When a Void player on your layer asks, you send them a quick group invite; the group ends on its own after 3 minutes. Only while you're solo, out of combat and outside dungeons, at most once every 2 minutes. Every hop works because someone helps.",
          get = function() local c = core(); return c and c:HostingOn() end, set = function(on) local c = core(); if c then c:SetHosting(on) end end },
        { label = "Host from my Group Finder listing",
          body = "Post a Group Finder listing (Custom, a note with the word \"layer\", e.g. Layer swap - whisper inv). While it's up, anyone who whispers you inv, layer or swap, or clicks Group Invite on it, gets an invite onto your layer: no addon needed on their side. Same limits as helping. Friends' and guildmates' invites are never touched.",
          get = function() local c = core(); return c and c.FinderOn and c:FinderOn() end, set = function(on) local c = core(); if c and c.SetFinder then c:SetFinder(on) end end },
        { label = "Rare alerts",
          body = "A rare up on another layer of your zone asks \"Hop there?\"; one on your layer gets a line in chat.",
          get = function() local c = core(); return c and c:PopupsOn() end, set = function(on) local c = core(); if c then c:SetPopups(on) end end },
        { label = "Stay grouped after a hop",
          body = "Only needed if leaving the group sends you back to your old layer; VoidLayer turns this on by itself when it sees that happen.",
          get = function() local c = core(); return c and c:StayOn() end, set = function(on) local c = core(); if c then c:SetStay(on) end end },
        { label = "Show my layer under the minimap",
          body = "Click it to open this window. Drag to move it.",
          get = function() return char().label ~= false end, set = function(on) char().label = on; ns.UpdateLabel() end },
    }
    f.gear = CreateFrame("Button", nil, f)
    f.gear:SetSize(16, 16)
    f.gear:SetPoint("TOPRIGHT", -24, -5)
    f.gear:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
    f.gear:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    f.gear:SetScript("OnClick", function(self)
        if not (MenuUtil and MenuUtil.CreateContextMenu) then return end
        MenuUtil.CreateContextMenu(self, function(_, root)
            root:CreateTitle("VoidLayer")
            for _, o in ipairs(f.opts) do
                local cb = root:CreateCheckbox(o.label, function() return o.get() and true or false end,
                    function() o.set(not o.get()) end)
                if cb and cb.SetTooltip then
                    cb:SetTooltip(function(tt) GameTooltip_SetTitle(tt, o.label); GameTooltip_AddNormalLine(tt, o.body) end)
                end
            end
        end)
    end)
    tip(f.gear, "Options", "Help others change layer, rare alerts, stay grouped after a hop, the label under the minimap.")

    f:SetScript("OnShow", function()
        local c = core()
        local zone; if c then zone = select(2, c:Here()) end
        if zone and c:Ask(zone) then f.asking = GetTime() end
        db().open = true
        UI_Update()
    end)
    f:SetScript("OnHide", function() db().open = false end)
    f.elapsed = 0
    f:SetScript("OnUpdate", function(self, dt)
        self.elapsed = self.elapsed + dt
        if self.elapsed >= 1 then self.elapsed = 0; UI_Update() end
    end)
    f:Hide()
    return f
end

-- Only layers you can actually get to: a Void player there said they can bring you over (and hasn't since answered
-- busy or gone quiet: VoidLayerCore drops those). The user, 2026-11-21, after four Hops to rare layers all failed
-- ("Asked 1: 1 in a group, in combat or just helped someone"): "if that player is no longer reachable, it should go
-- away". A rare up on such a layer rides in its row; rares on layers nobody can bring you to aren't shown.
local function otherLayers(c, zone, cur)
    local out = {}
    for pair, n in pairs(c:Counts(zone)) do
        local hosts = #c:Hosts(zone, pair)
        if pair ~= cur and hosts > 0 then out[#out + 1] = { pair = pair, n = n, hosts = hosts } end
    end
    for _, r in ipairs(c:Rares(zone)) do
        if r.pair ~= cur and r.hp > 0 then
            for _, l in ipairs(out) do
                if l.pair == r.pair then l.rares = l.rares or {}; l.rares[#l.rares + 1] = r end
            end
        end
    end
    table.sort(out, function(a, b)
        if (a.rares ~= nil) ~= (b.rares ~= nil) then return a.rares ~= nil end   -- a rare up first
        if a.n ~= b.n then return a.n > b.n end
        return a.pair < b.pair
    end)
    return out
end

UI_Update = function()
    local f = win
    if not (f and f:IsShown()) then return end
    local c = core()
    local cur, zone
    if c then cur, zone = c:Here() end
    f.title:SetText("VoidLayer  ·  " .. zoneName(zone))
    -- the online count rides in the "Other layers" header (in the title it got cut off, live 11-14)
    local online = c and c:Online()

    if not forever() then
        f.mine:SetText("Layers are a WoW Forever thing.")
    elseif not c then
        f.mine:SetText("Starting up...")
    elseif cur then
        local here = c:Counts(zone)[cur] or 0
        -- the name only: since 2026-11-24 it's a name VoidLayer gives the layer (Layer.lua v2), not a number to read
        f.mine:SetText(("You're on |cffffd200%s|r%s"):format(c:Label(zone, cur),
            here > 0 and ("  ·  %d Void player%s here too"):format(here, here == 1 and "" or "s") or ""))
    else
        f.mine:SetText("Your layer: |cff999999none here|r (no zone, or inside a dungeon)")
    end

    -- every line goes below the real height of the one above (live 11-14: "not known yet ... any NPC"
    -- wrapped and ran into the "Other layers" header, which sat at a fixed spot)
    local y = -28 - math.max(14, f.mine:GetStringHeight()) - 3
    if forever() and c and cur then
        f.seenBox:ClearAllPoints(); f.seenBox:SetPoint("TOPLEFT", 10, y)
        f.seen:SetText(seenText(true, c, zone, cur))
        local sh = math.max(12, f.seen:GetStringHeight())
        f.seenBox:SetHeight(sh)
        f.seenBox:Show()
        y = y - sh - 2
    else
        f.seenBox:Hide()
    end
    local span = (forever() and c and cur and c.SameLayer) and ns.SpanText(c, zone, cur)
    if span then
        f.span:ClearAllPoints(); f.span:SetPoint("TOPLEFT", 10, y + 2)
        f.span:SetText(span)
        f.span:Show()
        y = y - (f.span:GetStringHeight() + 4)
    else
        f.span:Hide()
    end
    -- in a group on another layer than the leader (or waiting for the re-invite)
    local g = (forever() and c and c.GroupLayer) and c:GroupLayer() or nil
    local rj = c and c.Rejoining and c:Rejoining()
    if rj or (g and g.differs) then
        local text
        if rj then
            text = rj.phase == "asking" and ("Asking %s for a re-invite..."):format(rj.leader)
                or ("Waiting for %s's invite..."):format(rj.leader)
        else
            text = ("Not on %s's layer%s"):format(g.leader or "the leader",
                g.how == "exact" and g.pair and (" (%s)"):format(c:Label(zone, g.pair)) or "")
            -- one chat line per leader and layer, so you know without the window open
            local key = tostring(g.leader) .. tostring(g.pair)
            if ns.groupWarned ~= key then
                ns.groupWarned = key
                say(("you're not on %s's layer: |cffffd200Group hop|r in the VoidLayer window fixes it."):format(g.leader or "the leader"))
            end
        end
        f.grp:ClearAllPoints(); f.grp:SetPoint("TOPLEFT", 10, y - 4)
        f.grp:SetText(text)
        f.grpBtn:ClearAllPoints(); f.grpBtn:SetPoint("TOPRIGHT", -10, y)
        f.grpBtn:SetShown(false)   -- the row's Group hop does it now
        f.grpBtn:SetEnabled(not InCombatLockdown())
        f.grp:Show()
        y = y - math.max(24, f.grp:GetStringHeight() + 8)
    else
        f.grp:Hide(); f.grpBtn:Hide()
    end

    local wrLeft = forever() and refreshLeft()
    if wrLeft then
        f.wr:ClearAllPoints(); f.wr:SetPoint("TOPLEFT", 10, y - 4)
        f.wr:SetText(wrLeft > 0 and ("World refresh in %s: the game moves you to another layer."):format(mmss(wrLeft))
            or "World refresh any moment: the game moves you to another layer.")
        f.wrBtn:ClearAllPoints(); f.wrBtn:SetPoint("TOPRIGHT", -10, y)
        f.wrBtn:SetEnabled(canRefreshNow())
        f.wr:Show(); f.wrBtn:Show()
        y = y - math.max(24, f.wr:GetStringHeight() + 8)
    else
        f.wr:Hide(); f.wrBtn:Hide()
    end
    local blocked = "..."; if c then blocked = c:Blocked() end
    -- other layers
    f.layersH:ClearAllPoints(); f.layersH:SetPoint("TOPLEFT", 10, y); y = y - 16
    -- how many layers this zone has, as far as Void players saw in the last 30 minutes
    local nSeen = (c and zone and c.LayersSeen) and c:LayersSeen(zone) or 0
    local extra = {}
    -- (no "N layers here" since 2026-11-24: two names can be one layer until Void players meet; nSeen unused)
    local _ = nSeen
    if online then extra[#extra + 1] = ("%d Void online"):format(online) end
    f.layersH:SetText("Other layers" .. (#extra > 0 and ("  |cff888888· " .. table.concat(extra, " · ") .. "|r") or ""))
    local list = (c and zone) and otherLayers(c, zone, cur) or {}
    local seenCounts = (c and zone and c.SeenCounts) and c:SeenCounts(zone) or {}
    for i, r in ipairs(f.layerRows) do
        local l = list[i]
        if l then
            r:ClearAllPoints(); r:SetPoint("TOPLEFT", 10, y - (i - 1) * ROW_H)
            r.a:SetText(c:Label(zone, l.pair))
            local what = l.n > 0 and ("%d Void player%s"):format(l.n, l.n == 1 and "" or "s") or ""
            local sc = seenCounts[l.pair]   -- players a Void player there has seen on it
            if sc then what = (what ~= "" and what .. " · " or "") .. ("%d seen"):format(sc) end
            if l.rares then   -- the rare(s) up there, by name
                local x = l.rares[1]
                what = ("|cffff8040%s|r%s · %s"):format(x.name, #l.rares > 1 and (" +" .. (#l.rares - 1)) or "", what)
            end
            -- your spot on that layer (fresh camp): cleared lately = no point hopping there to farm it
            local spot = c.SpotCleared and c:SpotCleared(zone, l.pair)
            if spot then what = (what ~= "" and what .. " · " or "") .. ("|cffcc6666spot cleared %s ago|r"):format(ago(spot)) end
            r.b:SetText(what)
            r.hop.pair = l.pair
            r.hop:SetShown(true)   -- every row listed has someone who can bring you over
            r.hop:SetEnabled(not blocked)
            r:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(c:Label(zone, l.pair) .. "  |cff777777" .. l.pair .. "|r", 1, 1, 1)
                GameTooltip:AddLine("A Void player there can bring you over.", 0.8, 0.8, 0.8, true)
                for _, x in ipairs(l.rares or {}) do
                    GameTooltip:AddLine(("Rare up: %s, %s ago"):format(x.name, ago(x.age)), 1, 0.5, 0.25)
                end
                GameTooltip:Show()
            end)
            r:SetScript("OnLeave", function() GameTooltip:Hide() end)
            r:Show()
        else
            r:Hide()
        end
    end
    local shown = math.min(#list, LAYER_ROWS)
    if shown == 0 then
        f.layersEmpty:ClearAllPoints(); f.layersEmpty:SetPoint("TOPLEFT", 14, y - 2)
        f.layersEmpty:SetText(f.asking and GetTime() - f.asking < 7 and "Asking the Void players here..."
            or "Nobody known who can bring you to another layer right now: Refresh asks the Void players here.")
        f.layersEmpty:Show()
        y = y - ROW_H - 4
    else
        f.layersEmpty:Hide()
        y = y - shown * ROW_H - 6
    end

    -- rares: the section only shows when there are some (it took two lines to say "none")
    -- only rares you can walk to: on your layer, or next door on it. A rare on another layer shows in that layer's row
    -- above, when someone there can bring you over (2026-11-21).
    local rares = {}
    for _, x in ipairs((c and zone) and c:Rares(zone) or {}) do
        if x.same then rares[#rares + 1] = x end
    end
    -- and rares up next door on YOUR layer (linked across zones): walk over, no hop
    if c and zone and c.RaresNextDoor then
        for _, x in ipairs(c:RaresNextDoor()) do rares[#rares + 1] = x end
    end
    f.raresH:ClearAllPoints(); f.raresH:SetPoint("TOPLEFT", 10, y)
    f.raresH:SetShown(#rares > 0)
    if #rares > 0 then y = y - 16 end
    for i, r in ipairs(f.rareRows) do
        local x = rares[i]
        if x then
            r:ClearAllPoints(); r:SetPoint("TOPLEFT", 10, y - (i - 1) * ROW_H)
            r.a:SetText((x.hp == 0 and "|cff888888" or "|cffffd200") .. x.name .. "|r")
            local where = x.nextDoor and ("|cff33ff33your layer|r, " .. zoneName(x.zone))
                or x.same and "|cff33ff33your layer|r" or c:Label(zone, x.pair)
            r.b:SetText(("%s · %s%s"):format(where, x.hp == 0 and "dead " or (x.hp < 100 and (x.hp .. "% ") or ""), ago(x.age)))
            r.hop.pair, r.hop.zone, r.hop.prefer = x.pair, x.zone, x.origin
            r.hop:SetShown(not x.same and not x.nextDoor and x.hp > 0 and cur ~= nil)
            r.hop:SetEnabled(not blocked)
            r:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(x.name, 1, 0.82, 0)
                if x.nextDoor then
                    GameTooltip:AddLine(("In %s, on your layer (%s there)  |cff777777%s|r"):format(zoneName(x.zone), c:Label(x.zone, x.pair), x.pair), 1, 1, 1, true)
                    GameTooltip:AddLine("Walk over: no hop needed. Your own zone crossing showed this is your layer there.", 0.8, 0.8, 0.8, true)
                else
                    GameTooltip:AddLine(("%s  |cff777777%s|r"):format(x.same and "On your layer" or c:Label(zone, x.pair), x.pair), 1, 1, 1)
                end
                if x.x > 0 or x.y > 0 then GameTooltip:AddLine(("Seen near %.0f, %.0f, %s ago"):format(x.x / 10, x.y / 10, ago(x.age)), 0.8, 0.8, 0.8) end
                GameTooltip:Show()
            end)
            r:SetScript("OnLeave", function() GameTooltip:Hide() end)
            r:Show()
        else
            r:Hide()
        end
    end
    local rs = math.min(#rares, RARE_ROWS)
    f.raresEmpty:Hide()
    if rs > 0 then y = y - rs * ROW_H - 6 end

    -- buttons: one row
    y = y - 4
    f.any:ClearAllPoints(); f.any:SetPoint("TOPLEFT", 10, y)
    f.fresh:ClearAllPoints(); f.fresh:SetPoint("LEFT", f.any, "RIGHT", 3, 0)
    f.refresh:ClearAllPoints(); f.refresh:SetPoint("LEFT", f.fresh, "RIGHT", 3, 0)
    -- Group hop: in a group led by someone else, out of combat, not inside, not already rejoining
    local lead = UnitIsGroupLeader("player")
    if issecretvalue and issecretvalue(lead) then lead = false end
    local rejoining = c and c.Rejoining and c:Rejoining()
    local why = (not IsInGroup()) and "Only in a party or a raid."
        or lead and "You lead this group: the others use Group hop to come to your layer."
        or IsInInstance() and "Not inside a dungeon or raid."
        or InCombatLockdown() and "Not in combat."
        or rejoining and "Already on its way." or nil
    f.any.why = why
    f.any:SetEnabled(c ~= nil and c.Rejoin ~= nil and why == nil)
    local left = (c and zone) and c:AskLeft(zone) or 0
    f.refresh:SetEnabled(c ~= nil and zone ~= nil and left == 0)
    f.refresh:SetText(left > 0 and ("Refresh %d:%02d"):format(math.floor(left / 60), math.floor(left % 60)) or "Refresh")
    -- Fresh layer solo; Move group in a party; Cancel while a group move is under way (core 10)
    local moving = c and c.MovingGroup and (c:MovingGroup() or c:Following())
    if moving then
        f.fresh.mode, f.fresh.why = "cancel", nil
        f.fresh:SetText("Cancel move")
        f.fresh:SetEnabled(true)
    elseif c and c.MoveGroup and IsInGroup() and not IsInRaid() then
        f.fresh.mode, f.fresh.why = "group", c:MoveGroupBlocked()
        f.fresh:SetText("Move group")
        f.fresh:SetEnabled(f.fresh.why == nil)
    else
        f.fresh.mode, f.fresh.why = nil, nil
        f.fresh:SetText("Fresh layer")
        f.fresh:SetEnabled(c ~= nil and c.StartFresh ~= nil and not blocked and cur ~= nil)
    end
    y = y - 24

    -- a status line only when there's something to say (blocked, a hop under way, why not here);
    -- the online count is in the title
    local status = c and ((c.GroupMoveStatus and c:GroupMoveStatus()) or c:Status())
    if not status and c then
        status = c:Blocked()
        if status == "A hop is under way." then status = nil end
        if not status then status = c:BlockReason() end
        if not status and c.FinderListed and c:FinderListed() then
            status = "|cff33ff33Hosting from your Group Finder listing:|r whisper inv, layer or swap and you're brought here."
        end
    end
    f.status:ClearAllPoints(); f.status:SetPoint("TOPLEFT", 10, y - 2)
    f.status:SetText(status or "")
    f.status:SetShown(status ~= nil)
    if status then y = y - (f.status:GetStringHeight() + 6) end
    f:SetHeight(-y + 6)
end

local function toggle()
    win = win or build()
    win:SetShown(not win:IsShown())
end
ns.Toggle = toggle

----------------------------------------------------------------------
-- Your layer under the minimap
----------------------------------------------------------------------
local label
local function buildLabel()
    local b = CreateFrame("Button", "VoidLayerMinimapLabel", UIParent, "BackdropTemplate")
    b:SetSize(90, 16)
    b:SetFrameStrata("MEDIUM")
    b:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = VoidPX() })
    b:SetBackdropColor(0.04, 0.04, 0.07, 0.8)
    b:SetBackdropBorderColor(A[1], A[2], A[3], 0.5)
    b:SetPoint("TOP", MinimapCluster or Minimap, "BOTTOM", 0, MinimapCluster and 6 or -18)   -- the cluster: a gathering HUD can carry Minimap off (live 11-09)
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    b.text:SetPoint("CENTER")
    -- plain drag, kept after a restart (VoidMove.lua; the user, 11-12: no hidden Shift). The old
    -- labelPos is dropped: a plain drag used to save it against the minimap cluster, so after a
    -- /reload the label could land at the bottom of the screen.
    db().labelPos = nil
    ns.Move(b, { db = db, key = "label" })
    b:SetScript("OnClick", toggle)
    b:SetScript("OnEnter", function(self)
        local c = core()
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:AddLine("VoidLayer", A[1], A[2], A[3])
        local cur, zone
        if c then cur, zone = c:Here() end
        if cur then
            GameTooltip:AddLine(("%s  |cff777777%s|r"):format(c:Label(zone, cur), cur), 1, 1, 1)
            local s = c:Summary(zone)
            if s then GameTooltip:AddLine(s, 0.8, 0.8, 0.8, true) end
            local seen = seenText(false, c, zone, cur)
            if seen then GameTooltip:AddLine(seen, 0.8, 0.8, 0.8) end
            local span = ns.SpanText(c, zone, cur)
            if span then GameTooltip:AddLine(span, 0.8, 0.8, 0.8, true) end
        else
            GameTooltip:AddLine("No layer here (no zone, or inside a dungeon).", 0.8, 0.8, 0.8, true)
        end
        local wr = refreshLeft()
        if wr then
            GameTooltip:AddLine(("World refresh in %s: the game moves you to another layer. New layer now (in the window) does it right away, solo."):format(mmss(wr)), 1, 0.55, 0.25, true)
        end
        GameTooltip:AddLine("Click: the layer window · Drag: move", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return b
end

function ns.UpdateLabel()
    if not forever() or char().label == false then
        if label then label:Hide() end
        return
    end
    label = label or buildLabel()
    local c = core()
    local cur, zone
    if c then cur, zone = c:Here() end
    local rareElsewhere = false
    if c and zone then
        for _, r in ipairs(c:Rares(zone)) do if not r.same and r.hp > 0 then rareElsewhere = true break end end
    end
    local wr = refreshLeft()
    local wrText = wr and (" |cffff8c40· refresh %s|r"):format(wr >= 60 and (math.ceil(wr / 60) .. "m") or (math.ceil(wr) .. "s")) or ""
    label.text:SetText((cur and (c:Label(zone, cur) .. (rareElsewhere and " |cffff8040•|r" or "")) or "|cff999999Layer ?|r") .. wrText)
    label:SetWidth(math.max(70, label.text:GetStringWidth() + 16))
    label:Show()
end

----------------------------------------------------------------------
-- Start-up, slash commands, the Void hub
----------------------------------------------------------------------
-- "/vl hop 6832" or "/vl hop 6832-17" (a layer's name is its server number, 2026-11-14)
local function pairFor(c, zone, want)
    if not want or want == "" then return nil end
    if want:match("^%d+%-%d+$") then return want:match("^(%d+)") .. "-0" end
    local letter = want:upper():gsub("^LAYER%s*", "")
    local pairs_ = {}
    for p in pairs(c:Counts(zone)) do pairs_[#pairs_ + 1] = p end
    for _, r in ipairs(c:Rares(zone)) do pairs_[#pairs_ + 1] = r.pair end
    for _, p in ipairs(pairs_) do
        if c:Label(zone, p) == "Layer " .. letter then return p end
    end
    return false
end

SLASH_VOIDLAYER1, SLASH_VOIDLAYER2 = "/vl", "/voidlayer"
SlashCmdList.VOIDLAYER = function(msg)
    local raw = strtrim(msg or "")
    msg = raw:lower()
    local c = core()
    if not forever() then say("layers are a WoW Forever thing.") return end
    if not c then say("still starting up; try again in a moment.") return end
    local cmd, rest = msg:match("^(%S*)%s*(.-)$")
    if cmd == "" then toggle()
    elseif cmd == "test" then
        -- /vl test join|host <First Surname> (or your target) · /vl test rare
        local what, who = raw:match("^%S+%s+(%S+)%s*(.-)$")
        what = what and what:lower()
        if who == "" then
            local t = UnitIsPlayer("target") and UnitName("target")
            who = (type(t) == "string" and not (issecretvalue and issecretvalue(t))) and t or nil
        end
        if what == "join" then c:TestJoin(who)
        elseif what == "host" then c:TestHost(who)
        elseif what == "rare" then c:TestRare()
        else say("|cffffd200/vl test join|r Name: accept their invite like a hop · |cffffd200/vl test host|r Name: invite them like a hop host · |cffffd200/vl test rare|r: a made-up rare on another layer") end
    elseif cmd == "hop" then
        local _, zone = c:Here()
        local p = pairFor(c, zone, rest)
        if p == false then say(("no %s known in this zone."):format(rest)) return end
        c:Start(p)
    elseif cmd == "host" then c:SetHosting(not c:HostingOn())
    elseif cmd == "layers" then c:Report()
    elseif cmd == "stats" then
        -- hop health (2026-11-16): how your hops ended and how hosting went, this character
        if not c.HopStats then say("the running layer core is older; update VoidSweep too.") return end
        local t, log = c:HopStats()
        local function n(k) return tonumber(t[k]) or 0 end
        -- one "start" per hop however many helpers it tried; a move that was sent back isn't a success (Sol review)
        local tried = n("start")
        local good = math.max(0, n("moved") - n("reverted"))
        local secs, cnt, asked = 0, 0, 0
        for _, e in ipairs(log) do
            if e.r == "moved" and tonumber(e.s) then secs, cnt, asked = secs + e.s, cnt + 1, asked + (tonumber(e.a) or 1) end
        end
        say(("hops on this character: %d tried, |cff33ff33%d worked|r%s%s."):format(tried, good,
            tried > 0 and (" (%d%%)"):format(math.floor(math.min(good, tried) * 100 / tried + 0.5)) or "",
            cnt > 0 and (", %d s on average, %.1f helpers asked"):format(math.floor(secs / cnt + 0.5), asked / cnt) or ""))
        say(("didn't work: nobody could %d, move not confirmed %d, group ended %d, sent back %d, cancelled %d. Helpers who didn't move you (tried the next) %d. No helper on another layer at all: %d (fresh: %d).")
            :format(n("nobody"), n("unconfirmed"), n("groupEnded"), n("reverted"), n("cancelled"), n("joinedNoMove"), n("noHelper"), n("noFresh")))
        say(("you helped: %d came over, %d didn't accept; from your Group Finder listing %d came, %d didn't.")
            :format(n("hostCame"), n("hostNoShow"), n("hostFinderCame"), n("hostFinderNoShow")))
    elseif cmd == "net" then
        if c.NetReport then c:NetReport() else say("the running layer core is older; update VoidSweep too.") end
    else
        say("|cffffd200/vl|r the window · |cffffd200/vl hop|r [17] hop to another layer · |cffffd200/vl host|r help others change layer on/off · |cffffd200/vl layers|r the layers here in chat · |cffffd200/vl net|r players online + whisper counts · |cffffd200/vl stats|r how your hops went")
    end
end

local boot = CreateFrame("Frame")
boot:RegisterEvent("PLAYER_LOGIN")
boot:SetScript("OnEvent", function()
    if not forever() then return end
    restoreRefresh()
    ns.OnLayerCore(function(c)
        c:OnChange(function() ns.UpdateLabel(); UI_Update() end)
        ns.UpdateLabel()
        if db().open then win = win or build(); win:Show() end
    end)
    C_Timer.NewTicker(5, ns.UpdateLabel)
end)

VoidHubLaunchers = VoidHubLaunchers or {}
VoidHubLaunchers.VoidLayer = { icon = "Interface\\Icons\\Spell_Arcane_Blink", onClick = function() toggle() end }

VoidHubToggles = VoidHubToggles or {}
table.insert(VoidHubToggles, {
    id = "VoidLayer.rares", group = "Layers", label = "Rare alerts",
    tip = "A rare up on another layer of your zone asks \"Hop there?\".",
    get = function() local c = core(); return c and c:PopupsOn() or false end,
    set = function(on) local c = core(); if c then c:SetPopups(on) end end,
})

----------------------------------------------------------------------
-- Read-only hooks for the all-in-one VoidHub window (2026-11-24). The hub draws its own Layers page from
-- these, the same helpers this window uses (everything else comes from VoidLayerCore). Nothing here changes
-- this window.
----------------------------------------------------------------------
_G.VoidLayerHub = {
    SeenText = function(c, zone, cur) return seenText(true, c, zone, cur) end,
    SpanText = function(c, zone, cur) return ns.SpanText(c, zone, cur) end,
    RefreshLeft = refreshLeft, CanRefreshNow = canRefreshNow, RefreshNow = function() return ns.RefreshNow() end,
    OtherLayers = otherLayers, Ago = ago, ZoneName = zoneName, Forever = forever,
    LabelOn = function() return char().label ~= false end,
    SetLabel = function(on) char().label = on; ns.UpdateLabel() end,
    Toggle = toggle,
}
