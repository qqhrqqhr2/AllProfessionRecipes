local dir, testDir = ...
local allFrames = dofile((testDir or "tools/test") .. "/mock.lua")
local ns = {}
for _, f in ipairs({"Data.lua", "Core.lua"}) do
  local fn = assert(loadfile(dir .. "/" .. f))
  fn("AllProfessionRecipes", ns)
end
local function fire(event, ...)
  for _, f in ipairs(allFrames) do
    if f._scripts.OnEvent then f._scripts.OnEvent(f, event, ...) end
  end
end
fire("ADDON_LOADED", "AllProfessionRecipes")
fire("PLAYER_LOGIN")
-- 포에버 전문 기술 창 흉내
ProfessionsFrame = CreateFrame("Frame", nil, nil)
ProfessionsFrame._top, ProfessionsFrame._h = 700, 600
local keys = {"Overview",1,2,3,4,5,6,7}
for i, k in ipairs(keys) do
  local t = CreateFrame("Frame", nil, ProfessionsFrame)
  t._w, t._h, t._top = 44, 44, 650 - (i-1)*52
  t._shown = i <= 6
  ProfessionsFrame["Professions"..k.."Tab"] = t
end
ProfessionsFrame._shown = false
fire("ADDON_LOADED", "Blizzard_Professions")
ProfessionsFrame:Show()
RunTimers()
fire("TRADE_SKILL_SHOW")
RunTimers()
-- 생성된 탭 찾기
local tabs = {}
for _, f in ipairs(allFrames) do if rawget(f, "_custom") then tabs[#tabs+1] = f end end
print("tabs", #tabs)
for _, t in ipairs(tabs) do print(" tab", t.skillLine, t._shown) end
-- 기계공학 탭 클릭
for _, t in ipairs(tabs) do if t.skillLine == 202 then t._custom(t, "LeftButton", true) end end
local P = AllProfessionRecipesFrame
print("panel shown", P:IsShown(), "attached", P.attached)
local shownRows = 0
for _, r in ipairs(P.rows) do if r:IsShown() then shownRows = shownRows + 1 end end
print("rows", shownRows, P.rows[1]._text and P.rows[1].text._text, P.rows[2].text._text)
print("detail", P.detail.name._text, P.detail.skill._text)
print("desc", P.detail.desc._text)
print("reag1", P.detail.reagents[1].text._text)
-- 헤더 접기
P.rows[1]._scripts.OnClick(P.rows[1])
print("after collapse row2", P.rows[2].text._text)
-- 검색
P.search:SetText("고글"); P.search._scripts.OnTextChanged(P.search)
print("search rows", P.rows[1].text._text, P.rows[2].text._text)
P.search:SetText(""); P.search._scripts.OnTextChanged(P.search)
-- 2번째 줄 레시피 클릭
P.rows[3]._scripts.OnClick(P.rows[3])
print("selected", P.detail.name._text)
-- 스크롤
P.rows[1]:GetParent()
-- 모든 전문 기술 열어 보기
for _, id in ipairs({171,164,333,202,165,197,186,185,129}) do ns.OpenProfession(id); print("open", id, P.rows[1].text._text, P.detail.name._text) end
-- 단독 모드
ProfessionsFrame:Hide()
SlashCmdList.ALLPROFESSIONRECIPES("")
print("standalone", P:IsShown(), P.attached)
SlashCmdList.ALLPROFESSIONRECIPES("reset")
print("done")
-- 기본 탭 클릭 시 닫히는지
ProfessionsFrame:Show(); RunTimers()
ns.OpenProfession(202)
print("before native click", UnlearnedPanelCheck, AllProfessionRecipesFrame:IsShown(), AllProfessionRecipesFrame.attached)
for _, f in ipairs(allFrames) do if f._scripts.OnEvent then f._scripts.OnEvent(f, "GLOBAL_MOUSE_DOWN", "LeftButton") end end
print("after native click", AllProfessionRecipesFrame:IsShown())
for _, f in ipairs(allFrames) do if rawget(f,"_custom") then local p = f._points print(" tab", f.skillLine) end end
SlashCmdList.ALLPROFESSIONRECIPES("side")
SlashCmdList.ALLPROFESSIONRECIPES("bottom")
print("pos", AllProfessionRecipesDB.tabPos)
SlashCmdList.ALLPROFESSIONRECIPES("left") print("pos", AllProfessionRecipesDB.tabPos)
for _, f in ipairs(allFrames) do if rawget(f,"_custom") and f._shown then local r = f:GetRegions(); print("flip", f.skillLine, r:GetTexCoord()) break end end
SlashCmdList.ALLPROFESSIONRECIPES("side")
for _, f in ipairs(allFrames) do if rawget(f,"_custom") and f._shown then local r = f:GetRegions(); print("unflip", f.skillLine, r:GetTexCoord()) break end end
SlashCmdList.ALLPROFESSIONRECIPES("icon 28") print("icon", AllProfessionRecipesDB.iconSize)
ProfessionsFrame:Show(); RunTimers()
for _, f in ipairs(allFrames) do if rawget(f,"_custom") and f.skillLine == 0 then f._custom(f, "LeftButton", true) end end
local P = AllProfessionRecipesFrame
print("learned mode shown", P:IsShown(), P.cbHide:IsShown())
for i = 1, 5 do print(" row", P.rows[i].text._text, P.rows[i].right._text) end
print(" src", P.detail.source._text)
P.cbHide._checked = false; P.cbHide._scripts.OnClick(P.cbHide)
local cnt=0 for i=1,26 do local t=P.rows[i].text._text if t and t:find("배움") then cnt=cnt+1 end end
print("learned visible rows", cnt)
for _, f in ipairs(allFrames) do if rawget(f,"_custom") and f.skillLine == 202 then f._custom(f, "LeftButton", true) end end
print("back to engineering", P.cbHide:IsShown())
-- 설정 탭
for _, f in ipairs(allFrames) do if rawget(f,"_custom") and f.skillLine == -1 then f._custom(f, "LeftButton", true) end end
local S = AllProfessionRecipesSettings
print("settings shown", S:IsShown())
-- 언어 영어로
local radios = {}
for _, f in ipairs(allFrames) do if rawget(f, "value") == "en" then f._scripts.OnClick(f) end end
print("lang", AllProfessionRecipesDB.lang)
ns.OpenProfession(202)
print("title rows EN", AllProfessionRecipesFrame.rows[2].text._text, AllProfessionRecipesFrame.detail.reagents[1].text._text)
for _, f in ipairs(allFrames) do if rawget(f, "value") == "auto" then f._scripts.OnClick(f) end end
print("rows KO", AllProfessionRecipesFrame.rows[2].text._text)
-- 후원
for _, f in ipairs(allFrames) do if f._scripts.OnClick and f._text == "후원하기" then f._scripts.OnClick(f) break end end
ProfessionsFrame:Show(); ns.OpenProfession(202)
local P = AllProfessionRecipesFrame
local moved = false
ProfessionsFrame.StartMoving = function() moved = true end
P._scripts.OnDragStart(P); P._scripts.OnDragStop(P)
print("drag moves professions frame", P.attached, moved)
-- 배우는 곳 / 채집 기술
ns.OpenProfession(171)
local P = AllProfessionRecipesFrame
P.search:SetText("하급 정신력"); P.search._scripts.OnTextChanged(P.search)
P.rows[2]._scripts.OnClick(P.rows[2])
print("where", P.detail.name._text, P.detail.where._text)
P.search:SetText(""); P.search._scripts.OnTextChanged(P.search)
ns.OpenProfession(182, true, 120)
print("herb missing", P.rows[1].text._text, P.rows[2].text._text, P.rows[2].right._text)
