-- All Profession Recipes (모든 전문 기술 제조법)
-- 전문 기술 창 옆 탭에 배우지 않은 전문 기술을 추가하고, 기본 창과 같은 형태로 제작 목록을 보여준다.
local ADDON, ns = ...

local Data, ItemNames = ns.Data, ns.ItemNames
local CLIENT_KO = (GetLocale() == "koKR")
local IS_KO = CLIENT_KO
local LI = IS_KO and 1 or 2 -- 이름 언어 인덱스

------------------------------------------------------------------------
-- 문자열
------------------------------------------------------------------------
local L_KO = {
	settings = "설정",
	settingsTip = "설정\n언어, 탭 위치, 아이콘 크기, 후원",
	language = "언어",
	langAuto = "자동 (게임 언어)",
	langKo = "한국어",
	langEn = "English",
	langNote = "영어 게임 클라이언트에서는 한국어 글꼴이 깨질 수 있습니다.",
	tabPosLabel = "탭 위치",
	posLeftL = "왼쪽",
	posBottomL = "아래",
	posRightL = "오른쪽",
	iconSizeLabel = "탭 아이콘 크기: %d",
	donate = "후원하기",
	donateText = "애드온이 도움이 되셨다면 커피 한 잔 후원 부탁드려요!\n아래 주소를 Ctrl+C로 복사해서 브라우저에 붙여넣으세요.",
	notLearned = "배우지 않음",
	missingTitle = "안 배운 제조법",
	hideLearned = "배운 것 숨기기",
	alreadyLearned = "이미 배움",
	learnedMark = "(배움)",
	needSkill = "숙련 %d 필요",
	currentTip = "안 배운 제조법\n지금 열려 있는 전문 기술에서 아직 배우지 않은 제조법을 보여줍니다.",
	openProfFirst = "먼저 배운 전문 기술(요리, 응급치료 등) 탭을 연 다음 눌러 주세요.",
	search = "검색",
	onlyNew = "포에버 신규만",
	cap = "숙련 225 이하만",
	reagents = "재료:",
	skill = "숙련:",
	trainer = "전문 기술 전문가에게 배움",
	book = "제조법 아이템으로 배움 (판매·획득·퀘스트)",
	newTag = "포에버 신규",
	makes = "제작 수량: %d",
	noRecipes = "조건에 맞는 제조법이 없습니다.",
	hoverHint = "아이콘에 마우스를 올리면 자세한 정보가 보입니다.",
	tabTip = "%s (배우지 않음)\n제작 목록 보기",
	count = "%d개",
	source = "데이터: wowf.io, seemeta.com",
	help = "/apr : 창 열기   /apr left : 탭을 창 왼쪽에   /apr bottom : 탭을 창 아래에   /apr side : 탭을 창 오른쪽에   /apr reset : 설정 초기화",
	posSide = "탭을 창 오른쪽에 붙였습니다.",
	posLeft = "탭을 창 왼쪽에 붙였습니다.",
	posBottom = "탭을 창 아래에 붙였습니다.",
	resetDone = "설정을 초기화했습니다.",
}
local L_EN = {
	settings = "Settings",
	settingsTip = "Settings\nLanguage, tab position, icon size, support",
	language = "Language",
	langAuto = "Auto (game language)",
	langKo = "한국어",
	langEn = "English",
	langNote = "Korean text may not display on an English game client.",
	tabPosLabel = "Tab position",
	posLeftL = "Left",
	posBottomL = "Bottom",
	posRightL = "Right",
	iconSizeLabel = "Tab icon size: %d",
	donate = "Support",
	donateText = "If this addon helps you, consider buying me a coffee!\nCopy the address below with Ctrl+C and paste it in your browser.",
	notLearned = "Not learned",
	missingTitle = "Missing recipes",
	hideLearned = "Hide learned",
	alreadyLearned = "Already learned",
	learnedMark = "(learned)",
	needSkill = "Requires skill %d",
	currentTip = "Missing recipes\nShows recipes you have not learned yet for the open profession.",
	openProfFirst = "Open one of your professions first, then click this tab.",
	search = "Search",
	onlyNew = "Forever new only",
	cap = "Skill 225 or less",
	reagents = "Reagents:",
	skill = "Skill:",
	trainer = "Learned from a trainer",
	book = "Learned from a recipe item (vendor/drop/quest)",
	newTag = "New in Forever",
	makes = "Creates: %d",
	noRecipes = "No recipes match.",
	hoverHint = "Hover the icon for details.",
	tabTip = "%s (not learned)\nShow recipes",
	count = "%d recipes",
	source = "Data: wowf.io, seemeta.com",
	help = "/apr : open window   /apr left : tabs left of window   /apr bottom : tabs below window   /apr side : tabs right of window   /apr reset : reset settings",
	posSide = "Tabs moved to the right of the window.",
	posLeft = "Tabs moved to the left of the window.",
	posBottom = "Tabs moved below the window.",
	resetDone = "Settings reset.",
}
local L = IS_KO and L_KO or L_EN
local DONATE_URL = "https://buymeacoffee.com/qqhrqqhr2"

