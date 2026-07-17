-- Options.lua
-- A proper options window for every setting that used to live only in the right-click
-- Dewdrop menu off the minimap button (ArcHUD.dewdrop_menu, built by Core.lua and by
-- each ring module via ArcHUD.modulePrototype:RegisterDewdropSettings in ModuleCore.lua).
--
-- This reads that same table directly instead of duplicating option lists by hand, so no
-- option's key, default, tooltip, or callback changes - only how it's presented. The old
-- Dewdrop menu code (createDDMenu, dewdrop_menu) is left completely intact; only the two
-- places that used to open it (the "/archud config" command and the minimap button) now
-- open this frame instead.

ArcHUD.Options = {}
local Options = ArcHUD.Options

local CHECK_HEIGHT = 22
local SLIDER_HEIGHT = 44
local GAP_HEIGHT = 10
local CATEGORY_BUTTON_HEIGHT = 24
-- A slider's own title text (set via the "...Text" sub-widget) sits above its anchor
-- point rather than below it, so it needs extra headroom before its own TOPLEFT anchor -
-- both for the very first row in a panel (against the scrollframe's top edge) and for any
-- slider that directly follows a checkbox/label row (against that row's own text).
local CONTENT_START_Y = -20
local SLIDER_TOP_PADDING = 14

local categoriesBuilt = false
local categoryButtons = {}
local checkPool = {}
local sliderPool = {}
local labelPool = {}
local currentCategoryKey, currentCategoryLabel

local function resolveProfile(namespace)
	if namespace then
		return ArcHUD:AcquireDBNamespace(namespace).profile
	end
	return ArcHUD.db.profile
end

-- Turns one dewdrop_menu row (a flat {"key1", val1, "key2", val2, ...} array) into a
-- lookup table - the same shape ArcHUD.createDDMenu already parses positionally.
local function parseEntry(entry)
	local data = {}
	local n = table.getn(entry)
	local i = 1
	while i < n do
		data[entry[i]] = entry[i + 1]
		i = i + 2
	end
	return data
end

-- Mirrors createDDMenu's own arg3/arg4 disambiguation exactly (arg3 is either the radio
-- value directly, or a namespace with the value in arg4), so a radio's current selection
-- reads correctly regardless of which shape a given entry uses.
local function isRadioSelected(data)
	if data.arg4 then
		return resolveProfile(data.arg3)[data.arg2] == data.arg4
	end
	return resolveProfile(nil)[data.arg2] == data.arg3
end

local function toggleChecked(data)
	return resolveProfile(data.arg3)[data.arg2] and true or false
end

local function currentSliderValue(data)
	return resolveProfile(data.sliderArg3)[data.sliderArg2] or 0
end

local function fireClick(data)
	data.func(data.arg1, data.arg2, data.arg3, data.arg4)
end

local function fireSlider(data, value)
	if data.sliderArg3 then
		data.sliderFunc(data.sliderArg1, data.sliderArg2, data.sliderArg3, value)
	else
		data.sliderFunc(data.sliderArg1, data.sliderArg2, value)
	end
end

local function showTooltip()
	if this.tooltipTitle then
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(this.tooltipTitle, 1, 1, 1)
		if this.tooltipText then
			GameTooltip:AddLine(this.tooltipText, nil, nil, nil, true)
		end
		GameTooltip:Show()
	end
end

local function hideTooltip()
	GameTooltip:Hide()
end

-- A checkbox is reused for both plain toggles and individual radio options (a radio
-- group is just several of these that deselect each other on click).
local function acquireCheckbox(index)
	local btn = checkPool[index]
	if not btn then
		local name = "ArcHUDOptionsCheck" .. index
		btn = CreateFrame("CheckButton", name, ArcHUDOptionsFrameContentScrollFrameScrollChild, "UICheckButtonTemplate")
		btn:SetWidth(20)
		btn:SetHeight(20)
		local text = getglobal(name .. "Text")
		text:SetFontObject(GameFontHighlight)
		text:SetJustifyH("LEFT")
		text:SetWidth(260)
		btn.text = text
		btn:SetScript("OnEnter", showTooltip)
		btn:SetScript("OnLeave", hideTooltip)
		btn:SetScript("OnClick", function()
			local data = this.entryData
			if not data then
				return
			end
			fireClick(data)
			if this.isRadio then
				Options:RefreshRadioGroup(this.radioSubKey)
			else
				this:SetChecked(toggleChecked(data) and 1 or nil)
			end
		end)
		checkPool[index] = btn
	end
	return btn
end

-- The label text is combined with the current value ("Fade when full: 10%") into the
-- slider's own title sub-widget, rather than a separate FontString below the slider -
-- OptionsSliderTemplate's Low/High labels already sit right at the slider's bottom edge,
-- so a second text anchored below the slider collided with them.
local function formatSliderValue(slider, value)
	local formatted = slider.isPercent and (math.floor(value * 100 + 0.5) .. "%") or tostring(value)
	return (slider.labelPrefix or "") .. ": " .. formatted
end

local function acquireSlider(index)
	local slider = sliderPool[index]
	if not slider then
		local name = "ArcHUDOptionsSlider" .. index
		slider = CreateFrame("Slider", name, ArcHUDOptionsFrameContentScrollFrameScrollChild, "OptionsSliderTemplate")
		slider:SetWidth(280)
		slider:SetHeight(16)
		slider:SetOrientation("HORIZONTAL")
		slider.titleText = getglobal(name .. "Text")
		slider.titleText:SetFontObject(GameFontHighlight)
		slider:SetScript("OnEnter", showTooltip)
		slider:SetScript("OnLeave", hideTooltip)
		slider:SetScript("OnValueChanged", function()
			-- Never call this:SetValue() from in here - it re-fires OnValueChanged (unlike
			-- CheckButton:SetChecked(), which doesn't re-fire OnClick) and would loop.
			local data = this.entryData
			if not data then
				return
			end
			local value = this:GetValue()
			fireSlider(data, value)
			this.titleText:SetText(formatSliderValue(this, value))
		end)
		sliderPool[index] = slider
	end
	return slider
end

local function acquireLabel(index)
	local lbl = labelPool[index]
	if not lbl then
		lbl = ArcHUDOptionsFrameContentScrollFrameScrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		lbl:SetJustifyH("LEFT")
		lbl:SetWidth(280)
		labelPool[index] = lbl
	end
	return lbl
end

local function acquireCategoryButton(index)
	local btn = categoryButtons[index]
	if not btn then
		btn = CreateFrame("Button", "ArcHUDOptionsCategory" .. index, ArcHUDOptionsFrameCategoryScrollFrameScrollChild, "UIPanelButtonTemplate")
		btn:SetWidth(148)
		btn:SetHeight(20)
		btn:SetScript("OnClick", function()
			Options:SelectCategory(this.categoryKey, this.categoryLabel)
		end)
		categoryButtons[index] = btn
	end
	return btn
end

function Options:RefreshRadioGroup(subKey)
	local i = 1
	while checkPool[i] do
		local btn = checkPool[i]
		if btn:IsShown() and btn.isRadio and btn.radioSubKey == subKey and btn.entryData then
			btn:SetChecked(isRadioSelected(btn.entryData) and 1 or nil)
		end
		i = i + 1
	end
end

function Options:BuildCategories()
	if categoriesBuilt then
		return
	end
	local list = ArcHUD.dewdrop_menu and ArcHUD.dewdrop_menu["L1"]
	if not list then
		return
	end
	categoriesBuilt = true

	local y = -4
	local index = 0
	for _, entry in ipairs(list) do
		if type(entry) == "table" and table.getn(entry) > 0 then
			local data = parseEntry(entry)
			if data.hasArrow and data.value and not data.hasSlider then
				index = index + 1
				local btn = acquireCategoryButton(index)
				btn:SetText(data.text or data.value)
				btn.categoryKey = data.value
				btn.categoryLabel = data.text
				btn:ClearAllPoints()
				btn:SetPoint("TOPLEFT", ArcHUDOptionsFrameCategoryScrollFrameScrollChild, "TOPLEFT", 4, y)
				btn:Show()
				y = y - CATEGORY_BUTTON_HEIGHT
			end
		end
	end
	ArcHUDOptionsFrameCategoryScrollFrameScrollChild:SetHeight(math.max(390, math.abs(y) + 10))

	if index > 0 then
		local first = categoryButtons[1]
		Options:SelectCategory(first.categoryKey, first.categoryLabel)
	end
end

-- Renders one category (a dewdrop_menu["L2_..."] table) as a stacked list of controls.
-- A nested "hasArrow"+"value" entry (Side, Ring Visibility) is inline-expanded as a
-- labeled radio row here instead of becoming yet another level of navigation - the old
-- menu needed a second flyout for these purely because Dewdrop can't show a slider or a
-- radio set inline; a real frame can.
function Options:SelectCategory(key, label)
	currentCategoryKey = key
	currentCategoryLabel = label
	getglobal("ArcHUDOptionsFrameContentTitle"):SetText(label or "")

	local i = 1
	while checkPool[i] do
		checkPool[i]:Hide()
		i = i + 1
	end
	i = 1
	while sliderPool[i] do
		sliderPool[i]:Hide()
		i = i + 1
	end
	i = 1
	while labelPool[i] do
		labelPool[i]:Hide()
		i = i + 1
	end

	for _, btn in ipairs(categoryButtons) do
		if btn.categoryKey == key then
			btn:LockHighlight()
		else
			btn:UnlockHighlight()
		end
	end

	local list = ArcHUD.dewdrop_menu and ArcHUD.dewdrop_menu[key]
	if not list then
		return
	end

	local checkIndex, sliderIndex, labelIndex = 0, 0, 0
	local y = CONTENT_START_Y

	local function layoutEntries(entries, indent)
		for _, entry in ipairs(entries) do
			if type(entry) == "table" then
				if table.getn(entry) == 0 then
					y = y - GAP_HEIGHT
				else
					local data = parseEntry(entry)
					if data.isTitle or data.notClickable then
						-- decorative name/version/author line from the old menu - the frame
						-- already shows the category name in its own title, skip these.
					elseif data.hasSlider then
						sliderIndex = sliderIndex + 1
						local slider = acquireSlider(sliderIndex)
						-- Assign every field OnValueChanged might read BEFORE calling any
						-- Slider setter below - SetMinMaxValues/SetValue can re-clamp the
						-- widget's leftover value from whatever this pooled slider was used
						-- for last and synchronously re-fire OnValueChanged, and that handler
						-- must never see a previous entry's stale data.
						slider.tooltipTitle = data.tooltipTitle
						slider.tooltipText = data.tooltipText
						slider.entryData = data
						slider.isPercent = data.sliderIsPercent
						slider.labelPrefix = data.text
						local minV = data.sliderMin or 0
						local maxV = data.sliderMax or (data.sliderIsPercent and 1 or 100)
						slider:SetMinMaxValues(minV, maxV)
						slider:SetValueStep(data.sliderStep or 1)
						getglobal(slider:GetName() .. "Low"):SetText(data.sliderMinText or tostring(minV))
						getglobal(slider:GetName() .. "High"):SetText(data.sliderMaxText or tostring(maxV))
						y = y - SLIDER_TOP_PADDING
						slider:ClearAllPoints()
						slider:SetPoint("TOPLEFT", ArcHUDOptionsFrameContentScrollFrameScrollChild, "TOPLEFT", 6 + indent, y)
						local current = currentSliderValue(data)
						slider:SetValue(current)
						slider.titleText:SetText(formatSliderValue(slider, current))
						slider:Show()
						y = y - SLIDER_HEIGHT
					elseif data.hasArrow and data.value then
						labelIndex = labelIndex + 1
						local lbl = acquireLabel(labelIndex)
						lbl:SetText(data.text or "")
						lbl:ClearAllPoints()
						lbl:SetPoint("TOPLEFT", ArcHUDOptionsFrameContentScrollFrameScrollChild, "TOPLEFT", 6 + indent, y)
						lbl:Show()
						y = y - CHECK_HEIGHT

						local sub = ArcHUD.dewdrop_menu[data.value]
						if sub then
							for _, subEntry in ipairs(sub) do
								if type(subEntry) == "table" and table.getn(subEntry) > 0 then
									local subData = parseEntry(subEntry)
									checkIndex = checkIndex + 1
									local rb = acquireCheckbox(checkIndex)
									rb.text:SetText(subData.text or "")
									rb.tooltipTitle = subData.tooltipTitle
									rb.tooltipText = subData.tooltipText
									rb.entryData = subData
									rb.isRadio = true
									rb.radioSubKey = data.value
									rb:SetChecked(isRadioSelected(subData) and 1 or nil)
									rb:ClearAllPoints()
									rb:SetPoint("TOPLEFT", ArcHUDOptionsFrameContentScrollFrameScrollChild, "TOPLEFT", 16 + indent, y)
									rb:Show()
									y = y - CHECK_HEIGHT
								end
							end
						end
					else
						checkIndex = checkIndex + 1
						local cb = acquireCheckbox(checkIndex)
						cb.text:SetText(data.text or "")
						cb.tooltipTitle = data.tooltipTitle
						cb.tooltipText = data.tooltipText
						cb.entryData = data
						cb.isRadio = false
						cb:SetChecked(toggleChecked(data) and 1 or nil)
						cb:ClearAllPoints()
						cb:SetPoint("TOPLEFT", ArcHUDOptionsFrameContentScrollFrameScrollChild, "TOPLEFT", 6 + indent, y)
						cb:Show()
						y = y - CHECK_HEIGHT
					end
				end
			end
		end
	end

	layoutEntries(list, 0)
	ArcHUDOptionsFrameContentScrollFrameScrollChild:SetHeight(math.max(366, math.abs(y) + 10))
end

function Options:Show()
	ArcHUDOptionsFrame:Show()
end

function Options:Hide()
	ArcHUDOptionsFrame:Hide()
end

function Options:Toggle()
	if ArcHUDOptionsFrame:IsShown() then
		ArcHUDOptionsFrame:Hide()
	else
		ArcHUDOptionsFrame:Show()
	end
end

function Options:OnShow()
	self:BuildCategories()
	-- Re-render the current category on every open (not just the first), so a value
	-- changed elsewhere (e.g. a macro calling ArcHUD.modDB directly) while the frame was
	-- hidden shows up correctly instead of the stale state from last time it was open.
	if currentCategoryKey then
		self:SelectCategory(currentCategoryKey, currentCategoryLabel)
	end
end
