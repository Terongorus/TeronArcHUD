--
-- ArcHUDFu -- a FuBar button interface to ArcHUD
--

-- Only load if ArcHUD is already loaded
if not ArcHUD then return end

ArcHUDFu = AceLibrary("AceAddon-2.0"):new("AceDB-2.0", "FuBarPlugin-2.0")
ArcHUDFu:RegisterDB("ArcHUDDB")
ArcHUDFu.hasIcon = "Interface\\Icons\\Ability_Hunter_Pathfinding"
ArcHUDFu.cannotDetachTooltip = true
ArcHUDFu.independentProfile = true
ArcHUDFu.hideWithoutStandby = true

-- These used to open the old right-click Dewdrop menu (ArcHUD.createDDMenu, still intact
-- in Core.lua and read directly by Options.lua) - both FuBar-bar mode (OnMenuRequest) and
-- minimap-icon mode (OnClick for left-click, OpenMenu for right-click) now open the
-- options frame instead.
function ArcHUDFu:OnMenuRequest()
	ArcHUD.Options:Toggle()
end

function ArcHUDFu:OnClick()
	ArcHUD.Options:Toggle()
end

function ArcHUDFu:OpenMenu()
	ArcHUD.Options:Toggle()
end