-- 표시 순서와 아이콘
local PROFESSIONS = {
	{ id = 171, icon = "Interface\\Icons\\Trade_Alchemy",          ko = "연금술",   en = "Alchemy" },
	{ id = 164, icon = "Interface\\Icons\\Trade_BlackSmithing",    ko = "대장기술", en = "Blacksmithing" },
	{ id = 333, icon = "Interface\\Icons\\Trade_Engraving",        ko = "마법부여", en = "Enchanting" },
	{ id = 202, icon = "Interface\\Icons\\Trade_Engineering",      ko = "기계공학", en = "Engineering" },
	{ id = 165, icon = "Interface\\Icons\\Trade_LeatherWorking",   ko = "가죽세공", en = "Leatherworking" },
	{ id = 197, icon = "Interface\\Icons\\Trade_Tailoring",        ko = "재봉술",   en = "Tailoring" },
	{ id = 186, icon = "Interface\\Icons\\Trade_Mining",           ko = "채광",     en = "Mining" },
	{ id = 185, icon = "Interface\\Icons\\INV_Misc_Food_15",       ko = "요리",     en = "Cooking" },
	{ id = 129, icon = "Interface\\Icons\\Spell_Holy_SealOfSacrifice", ko = "응급치료", en = "First Aid" },
	{ id = 182, icon = "Interface\\Icons\\Trade_Herbalism",        ko = "약초 채집", en = "Herbalism" },
	{ id = 393, icon = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01",  ko = "무두질",   en = "Skinning" },
	{ id = 356, icon = "Interface\\Icons\\Trade_Fishing",          ko = "낚시",     en = "Fishing" },
}
local PROF_BY_ID = {}
for _, p in ipairs(PROFESSIONS) do PROF_BY_ID[p.id] = p end

local function ProfName(p)
	return IS_KO and p.ko or p.en
end

-- 레시피 배열 인덱스
local R_SPELL, R_ITEM, R_CAT, R_ORANGE, R_YELLOW, R_GREEN, R_GREY, R_FLAGS, R_QTY, R_ICON, R_NAME_KO, R_NAME_EN, R_REAG, R_DESC_KO, R_DESC_EN, R_SRC_KO, R_SRC_EN =
	1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17
local F_NEW, F_TRAINER = 1, 2

local function HasFlag(r, f) return bit.band(r[R_FLAGS], f) ~= 0 end
local function RecipeName(r) return IS_KO and r[R_NAME_KO] or r[R_NAME_EN] end
local function RecipeDesc(r) return IS_KO and r[R_DESC_KO] or r[R_DESC_EN] end
local function RecipeSrc(r) return (IS_KO and r[R_SRC_KO] or r[R_SRC_EN]) or "" end

------------------------------------------------------------------------
-- 저장 변수
------------------------------------------------------------------------
local DEFAULTS = { collapsed = {}, onlyNew = false, cap = false, standalonePos = nil, tabPos = "left", hideLearned = true, lang = "auto" }
local DB

local function ApplyLanguage()
	local lang = DB and DB.lang or "auto"
	if lang == "ko" then IS_KO = true elseif lang == "en" then IS_KO = false else IS_KO = CLIENT_KO end
	LI = IS_KO and 1 or 2
	L = IS_KO and L_KO or L_EN
end

local function InitDB()
	AllProfessionRecipesDB = AllProfessionRecipesDB or {}
	DB = AllProfessionRecipesDB
	for k, v in pairs(DEFAULTS) do
		if DB[k] == nil then DB[k] = (type(v) == "table") and {} or v end
	end
	ApplyLanguage()
end

------------------------------------------------------------------------
-- 아이템 정보 헬퍼
------------------------------------------------------------------------
local GetItemNameByID = (C_Item and C_Item.GetItemNameByID) or function(id) return (GetItemInfo(id)) end
local GetItemIconByID = (C_Item and C_Item.GetItemIconByID) or GetItemIcon
local GetItemQualityByID = (C_Item and C_Item.GetItemQualityByID) or function(id) return select(3, GetItemInfo(id)) end
local GetItemCountFn = (C_Item and C_Item.GetItemCount) or GetItemCount
local GetItemInfoFn = (C_Item and C_Item.GetItemInfo) or GetItemInfo

local function ItemName(id)
	if IS_KO ~= CLIENT_KO and ItemNames[id] then return ItemNames[id][LI] end
	local n = GetItemNameByID(id)
	if n then return n end
	if C_Item and C_Item.RequestLoadItemDataByID then C_Item.RequestLoadItemDataByID(id) end
	local f = ItemNames[id]
	return f and f[LI] or ("#" .. id)
end

local function ItemIcon(id, fallback)
	local t = GetItemIconByID and GetItemIconByID(id)
	if t then return t end
	if fallback and fallback ~= "" then return "Interface\\Icons\\" .. fallback end
	return 134400 -- 물음표
end

local function QualityHex(id)
	local q = id and id > 0 and GetItemQualityByID(id)
	if q and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[q] then
		return ITEM_QUALITY_COLORS[q].hex
	end
	return "|cffffd100"
end

local function RecipeIcon(r)
	if r[R_ICON] ~= "" then return "Interface\\Icons\\" .. r[R_ICON] end
	if r[R_ITEM] > 0 then return ItemIcon(r[R_ITEM]) end
	local tex = C_Spell and C_Spell.GetSpellTexture and C_Spell.GetSpellTexture(r[R_SPELL])
	return tex or 134400
end

local function SkillText(r)
	local parts = { "|cffff8040" .. r[R_ORANGE] .. "|r" }
	if r[R_YELLOW] > 0 then
		parts[#parts + 1] = "|cffffff00" .. r[R_YELLOW] .. "|r"
		parts[#parts + 1] = "|cff40bf40" .. r[R_GREEN] .. "|r"
		parts[#parts + 1] = "|cff808080" .. r[R_GREY] .. "|r"
	end
	return table.concat(parts, "  ")
end

------------------------------------------------------------------------
-- 배운 전문 기술 확인
------------------------------------------------------------------------
local function GetLearnedSkillLines()
	local learned = {}
	if GetProfessions and GetProfessionInfo then
		local list = { GetProfessions() }
		for i = 1, 6 do
			local idx = list[i]
			if idx then
				local skillLine = select(7, GetProfessionInfo(idx))
				if skillLine then learned[skillLine] = true end
			end
		end
	end
	-- 전문 기술 주문(수습~전문가 등급)으로 확인
	local RANK_SPELLS = {
		[171] = { 2259, 3101, 3464, 11611 }, [164] = { 2018, 3100, 3538, 9785 },
		[333] = { 7411, 7412, 7413, 13920 }, [202] = { 4036, 4037, 4038, 12656 },
		[165] = { 2108, 3104, 3811, 10662 }, [197] = { 3908, 3909, 3910, 12180 },
		[186] = { 2575, 2576, 3564, 10248, 2656 }, [185] = { 2550, 3102, 3413, 18260 },
		[129] = { 3273, 3274, 7924, 10846 },
		[182] = { 2366, 2368, 3570, 11993 }, [393] = { 8613, 8617, 8618, 10768 },
		[356] = { 7620, 7731, 7732, 18248 },
	}
	local isKnown = IsPlayerSpell or IsSpellKnown
	if isKnown then
		for skill, spells in pairs(RANK_SPELLS) do
			for _, id in ipairs(spells) do
				local ok, known = pcall(isKnown, id)
				if ok and known then learned[skill] = true break end
			end
		end
	end
	-- 예전 방식(스킬 목록) 보조 확인
	if GetNumSkillLines and GetSkillLineInfo then
		local names = {}
		for _, p in ipairs(PROFESSIONS) do names[p.ko] = p.id; names[p.en] = p.id end
		for i = 1, GetNumSkillLines() do
			local name, isHeader = GetSkillLineInfo(i)
			if name and not isHeader and names[name] then learned[names[name]] = true end
		end
	end
	return learned
end

------------------------------------------------------------------------
-- 메인 창
------------------------------------------------------------------------
local Panel
local ROW_H, NUM_ROWS = 18, 26
local currentProf
local selectedRecipe
local listEntries = {}
local scrollOffset = 0

local function CreateBackdropFrame(parent, name)
	local ok, f = pcall(CreateFrame, "Frame", name, parent, "PortraitFrameTemplate")
	if ok and f then return f, true end
	f = CreateFrame("Frame", name, parent, "BackdropTemplate")
	f:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 },
	})
	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)
	f.CloseButton = close
	return f, false
end

local function SetPanelTitle(text)
	if Panel.SetTitle then
		Panel:SetTitle(text)
	elseif Panel.TitleContainer and Panel.TitleContainer.TitleText then
		Panel.TitleContainer.TitleText:SetText(text)
	elseif Panel.TitleText then
		Panel.TitleText:SetText(text)
	else
		Panel.fallbackTitle:SetText(text)
	end
end

local function SetPanelPortrait(tex)
	if Panel.SetPortraitToAsset then
		Panel:SetPortraitToAsset(tex)
	elseif Panel.PortraitContainer and Panel.PortraitContainer.portrait then
		SetPortraitToTexture(Panel.PortraitContainer.portrait, tex)
	elseif Panel.portrait then
		SetPortraitToTexture(Panel.portrait, tex)
	end
end

-- 배운 전문 기술 모드 ----------------------------------------------------
local learnedMode = false
local learnedSpells = {}
local curSkill = 0

local function MatchProfName(name)
	if not name then return nil end
	for _, p in ipairs(PROFESSIONS) do
		if name == p.ko or name == p.en then return p.id end
	end
end

local function CurrentTradeSkillLine()
	if C_TradeSkillUI then
		if C_TradeSkillUI.GetBaseProfessionInfo then
			local ok, info = pcall(C_TradeSkillUI.GetBaseProfessionInfo)
			if ok and type(info) == "table" then
				local id = (info.professionID and Data[info.professionID] and info.professionID)
					or (info.parentProfessionID and Data[info.parentProfessionID] and info.parentProfessionID)
					or MatchProfName(info.professionName) or MatchProfName(info.parentProfessionName)
				if id then return id, info.skillLevel end
			end
		end
		if C_TradeSkillUI.GetTradeSkillLine then
			local ok, id, name, rank = pcall(C_TradeSkillUI.GetTradeSkillLine)
			if ok then
				id = (id and Data[id] and id) or MatchProfName(name)
				if id then return id, rank end
			end
		end
	end
	if GetTradeSkillLine then
		local name, rank = GetTradeSkillLine()
		local id = MatchProfName(name)
		if id then return id, rank end
	end
end

local function RefreshLearned()
	wipe(learnedSpells)
	if C_TradeSkillUI and C_TradeSkillUI.GetAllRecipeIDs then
		local ok, ids = pcall(C_TradeSkillUI.GetAllRecipeIDs)
		if ok and type(ids) == "table" then
			for _, id in ipairs(ids) do
				local ok2, info = pcall(C_TradeSkillUI.GetRecipeInfo, id)
				if ok2 and info and info.learned then learnedSpells[id] = true end
			end
		end
	end
end

local function IsLearned(r)
	if learnedSpells[r[R_SPELL]] then return true end
	if IsPlayerSpell then
		local ok, known = pcall(IsPlayerSpell, r[R_SPELL])
		if ok and known then return true end
	end
	return false
end

local function DifficultyColor(r)
	if curSkill < r[R_ORANGE] then return "|cffff2020" end
	if r[R_YELLOW] == 0 or curSkill < r[R_YELLOW] then return "|cffff8040" end
	if curSkill < r[R_GREEN] then return "|cffffff00" end
	if curSkill < r[R_GREY] then return "|cff40bf40" end
	return "|cff808080"
end

-- 목록 만들기 -----------------------------------------------------------
local function RecipeMatches(r, query)
	if DB.onlyNew and not HasFlag(r, F_NEW) then return false end
	if DB.cap and r[R_ORANGE] > 225 then return false end
	if learnedMode and DB.hideLearned and IsLearned(r) then return false end
	if query and query ~= "" then
		local q = query:lower()
		if RecipeName(r):lower():find(q, 1, true) then return true end
		for _, rg in ipairs(r[R_REAG]) do
			if ItemName(rg[1]):lower():find(q, 1, true) then return true end
		end
		return false
	end
	return true
end

local function BuildList()
	wipe(listEntries)
	local data = currentProf and Data[currentProf]
	if not data then return end
	local query = Panel.search:GetText()
	local byCat = {}
	for _, r in ipairs(data.recipes) do
		if RecipeMatches(r, query) then
			local c = r[R_CAT]
			byCat[c] = byCat[c] or {}
			table.insert(byCat[c], r)
		end
	end
	local order, seen = {}, {}
	for _, c in ipairs(data.cats) do order[#order + 1] = { c[1], IS_KO and c[2] or c[3] }; seen[c[1]] = true end
	for c in pairs(byCat) do if not seen[c] then order[#order + 1] = { c, IS_KO and "기타" or "Other" } end end
	local searching = query and query ~= ""
	local collapsed = DB.collapsed[currentProf] or {}
	for _, c in ipairs(order) do
		local list = byCat[c[1]]
		if list then
			table.sort(list, function(a, b)
				if a[R_ORANGE] ~= b[R_ORANGE] then return a[R_ORANGE] > b[R_ORANGE] end
				return RecipeName(a) < RecipeName(b)
			end)
			local isCollapsed = collapsed[c[1]] and not searching
			listEntries[#listEntries + 1] = { header = true, cat = c[1], name = c[2], n = #list, collapsed = isCollapsed }
			if not isCollapsed then
				for _, r in ipairs(list) do listEntries[#listEntries + 1] = { recipe = r } end
			end
		end
	end
end

local UpdateDetail

local function UpdateList()
	local maxOffset = math.max(0, #listEntries - NUM_ROWS)
	if scrollOffset > maxOffset then scrollOffset = maxOffset end
	if scrollOffset < 0 then scrollOffset = 0 end
	Panel.slider:SetMinMaxValues(0, maxOffset)
	Panel.slider:SetValue(scrollOffset)
	Panel.slider:SetShown(maxOffset > 0)
	for i = 1, NUM_ROWS do
		local row = Panel.rows[i]
		local e = listEntries[i + scrollOffset]
		row.entry = e
		if not e then
			row:Hide()
		else
			row:Show()
			if e.header then
				row.text:SetPoint("LEFT", 6, 0)
				row.text:SetText("|cffffd100" .. e.name .. "|r |cff808080(" .. e.n .. ")|r")
				row.right:SetText(e.collapsed and "|cffffd100+|r" or "|cffffd100-|r")
				row.hl:SetShown(false)
				row.headerBg:Show()
			else
				local r = e.recipe
				row.headerBg:Hide()
				row.text:SetPoint("LEFT", 18, 0)
				local name = RecipeName(r)
				if HasFlag(r, F_NEW) then name = name .. " |cff66ccff*|r" end
				if learnedMode then
					if IsLearned(r) then name = "|cff808080" .. name .. " " .. L.learnedMark .. "|r" end
					row.right:SetText(DifficultyColor(r) .. r[R_ORANGE] .. "|r")
				else
					row.right:SetText("|cffff8040" .. r[R_ORANGE] .. "|r")
				end
				row.text:SetText(name)
				row.hl:SetShown(selectedRecipe == r)
			end
		end
	end
	Panel.empty:SetShown(#listEntries == 0)
end

local function Refresh()
	BuildList()
	UpdateList()
	UpdateDetail()
end

-- 상세 정보 --------------------------------------------------------------
local function TooltipLines(itemID)
	if not (C_TooltipInfo and C_TooltipInfo.GetItemByID) then return nil end
	local ok, data = pcall(C_TooltipInfo.GetItemByID, itemID)
	if not ok or not data or not data.lines then return nil end
	local out = {}
	for i = 2, #data.lines do
		local line = data.lines[i]
		local t = line.leftText
		if t and t ~= "" then
			local c = line.leftColor
			if c and c.GenerateHexColor then
				t = "|c" .. c:GenerateHexColor() .. t .. "|r"
			end
			out[#out + 1] = t
		end
	end
	return table.concat(out, "\n")
end

function UpdateDetail()
	local d = Panel.detail
	local r = selectedRecipe
	if not r then d:Hide() return end
	d:Show()
	d.icon.tex:SetTexture(RecipeIcon(r))
	d.name:SetText(QualityHex(r[R_ITEM]) .. RecipeName(r) .. "|r")
	local src = HasFlag(r, F_TRAINER) and L.trainer or L.book
	if learnedMode then
		if IsLearned(r) then
			src = "|cff40bf40" .. L.alreadyLearned .. "|r"
		elseif curSkill < r[R_ORANGE] then
			src = src .. "  |cffff2020(" .. L.needSkill:format(r[R_ORANGE]) .. ")|r"
		end
	end
	if HasFlag(r, F_NEW) then src = src .. "   |cff66ccff" .. L.newTag .. "|r" end
	d.source:SetText(src)

	local desc = RecipeDesc(r)
	if (not desc or desc == "") and r[R_ITEM] > 0 then
		desc = TooltipLines(r[R_ITEM])
		if C_Item and C_Item.RequestLoadItemDataByID then C_Item.RequestLoadItemDataByID(r[R_ITEM]) end
	end
	if not desc or desc == "" then desc = "|cff808080" .. L.hoverHint .. "|r" end
	d.desc:SetText(desc)

	d.skill:SetText(L.skill .. "  " .. SkillText(r))

	-- 배우는 곳 (판매 NPC 좌표, 드랍 지역, 퀘스트)
	local where = RecipeSrc(r)
	d.where:SetText(where)
	local wh = (where ~= "") and (d.where:GetStringHeight() or 0) or 0
	d.desc:SetHeight(math.max(50, (d.descBase or 170) - wh))
	if r[R_QTY] and r[R_QTY] > 1 then
		d.qty:SetText(L.makes:format(r[R_QTY]))
	else
		d.qty:SetText("")
	end

	for i, btn in ipairs(d.reagents) do
		local rg = r[R_REAG][i]
		if rg then
			local id, need = rg[1], rg[2]
			btn.itemID = id
			btn.tex:SetTexture(ItemIcon(id, nil))
			local have = GetItemCountFn(id, true) or 0
			local col = (have >= need) and "|cffffffff" or "|cff808080"
			btn.text:SetText(col .. have .. "/" .. need .. "|r  " .. QualityHex(id) .. ItemName(id) .. "|r")
			btn:Show()
		else
			btn:Hide()
		end
	end
end

-- 창 만들기 ---------------------------------------------------------------
local function ShowItemTooltip(owner, itemID, spellID)
	GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
	if itemID and itemID > 0 then
		GameTooltip:SetItemByID(itemID)
	elseif spellID then
		GameTooltip:SetSpellByID(spellID)
	end
	GameTooltip:Show()
end

local function LinkRecipe(r, itemID)
	local link
	if itemID and itemID > 0 then
		link = select(2, GetItemInfoFn(itemID))
	elseif r then
		link = (C_Spell and C_Spell.GetSpellLink and C_Spell.GetSpellLink(r[R_SPELL])) or (GetSpellLink and GetSpellLink(r[R_SPELL]))
	end
	if link then ChatEdit_InsertLink(link) end
end

local function CreateCheck(parent, label, key)
	local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	cb:SetSize(22, 22)
	local fs = cb.Text or cb.text
	if not fs then
		fs = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		fs:SetPoint("LEFT", cb, "RIGHT", 0, 1)
	end
	fs:SetFontObject("GameFontHighlightSmall")
	fs:SetText(L[label])
	cb.label, cb.labelKey = fs, label
	cb:SetScript("OnShow", function(self) self:SetChecked(DB[key]) end)
	cb:SetScript("OnClick", function(self)
		DB[key] = self:GetChecked() and true or false
		scrollOffset = 0
		Refresh()
	end)
	return cb
end

local function CreatePanel()
	local f, templated = CreateBackdropFrame(UIParent, "AllProfessionRecipesFrame")
	Panel = f
	f:SetSize(860, 600)
	f:SetFrameStrata("HIGH")
	f:SetToplevel(true)
	f:EnableMouse(true)
	f:Hide()
	if not templated then
		f.fallbackTitle = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		f.fallbackTitle:SetPoint("TOP", 0, -14)
	end
	f.CloseButton:SetScript("OnClick", function()
		f:Hide()
		if f.attached and ProfessionsFrame and ProfessionsFrame:IsShown() then
			HideUIPanel(ProfessionsFrame)
		end
	end)
	f:SetScript("OnHide", function()
		ns.UpdateTabChecks()
	end)

	-- 단독 창일 때 이동
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", function(self)
		if self.attached and ProfessionsFrame then
			-- 전문 기술 창 위에 붙어 있을 땐 전문 기술 창 자체를 옮김
			if not ProfessionsFrame:IsMovable() then ProfessionsFrame:SetMovable(true) end
			ProfessionsFrame:StartMoving()
			self.movingParent = true
		else
			self:StartMoving()
		end
	end)
	f:SetScript("OnDragStop", function(self)
		if self.movingParent then
			self.movingParent = nil
			if ProfessionsFrame then ProfessionsFrame:StopMovingOrSizing() end
			return
		end
		self:StopMovingOrSizing()
		if not self.attached then
			local p, _, rp, x, y = self:GetPoint()
			DB.standalonePos = { p, rp, x, y }
		end
	end)

	-- 숙련 막대 자리: 안내 문구
	local info = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	info:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 22, 9)
	f.info = info


	-- 왼쪽 목록 영역
	local left = CreateFrame("Frame", nil, f, "BackdropTemplate")
	left:SetPoint("TOPLEFT", 12, -62)
	left:SetPoint("BOTTOMLEFT", 12, 28)
	left:SetWidth(300)
	f.left = left
	left:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
	left:SetBackdropColor(0, 0, 0, 0.45)
	left:SetBackdropBorderColor(0.6, 0.5, 0.3, 1)

	local okSearch, search = pcall(CreateFrame, "EditBox", nil, f, "SearchBoxTemplate")
	if not okSearch then
		search = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
		search:SetAutoFocus(false)
	end
	search:SetSize(170, 20)
	search:SetPoint("BOTTOMLEFT", left, "TOPLEFT", 64, 4)
	if search.Instructions then search.Instructions:SetText(L.search) end
	search:HookScript("OnTextChanged", function() scrollOffset = 0; Refresh() end)
	f.search = search

	local cbNew = CreateCheck(f, "onlyNew", "onlyNew")
	cbNew:SetPoint("LEFT", search, "RIGHT", 8, 0)
	local cbCap = CreateCheck(f, "cap", "cap")
	cbCap:SetPoint("LEFT", cbNew, "RIGHT", 90, 0)
	local cbHide = CreateCheck(f, "hideLearned", "hideLearned")
	cbHide:SetPoint("LEFT", cbCap, "RIGHT", 100, 0)
	f.cbHide = cbHide
	f.checks = { cbNew, cbCap, cbHide }

	f.rows = {}
	for i = 1, NUM_ROWS do
		local row = CreateFrame("Button", nil, left)
		row:SetHeight(ROW_H)
		row:SetPoint("TOPLEFT", 6, -6 - (i - 1) * ROW_H)
		row:SetPoint("RIGHT", left, "RIGHT", -22, 0)
		row.headerBg = row:CreateTexture(nil, "BACKGROUND")
		row.headerBg:SetAllPoints()
		row.headerBg:SetColorTexture(0.35, 0.25, 0.1, 0.45)
		row.hl = row:CreateTexture(nil, "BACKGROUND")
		row.hl:SetAllPoints()
		row.hl:SetColorTexture(1, 0.82, 0, 0.25)
		row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
		row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.text:SetPoint("LEFT", 18, 0)
		row.text:SetPoint("RIGHT", row, "RIGHT", -34, 0)
		row.text:SetJustifyH("LEFT")
		row.text:SetWordWrap(false)
		row.right = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.right:SetPoint("RIGHT", -4, 0)
		row:RegisterForClicks("LeftButtonUp")
		row:SetScript("OnClick", function(self)
			local e = self.entry
			if not e then return end
			if e.header then
				DB.collapsed[currentProf] = DB.collapsed[currentProf] or {}
				local c = DB.collapsed[currentProf]
				c[e.cat] = not c[e.cat] or nil
				Refresh()
			else
				if IsModifiedClick("CHATLINK") then LinkRecipe(e.recipe, e.recipe[R_ITEM]) return end
				selectedRecipe = e.recipe
				UpdateList()
				UpdateDetail()
			end
		end)
		row:SetScript("OnEnter", function(self)
			local e = self.entry
			if e and e.recipe then ShowItemTooltip(self, e.recipe[R_ITEM], e.recipe[R_SPELL]) end
		end)
		row:SetScript("OnLeave", GameTooltip_Hide)
		f.rows[i] = row
	end

	local slider = CreateFrame("Slider", nil, left, "BackdropTemplate")
	slider:SetPoint("TOPRIGHT", -5, -8)
	slider:SetPoint("BOTTOMRIGHT", -5, 8)
	slider:SetWidth(12)
	slider:SetOrientation("VERTICAL")
	slider:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
	slider:SetBackdropColor(0, 0, 0, 0.5)
	slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
	slider:SetValueStep(1)
	slider:SetObeyStepOnDrag(true)
	slider:SetScript("OnValueChanged", function(_, v)
		v = math.floor(v + 0.5)
		if v ~= scrollOffset then scrollOffset = v; UpdateList() end
	end)
	f.slider = slider
	left:EnableMouseWheel(true)
	left:SetScript("OnMouseWheel", function(_, delta)
		scrollOffset = scrollOffset - delta * 3
		UpdateList()
	end)

	f.empty = left:CreateFontString(nil, "OVERLAY", "GameFontDisable")
	f.empty:SetPoint("CENTER")
	f.empty:SetText(L.noRecipes)

	-- 오른쪽 상세 영역
	local d = CreateFrame("Frame", nil, f, "BackdropTemplate")
	d:SetPoint("TOPLEFT", left, "TOPRIGHT", 8, 0)
	d:SetPoint("BOTTOMRIGHT", -12, 28)
	d:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
	d:SetBackdropColor(0, 0, 0, 0.35)
	d:SetBackdropBorderColor(0.6, 0.5, 0.3, 1)
	f.detail = d

	local icon = CreateFrame("Button", nil, d)
	icon:SetSize(48, 48)
	icon:SetPoint("TOPLEFT", 16, -16)
	icon.tex = icon:CreateTexture(nil, "ARTWORK")
	icon.tex:SetAllPoints()
	icon:SetScript("OnEnter", function(self)
		local r = selectedRecipe
		if r then ShowItemTooltip(self, r[R_ITEM], r[R_SPELL]) end
	end)
	icon:SetScript("OnLeave", GameTooltip_Hide)
	icon:SetScript("OnClick", function()
		local r = selectedRecipe
		if r and IsModifiedClick("CHATLINK") then LinkRecipe(r, r[R_ITEM]) end
	end)
	d.icon = icon

	d.name = d:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	d.name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, -4)
	d.name:SetPoint("RIGHT", d, "RIGHT", -16, 0)
	d.name:SetJustifyH("LEFT")

	d.source = d:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	d.source:SetPoint("TOPLEFT", d.name, "BOTTOMLEFT", 0, -6)
	d.source:SetPoint("RIGHT", d, "RIGHT", -16, 0)
	d.source:SetJustifyH("LEFT")

	d.skill = d:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	d.skill:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -12)

	d.qty = d:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	d.qty:SetPoint("LEFT", d.skill, "RIGHT", 24, 0)

	d.desc = d:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	d.where = d:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	d.where:SetPoint("TOPLEFT", d.skill, "BOTTOMLEFT", 0, -8)
	d.where:SetPoint("RIGHT", d, "RIGHT", -16, 0)
	d.where:SetJustifyH("LEFT")
	d.where:SetSpacing(2)

	d.desc:SetPoint("TOPLEFT", d.where, "BOTTOMLEFT", 0, -10)
	d.desc:SetPoint("RIGHT", d, "RIGHT", -16, 0)
	d.desc:SetJustifyH("LEFT")
	d.desc:SetJustifyV("TOP")
	d.desc:SetHeight(170)
	d.desc:SetSpacing(2)

	local rl = d:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	rl:SetPoint("TOPLEFT", d.desc, "BOTTOMLEFT", 0, -10)
	rl:SetText(L.reagents)
	f.reagentLabel = rl

	d.reagents = {}
	for i = 1, 8 do
		local b = CreateFrame("Button", nil, d)
		b:SetSize(230, 36)
		local col, rowi = (i - 1) % 2, math.floor((i - 1) / 2)
		b:SetPoint("TOPLEFT", rl, "BOTTOMLEFT", col * 245, -6 - rowi * 40)
		b.tex = b:CreateTexture(nil, "ARTWORK")
		b.tex:SetSize(34, 34)
		b.tex:SetPoint("LEFT")
		b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		b.text:SetPoint("LEFT", b.tex, "RIGHT", 6, 0)
		b.text:SetPoint("RIGHT", b, "RIGHT", 0, 0)
		b.text:SetJustifyH("LEFT")
		b:SetScript("OnEnter", function(self) ShowItemTooltip(self, self.itemID) end)
		b:SetScript("OnLeave", GameTooltip_Hide)
		b:SetScript("OnClick", function(self)
			if IsModifiedClick("CHATLINK") then LinkRecipe(nil, self.itemID) end
		end)
		d.reagents[i] = b
	end

	-- 창 크기에 맞춰 배치 (포에버 전문 기술 창은 단독 창보다 좁음)
	local function Relayout()
		local w = f:GetWidth() or 860
		if w <= 0 then return end
		local leftW = math.max(220, math.floor(w * 0.36))
		left:SetWidth(leftW)
		local dw = (d:GetWidth() or (w - leftW - 32)) - 32
		if dw <= 0 then dw = w - leftW - 64 end
		local twoCols = dw >= 380
		local bw = twoCols and math.floor((dw - 10) / 2) or dw
		for i, b in ipairs(d.reagents) do
			local col, rowi
			if twoCols then col, rowi = (i - 1) % 2, math.floor((i - 1) / 2) else col, rowi = 0, i - 1 end
			b:ClearAllPoints()
			b:SetSize(bw, twoCols and 36 or 30)
			b:SetPoint("TOPLEFT", rl, "BOTTOMLEFT", col * (bw + 10), -6 - rowi * (twoCols and 40 or 32))
		end
		d.descBase = twoCols and 170 or 120
		if f:IsShown() and selectedRecipe then UpdateDetail() end
	end
	f:HookScript("OnSizeChanged", Relayout)
	d:HookScript("OnSizeChanged", Relayout)
	f.Relayout = Relayout
	if f.SetClipsChildren then f:SetClipsChildren(true) end
	if d.SetClipsChildren then d:SetClipsChildren(true) end
	if left.SetClipsChildren then left:SetClipsChildren(true) end

	-- 아이템 정보가 늦게 도착하면 다시 그림
	f:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	f:RegisterEvent("BAG_UPDATE_DELAYED")
	f:SetScript("OnEvent", function(self)
		if not self:IsShown() then return end
		if self.pendingRefresh then return end
		self.pendingRefresh = true
		C_Timer.After(0.2, function()
			self.pendingRefresh = nil
			if self:IsShown() then UpdateList(); UpdateDetail() end
		end)
	end)

	table.insert(UISpecialFrames, "AllProfessionRecipesFrame")
end

-- 창을 전문 기술 창 위에 붙이거나 단독으로 띄움
local function AttachPanel()
	Panel:ClearAllPoints()
	if ProfessionsFrame and ProfessionsFrame:IsShown() then
		Panel.attached = true
		Panel:SetParent(ProfessionsFrame)
		Panel:SetAllPoints(ProfessionsFrame)
		Panel:SetFrameStrata("HIGH")
		Panel:SetFrameLevel(ProfessionsFrame:GetFrameLevel() + 40)
	else
		Panel.attached = false
		Panel:SetParent(UIParent)
		Panel:SetFrameStrata("HIGH")
		Panel:SetSize(860, 600)
		local pos = DB.standalonePos
		if pos then
			Panel:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4])
		else
			Panel:SetPoint("CENTER")
		end
	end
end

function ns.OpenProfession(skillLine, isLearned, skill)
	if not Panel then CreatePanel() end
	if not Data[skillLine] then return end
	isLearned = isLearned and true or false
	if isLearned then RefreshLearned(); curSkill = skill or 0 end
	if currentProf ~= skillLine or learnedMode ~= isLearned then
		learnedMode = isLearned
		currentProf = skillLine
		selectedRecipe = nil
		scrollOffset = 0
		Panel.search:SetText("")
	end
	local p = PROF_BY_ID[skillLine]
	AttachPanel()
	SetPanelTitle(ProfName(p) .. " |cff808080(" .. (learnedMode and L.missingTitle or L.notLearned) .. ")|r")
	Panel.cbHide:SetShown(learnedMode)
	SetPanelPortrait(p.icon)
	Panel.info:SetText(L.count:format(#Data[skillLine].recipes) .. "   |cffff8040■|r |cffffff00■|r |cff40bf40■|r |cff808080■|r")
	BuildList()
	if not selectedRecipe then
		for _, e in ipairs(listEntries) do
			if e.recipe then selectedRecipe = e.recipe break end
		end
	end
	Panel:Show()
	if Panel.Relayout then Panel.Relayout() end
	if ns.switcher then ns.switcher:SetShown(not Panel.attached) end
	UpdateList()
	UpdateDetail()
	ns.UpdateTabChecks()
end

-- 지금 열린(배운) 전문 기술의 안 배운 제조법 열기
function ns.OpenCurrent()
	local id, skill = CurrentTradeSkillLine()
	if not id then
		print("|cff66ccffAll Profession Recipes|r: " .. L.openProfFirst)
		return
	end
	ns.OpenProfession(id, true, skill)
end

------------------------------------------------------------------------
-- 전문 기술 창 옆 탭
------------------------------------------------------------------------
local tabs = {}
local nativeHooked = {}

local function NativeTabs()
	local out = {}
	if not ProfessionsFrame then return out end
	for _, key in ipairs({ "Overview", 1, 2, 3, 4, 5, 6, 7, 8, 9 }) do
		local t = ProfessionsFrame["Professions" .. key .. "Tab"]
		if type(t) == "table" and t.GetObjectType then out[#out + 1] = t end
	end
	return out
end

local function CreateTab(index)
	local ok, tab = pcall(CreateFrame, "Frame", nil, ProfessionsFrame, "QuestLogTabButtonTemplate")
	if not ok or not tab then
		tab = CreateFrame("Button", nil, ProfessionsFrame)
		tab:SetSize(36, 36)
		local bg = tab:CreateTexture(nil, "BACKGROUND")
		bg:SetPoint("TOPLEFT", -4, 4)
		bg:SetPoint("BOTTOMRIGHT", 4, -4)
		bg:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab")
		bg:SetTexCoord(0, 0.6, 0, 0.6)
		tab.Icon = tab:CreateTexture(nil, "ARTWORK")
		tab.Icon:SetAllPoints()
		tab.Selected = tab:CreateTexture(nil, "OVERLAY")
		tab.Selected:SetAllPoints()
		tab.Selected:SetTexture("Interface\\Buttons\\CheckButtonHilight")
		tab.Selected:SetBlendMode("ADD")
		tab:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
		tab.SetChecked = function(self, v) self.Selected:SetShown(v) end
	end
	tab:EnableMouse(true)
	tab.displayMode = nil
	local function onClick(self)
		if self.skillLine == -1 then
			ns.ToggleSettings()
		elseif self.skillLine == 0 then
			if Panel and Panel:IsShown() and learnedMode then Panel:Hide() else ns.OpenCurrent() end
		elseif Panel and Panel:IsShown() and currentProf == self.skillLine and not learnedMode then
			Panel:Hide()
		else
			ns.OpenProfession(self.skillLine)
		end
	end
	if tab.SetCustomOnMouseUpHandler then
		tab:SetCustomOnMouseUpHandler(function(self, button, upInside)
			if upInside == false then return end
			onClick(self)
		end)
	else
		tab:SetScript("OnMouseUp", function(self, button)
			if self:IsMouseOver() then onClick(self) end
		end)
	end
	tab:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if self.skillLine == -1 then
			GameTooltip:SetText(L.settingsTip, 1, 1, 1, 1, true)
		elseif self.skillLine == 0 then
			GameTooltip:SetText(L.currentTip, 1, 1, 1, 1, true)
		else
			GameTooltip:SetText(L.tabTip:format(ProfName(PROF_BY_ID[self.skillLine])), 1, 1, 1, 1, true)
		end
		GameTooltip:Show()
	end)
	tab:SetScript("OnLeave", GameTooltip_Hide)
	tabs[index] = tab
	return tab
end

local function MirrorPoint(pt)
	if not pt then return pt end
	return (pt:gsub("LEFT", "\001"):gsub("RIGHT", "LEFT"):gsub("\001", "RIGHT"))
end

-- 테두리를 뒤집으면 아이콘·무늬 위치도 반대로 옮겨야 가운데 맞음
-- 아이콘 위치: 템플릿이 누를 때/선택될 때 아이콘을 다시 배치하므로 매번 원래 위치(또는 대칭 위치)로 고정
local function PlaceTabIcon(tab, want)
	local icon = tab.Icon
	if not icon or not icon.GetNumPoints then return end
	if not icon.__aprPts then
		icon.__aprPts = {}
		for i = 1, (icon:GetNumPoints() or 0) do icon.__aprPts[i] = { icon:GetPoint(i) } end
		if #icon.__aprPts == 0 then icon.__aprPts[1] = { "CENTER", tab, "CENTER", 0, 0 } end
	end
	icon:ClearAllPoints()
	for _, pt in ipairs(icon.__aprPts) do
		local p, rel, rp, x, y = pt[1], pt[2], pt[3], pt[4] or 0, pt[5] or 0
		if want then
			icon:SetPoint(MirrorPoint(p), rel, MirrorPoint(rp), -x, y)
		else
			icon:SetPoint(p, rel, rp, x, y)
		end
	end
end

local function MirrorTabAnchors(tab, want)
	PlaceTabIcon(tab, want)
	if tab.__aprMirrored == want then return end
	local regions = { tab:GetRegions() }
	if tab.GetHighlightTexture then regions[#regions + 1] = tab:GetHighlightTexture() end
	for _, r in ipairs(regions) do
		if r and r ~= tab.Icon and r.GetNumPoints then
			if not r.__aprPts then
				r.__aprPts = {}
				for i = 1, (r:GetNumPoints() or 0) do r.__aprPts[i] = { r:GetPoint(i) } end
			end
			if #r.__aprPts > 0 then
				r:ClearAllPoints()
				for _, pt in ipairs(r.__aprPts) do
					local p, rel, rp, x, y = pt[1], pt[2], pt[3], pt[4] or 0, pt[5] or 0
					if want then
						r:SetPoint(MirrorPoint(p), rel, MirrorPoint(rp), -x, y)
					else
						r:SetPoint(p, rel, rp, x, y)
					end
				end
			end
		end
	end
	tab.__aprMirrored = want
end

-- 탭 테두리를 좌우로 뒤집기 (왼쪽에 붙일 때). 아이콘은 그대로.
local function ApplyTabFlip(tab)
	local want = (DB and DB.tabPos == "left") and true or false
	MirrorTabAnchors(tab, want)
	local regions = { tab:GetRegions() }
	if tab.GetHighlightTexture then regions[#regions + 1] = tab:GetHighlightTexture() end
	for _, r in ipairs(regions) do
		if r and r ~= tab.Icon and r.GetObjectType and r:GetObjectType() == "Texture" and r.GetTexCoord then
			local ulx, uly, llx, lly, urx, ury, lrx, lry = r:GetTexCoord()
			if ulx and urx then
				local flipped = ulx > urx
				if want ~= flipped then
					r:SetTexCoord(urx, ury, lrx, lry, ulx, uly, llx, lly)
				end
			end
		end
	end
end

local function HookTabFlip(tab)
	if tab.__aprFlipHooked then return end
	tab.__aprFlipHooked = true
	local function again() ApplyTabFlip(tab) end
	-- 템플릿이 상태에 따라 텍스처를 다시 입히므로 그때마다 다시 뒤집기
	if tab.SetChecked then hooksecurefunc(tab, "SetChecked", again) end
	for _, ev in ipairs({ "OnShow", "OnEnter", "OnLeave", "OnMouseDown", "OnMouseUp" }) do
		pcall(tab.HookScript, tab, ev, again)
	end
end

function ns.UpdateTabChecks()
	local shown = Panel and Panel:IsShown() and Panel.attached
	for _, tab in ipairs(tabs) do
		local on
		if tab.skillLine == -1 then on = ns.settingsFrame and ns.settingsFrame:IsShown()
		elseif tab.skillLine == 0 then on = shown and learnedMode else on = shown and not learnedMode and currentProf == tab.skillLine end
		if tab.SetChecked then tab:SetChecked(on and true or false) end
	end
end

local function HookNativeTab(t)
	if nativeHooked[t] then return end
	nativeHooked[t] = true
	local function hide() if Panel and Panel.attached then Panel:Hide() end end
	pcall(t.HookScript, t, "OnMouseDown", hide)
	pcall(t.HookScript, t, "OnMouseUp", hide)
	pcall(t.HookScript, t, "OnClick", hide)
end

-- 기존 탭(포에버 기본 탭, ATT 등 공유 사이드바) 중 가장 아래 것 찾기
local function LowestExistingTab()
	local lowest, lowestBottom
	local function consider(t)
		if t and t:IsShown() and t.GetBottom then
			local b = t:GetBottom()
			if b and (not lowestBottom or b < lowestBottom) then lowest, lowestBottom = t, b end
		end
	end
	for _, t in ipairs(NativeTabs()) do consider(t) end
	if ProfessionsFrameTabSideBar and ProfessionsFrameTabSideBar.Tabs then
		for _, t in pairs(ProfessionsFrameTabSideBar.Tabs) do consider(t) end
	end
	return lowest
end

local function TabStep()
	local a, b = ProfessionsFrame.ProfessionsOverviewTab, ProfessionsFrame.Professions1Tab
	if a and b and a:GetTop() and b:GetTop() then
		local s = a:GetTop() - b:GetTop()
		if s > 20 and s < 120 then return s end
	end
	return 50
end

local function LayoutTabs()
	if not ProfessionsFrame then return end
	for _, t in ipairs(NativeTabs()) do HookNativeTab(t) end

	local learned = GetLearnedSkillLines()
	-- 첫 탭: 지금 열린 전문 기술의 안 배운 제조법
	local wanted = { { id = 0, icon = "Interface\\Icons\\INV_Scroll_03" } }
	for _, p in ipairs(PROFESSIONS) do
		if not learned[p.id] and Data[p.id] then wanted[#wanted + 1] = p end
	end
	-- 마지막 탭: 설정
	wanted[#wanted + 1] = { id = -1, icon = "Interface\\Icons\\INV_Misc_Gear_01" }

	local anchor = LowestExistingTab()
	local step = TabStep()
	local frameBottom = ProfessionsFrame:GetBottom() or 0
	local topTab = ProfessionsFrame.ProfessionsOverviewTab
	if type(topTab) ~= "table" or not topTab.GetTop or not topTab:IsShown() then topTab = nil end

	-- 기존 탭 아래 남은 칸 수
	local below = 0
	if anchor and anchor:GetBottom() then
		below = math.floor((anchor:GetTop() - frameBottom) / step) - 1
	end
	local perCol = 99
	if topTab and topTab:GetTop() then
		perCol = math.max(1, math.floor((topTab:GetTop() - frameBottom) / step))
	end
	local useSideColumn = anchor and topTab and #wanted > below

	for i, p in ipairs(wanted) do
		local tab = tabs[i] or CreateTab(i)
		tab.skillLine = p.id
		if tab.Icon then
			tab.Icon:SetTexture(p.icon)
			-- 탭 테두리 안쪽을 꽉 채우는 크기 (24는 작고, 기본 탭 아이콘 크기는 넘침)
			local size = DB.iconSize or 30
			tab.Icon:SetSize(size, size)
			tab.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		end
		tab:ClearAllPoints()
		local w = (anchor and anchor:GetWidth()) or tab:GetWidth() or 40
		if DB.tabPos == "left" then
			-- 창 왼쪽 바깥에 세로로 (초상화 아래부터)
			local perLeft = math.max(1, math.floor(((ProfessionsFrame:GetHeight() or 600) - 80) / step))
			local col = math.floor((i - 1) / perLeft)
			local row = (i - 1) % perLeft
			tab:SetPoint("TOPRIGHT", ProfessionsFrame, "TOPLEFT", 2 - col * (w + 2), -70 - row * step)
		elseif DB.tabPos == "bottom" then
			-- 창 아래쪽에 가로로 나란히
			tab:SetPoint("TOPLEFT", ProfessionsFrame, "BOTTOMLEFT", 70 + (i - 1) * (w + 4), 2)
		elseif useSideColumn then
			-- 기본 탭 줄 바로 오른쪽에 세로로
			local col = 1 + math.floor((i - 1) / perCol)
			local row = (i - 1) % perCol
			tab:SetPoint("TOPLEFT", topTab, "TOPLEFT", col * (w + 2), -row * step)
		elseif anchor then
			tab:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, -i * step)
		else
			tab:SetPoint("TOPLEFT", ProfessionsFrame, "TOPRIGHT", 0, -60 - (i - 1) * step)
		end
		tab:Show()
		HookTabFlip(tab)
		ApplyTabFlip(tab)
	end
	for i = #wanted + 1, #tabs do tabs[i]:Hide() end
	ns.UpdateTabChecks()
end

local function OnProfessionsFrameReady()
	if not ProfessionsFrame or ProfessionsFrame.__aprHooked then return end
	ProfessionsFrame.__aprHooked = true
	ProfessionsFrame:HookScript("OnShow", function()
		-- 다른 애드온(ATT 등)이 탭을 배치한 다음에 배치
		C_Timer.After(0, LayoutTabs)
		C_Timer.After(0.3, LayoutTabs)
	end)
	ProfessionsFrame:HookScript("OnHide", function()
		if Panel and Panel.attached then Panel:Hide() end
	end)
	if ProfessionsFrame:IsShown() then C_Timer.After(0, LayoutTabs) end
end

------------------------------------------------------------------------
-- 이벤트
------------------------------------------------------------------------
local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("TRADE_SKILL_SHOW")
ev:RegisterEvent("SKILL_LINES_CHANGED")
ev:RegisterEvent("TRADE_SKILL_DATA_SOURCE_CHANGED")
pcall(ev.RegisterEvent, ev, "GLOBAL_MOUSE_DOWN")
ev:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 == ADDON then
			InitDB()
			if ns.RegisterBlizzardSettings then ns.RegisterBlizzardSettings() end
		elseif arg1 == "Blizzard_Professions" then
			OnProfessionsFrameReady()
		end
	elseif event == "PLAYER_LOGIN" then
		if ProfessionsFrame then OnProfessionsFrameReady() end
	elseif event == "TRADE_SKILL_SHOW" then
		OnProfessionsFrameReady()
		if Panel and Panel.attached then Panel:Hide() end
		C_Timer.After(0.1, LayoutTabs)
	elseif event == "TRADE_SKILL_DATA_SOURCE_CHANGED" then
		if Panel and Panel.attached then Panel:Hide() end
	elseif event == "GLOBAL_MOUSE_DOWN" then
		-- 포에버 기본 탭(또는 다른 애드온 탭)을 누르면 내 창 닫기
		if Panel and Panel:IsShown() and Panel.attached then
			local others = NativeTabs()
			if ProfessionsFrameTabSideBar and ProfessionsFrameTabSideBar.Tabs then
				for _, t in pairs(ProfessionsFrameTabSideBar.Tabs) do others[#others + 1] = t end
			end
			for _, t in ipairs(others) do
				if t:IsShown() and t:IsMouseOver() then Panel:Hide() break end
			end
		end
	elseif event == "SKILL_LINES_CHANGED" then
		if ProfessionsFrame and ProfessionsFrame:IsShown() then C_Timer.After(0.1, LayoutTabs) end
	end
end)

------------------------------------------------------------------------
-- 언어 바꾼 뒤 글자 다시 쓰기
------------------------------------------------------------------------
function ns.RefreshTexts()
	if Panel then
		if Panel.search.Instructions then Panel.search.Instructions:SetText(L.search) end
		for _, cb in ipairs(Panel.checks or {}) do cb.label:SetText(L[cb.labelKey]) end
		if Panel.reagentLabel then Panel.reagentLabel:SetText(L.reagents) end
		Panel.empty:SetText(L.noRecipes)
		if Panel:IsShown() and currentProf then ns.OpenProfession(currentProf, learnedMode, curSkill) end
	end
	if ns.settingsFrame then ns.settingsFrame:UpdateTexts() end
end

------------------------------------------------------------------------
-- 설정 창 (언어, 탭 위치, 아이콘 크기, 후원)
------------------------------------------------------------------------
StaticPopupDialogs["ALLPROFESSIONRECIPES_DONATE"] = {
	text = "%s",
	button1 = OKAY or "OK",
	hasEditBox = true,
	editBoxWidth = 280,
	OnShow = function(self)
		local eb = self.editBox or self.EditBox
		if eb then
			eb:SetText(DONATE_URL)
			eb:HighlightText()
			eb:SetFocus()
		end
	end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

local function ShowDonate()
	StaticPopup_Show("ALLPROFESSIONRECIPES_DONATE", L.donateText)
end

local function CreateRadioGroup(parent, items, getter, setter)
	local group = {}
	for i, it in ipairs(items) do
		local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
		cb:SetSize(22, 22)
		local fs = cb.Text or cb.text
		if not fs then
			fs = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			fs:SetPoint("LEFT", cb, "RIGHT", 0, 1)
		end
		fs:SetFontObject("GameFontHighlightSmall")
		cb.label, cb.value, cb.textKey = fs, it.value, it.textKey
		cb:SetScript("OnClick", function(self)
			setter(self.value)
			for _, o in ipairs(group) do o:SetChecked(o.value == getter()) end
		end)
		group[i] = cb
	end
	group.Refresh = function()
		for _, o in ipairs(group) do
			o:SetChecked(o.value == getter())
			o.label:SetText(L[o.textKey] or o.textKey)
		end
	end
	return group
end

local function CreateSettings()
	local okT, f = pcall(CreateFrame, "Frame", "AllProfessionRecipesSettings", UIParent, "BasicFrameTemplateWithInset")
	if not okT or not f then
		f = CreateFrame("Frame", "AllProfessionRecipesSettings", UIParent, "BackdropTemplate")
		f:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 } })
		local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT", -4, -4)
	end
	ns.settingsFrame = f
	f:SetSize(330, 330)
	f:SetPoint("CENTER")
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:Hide()
	f:SetScript("OnShow", function() f:UpdateTexts(); ns.UpdateTabChecks() end)
	f:SetScript("OnHide", function() ns.UpdateTabChecks() end)
	table.insert(UISpecialFrames, "AllProfessionRecipesSettings")

	local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOP", 0, -6)

	local langLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	langLabel:SetPoint("TOPLEFT", 18, -36)
	local lang = CreateRadioGroup(f, {
		{ value = "auto", textKey = "langAuto" }, { value = "ko", textKey = "langKo" }, { value = "en", textKey = "langEn" },
	}, function() return DB.lang end, function(v)
		DB.lang = v
		ApplyLanguage()
		ns.RefreshTexts()
	end)
	lang[1]:SetPoint("TOPLEFT", langLabel, "BOTTOMLEFT", 0, -4)
	lang[2]:SetPoint("TOPLEFT", lang[1], "BOTTOMLEFT", 0, 0)
	lang[3]:SetPoint("LEFT", lang[2], "RIGHT", 100, 0)
	local note = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	note:SetPoint("TOPLEFT", lang[2], "BOTTOMLEFT", 2, -2)
	note:SetPoint("RIGHT", f, "RIGHT", -18, 0)
	note:SetJustifyH("LEFT")

	local posLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	posLabel:SetPoint("TOPLEFT", note, "BOTTOMLEFT", -2, -14)
	local pos = CreateRadioGroup(f, {
		{ value = "left", textKey = "posLeftL" }, { value = "bottom", textKey = "posBottomL" }, { value = "side", textKey = "posRightL" },
	}, function() return DB.tabPos end, function(v)
		DB.tabPos = v
		LayoutTabs()
	end)
	pos[1]:SetPoint("TOPLEFT", posLabel, "BOTTOMLEFT", 0, -4)
	pos[2]:SetPoint("LEFT", pos[1], "RIGHT", 80, 0)
	pos[3]:SetPoint("LEFT", pos[2], "RIGHT", 80, 0)

	local sizeLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	sizeLabel:SetPoint("TOPLEFT", pos[1], "BOTTOMLEFT", 0, -14)
	local function sizeBtn(text, delta)
		local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
		b:SetSize(32, 22)
		b:SetText(text)
		b:SetScript("OnClick", function()
			DB.iconSize = math.max(16, math.min(48, (DB.iconSize or 30) + delta))
			LayoutTabs()
			f:UpdateTexts()
		end)
		return b
	end
	local minus = sizeBtn("-", -2)
	minus:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT", 0, -6)
	local plus = sizeBtn("+", 2)
	plus:SetPoint("LEFT", minus, "RIGHT", 6, 0)

	local donate = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	donate:SetSize(160, 26)
	donate:SetPoint("BOTTOM", 0, 18)
	donate:SetScript("OnClick", ShowDonate)
	local cup = donate:CreateTexture(nil, "OVERLAY")
	cup:SetSize(18, 18)
	cup:SetPoint("RIGHT", donate, "LEFT", -4, 0)
	cup:SetTexture("Interface\\Icons\\INV_Drink_04")

	function f:UpdateTexts()
		title:SetText("All Profession Recipes - " .. L.settings)
		langLabel:SetText(L.language)
		note:SetText(L.langNote)
		posLabel:SetText(L.tabPosLabel)
		sizeLabel:SetText(L.iconSizeLabel:format(DB.iconSize or 30))
		donate:SetText(L.donate)
		lang.Refresh()
		pos.Refresh()
	end
	return f
end

function ns.ToggleSettings()
	if not ns.settingsFrame then CreateSettings() end
	ns.settingsFrame:SetShown(not ns.settingsFrame:IsShown())
end

-- 게임 설정(ESC > 설정 > 애드온)에도 등록
local function RegisterBlizzardSettings()
	if not (Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory) then return end
	local canvas = CreateFrame("Frame")
	local t = canvas:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	t:SetPoint("TOPLEFT", 16, -16)
	t:SetText("All Profession Recipes")
	local b = CreateFrame("Button", nil, canvas, "UIPanelButtonTemplate")
	b:SetSize(180, 26)
	b:SetPoint("TOPLEFT", t, "BOTTOMLEFT", 0, -12)
	b:SetText(L.settings)
	b:SetScript("OnClick", function()
		if SettingsPanel and SettingsPanel:IsShown() then HideUIPanel(SettingsPanel) end
		if not ns.settingsFrame then CreateSettings() end
		ns.settingsFrame:Show()
	end)
	local d = CreateFrame("Button", nil, canvas, "UIPanelButtonTemplate")
	d:SetSize(180, 26)
	d:SetPoint("TOPLEFT", b, "BOTTOMLEFT", 0, -8)
	d:SetText(L.donate)
	d:SetScript("OnClick", ShowDonate)
	local ok, cat = pcall(Settings.RegisterCanvasLayoutCategory, canvas, "All Profession Recipes")
	if ok and cat then pcall(Settings.RegisterAddOnCategory, cat) end
end
ns.RegisterBlizzardSettings = RegisterBlizzardSettings

------------------------------------------------------------------------
-- 명령어
------------------------------------------------------------------------
SLASH_ALLPROFESSIONRECIPES1 = "/apr"
SLASH_ALLPROFESSIONRECIPES2 = "/전문기술"
SlashCmdList.ALLPROFESSIONRECIPES = function(msg)
	msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
	if msg == "reset" then
		AllProfessionRecipesDB = nil
		InitDB()
		print("|cff66ccffAll Profession Recipes|r: " .. L.resetDone)
		return
	elseif msg == "side" or msg == "bottom" or msg == "left" then
		DB.tabPos = msg
		LayoutTabs()
		local m = (msg == "side" and L.posSide) or (msg == "left" and L.posLeft) or L.posBottom
		print("|cff66ccffAll Profession Recipes|r: " .. m)
		return
	elseif msg == "config" or msg == "settings" or msg == "설정" then
		ns.ToggleSettings()
		return
	elseif msg:match("^icon%s+%d+$") then
		local n = tonumber(msg:match("%d+"))
		if n >= 16 and n <= 48 then
			DB.iconSize = n
			LayoutTabs()
			print("|cff66ccffAll Profession Recipes|r: icon " .. n)
		end
		return
	elseif msg == "help" or msg == "?" then
		print("|cff66ccffAll Profession Recipes|r: " .. L.help)
		return
	end
	-- 배우지 않은 첫 전문 기술로 열기
	local learned = GetLearnedSkillLines()
	local target = currentProf
	if not target then
		for _, p in ipairs(PROFESSIONS) do
			if not learned[p.id] then target = p.id break end
		end
	end
	target = target or 202
	if Panel and Panel:IsShown() and not Panel.attached then Panel:Hide() return end
	ns.OpenProfession(target)
	ns.ShowStandaloneSwitcher()
end

-- 단독 창에서 전문 기술 바꾸는 작은 아이콘 줄
local switcher
function ns.ShowStandaloneSwitcher()
	if not Panel then return end
	if not switcher then
		switcher = CreateFrame("Frame", nil, Panel)
		switcher:SetSize(1, 1)
		switcher:SetPoint("TOPLEFT", Panel, "TOPRIGHT", 2, -60)
		switcher.buttons = {}
		for i, p in ipairs(PROFESSIONS) do
			local b = CreateFrame("Button", nil, switcher)
			b:SetSize(32, 32)
			b:SetPoint("TOPLEFT", 0, -(i - 1) * 36)
			b:SetNormalTexture(p.icon)
			b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
			b:SetScript("OnClick", function() ns.OpenProfession(p.id) end)
			b:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(ProfName(p))
				GameTooltip:Show()
			end)
			b:SetScript("OnLeave", GameTooltip_Hide)
			switcher.buttons[i] = b
		end
		ns.switcher = switcher
	end
	switcher:SetShown(not Panel.attached)
end
