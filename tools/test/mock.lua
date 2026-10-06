-- 간단한 WoW API 모의 환경
local timers = {}
C_Timer = { After = function(t, fn) table.insert(timers, fn) end }
function RunTimers() local n = 0 while #timers > 0 and n < 100 do local fn = table.remove(timers, 1); fn(); n = n + 1 end end
bit = { band = function(a, b) local r, p = 0, 1 while a > 0 and b > 0 do if a % 2 == 1 and b % 2 == 1 then r = r + p end a = math.floor(a/2); b = math.floor(b/2); p = p * 2 end return r end }
function wipe(t) for k in pairs(t) do t[k] = nil end return t end
function GetLocale() return "koKR" end
UISpecialFrames = {}
ITEM_QUALITY_COLORS = { [0]={hex="|cff9d9d9d"},[1]={hex="|cffffffff"},[2]={hex="|cff1eff00"},[3]={hex="|cff0070dd"},[4]={hex="|cffa335ee"} }
local allFrames = {}
local Frame = {}
Frame.__index = function(self, k)
  local v = rawget(Frame, k); if v then return v end
  if type(k) == "string" and (k:match("^Set") or k:match("^Get") or k:match("^Register") or k:match("^Enable") or k:match("^Clear") or k:match("^Start") or k:match("^Stop") or k:match("^Is")) then
    return function() return nil end
  end
  return nil
end
local function new(kind, name, parent, template)
  local f = setmetatable({ _kind = kind, _shown = true, _scripts = {}, _w = 10, _h = 10, _parent = parent, _template = template }, Frame)
  if template and template:find("PortraitFrameTemplate") then f.CloseButton = new("Button", nil, f) end
  if template and template:find("CheckButton") then f.Text = new("FontString") end
  if name then _G[name] = f end
  table.insert(allFrames, f)
  return f
end
function Frame:CreateTexture() return new("Texture") end
function Frame:CreateFontString() local fs = new("FontString"); return fs end
function Frame:SetText(t) self._text = t end
function Frame:GetText() return self._text or "" end
function Frame:Show() local was = self._shown; self._shown = true; if not was and self._scripts.OnShow then self._scripts.OnShow(self) end end
function Frame:Hide() local was = self._shown; self._shown = false; if was and self._scripts.OnHide then self._scripts.OnHide(self) end end
function Frame:SetShown(v) if v then self:Show() else self:Hide() end end
function Frame:IsShown() return self._shown end
function Frame:IsVisible() return self._shown end
function Frame:SetScript(n, fn) self._scripts[n] = fn end
function Frame:GetScript(n) return self._scripts[n] end
function Frame:HookScript(n, fn) local old = self._scripts[n]; self._scripts[n] = function(...) if old then old(...) end fn(...) end end
function Frame:SetSize(w, h) self._w, self._h = w, h end
function Frame:GetSize() return self._w, self._h end
function Frame:GetWidth() return self._w end
function Frame:GetHeight() return self._h end
function Frame:SetHeight(h) self._h = h end
function Frame:SetWidth(w) self._w = w end
function Frame:GetTop() return self._top end
function Frame:GetBottom() return self._top and (self._top - self._h) end
function Frame:GetLeft() return 0 end
function Frame:GetFrameLevel() return 5 end
function Frame:GetFrameStrata() return "MEDIUM" end
function Frame:GetChecked() return self._checked end
function Frame:SetChecked(v) self._checked = v end
function Frame:GetPoint() return "CENTER", nil, "CENTER", 0, 0 end
function Frame:IsMouseOver() return true end
function Frame:GetObjectType() return self._kind end
function Frame:HighlightText() end
function Frame:SetFocus() end
function Frame:Click(btn) if self._scripts.OnClick then self._scripts.OnClick(self, btn or "LeftButton") end end
function CreateFrame(kind, name, parent, template)
  if template == "QuestLogTabButtonTemplate" then
    local f = new(kind, name, parent, template)
    f.Icon = new("Texture")
    function f:SetCustomOnMouseUpHandler(fn) self._custom = fn end
    return f
  end
  return new(kind, name, parent, template)
end
function SetPortraitToTexture() end
function hooksecurefunc(t, name, fn) local old = t[name]; t[name] = function(...) local r = {old(...)}; fn(...); return unpack(r) end end
function Frame:GetRegions() if not self._regs then local t = new("Texture"); t._tc = {0,0,0,1,1,0,1,1}; self._regs = {t} end return unpack(self._regs) end
function Frame:GetTexCoord() return unpack(self._tc or {0,0,0,1,1,0,1,1}) end
function Frame:SetTexCoord(...) self._tc = {...} end
function GameTooltip_Hide() end
GameTooltip = new("GameTooltip")
function IsModifiedClick() return false end
function ChatEdit_InsertLink() end
function HideUIPanel(f) f:Hide() end
C_Item = {
  GetItemNameByID = function(id) if id % 2 == 0 then return "아이템" .. id end end,
  GetItemIconByID = function(id) return 1000 + id end,
  GetItemQualityByID = function(id) return 1 end,
  GetItemCount = function(id) return 1 end,
  GetItemInfo = function(id) return "x", "link" end,
  RequestLoadItemDataByID = function() end,
}
C_TooltipInfo = { GetItemByID = function(id) return { lines = { {leftText="이름"}, {leftText="머리"}, {leftText="방어도 10", leftColor={GenerateHexColor=function() return "ffffffff" end}} } } end }
C_Spell = { GetSpellTexture = function() return 1 end, GetSpellLink = function() return "slink" end }
function GetProfessions() return 1, 2, nil, 4, 5, 6 end
local profs = { [1]=182, [2]=393, [4]=356, [5]=185, [6]=129 }
function GetProfessionInfo(i) return "n", 0, 1, 1, 0, 0, profs[i] end
function IsPlayerSpell(id) return id == 3273 end
SlashCmdList = {}
StaticPopupDialogs = {}
function StaticPopup_Show(name, text) local d = StaticPopupDialogs[name]; local popup = new("Frame"); popup.editBox = new("EditBox"); d.OnShow(popup); print("popup", text, popup.editBox._text) end
Settings = { RegisterCanvasLayoutCategory = function(c, n) return {n=n} end, RegisterAddOnCategory = function(c) print("settings registered", c.n) end }
C_TradeSkillUI = {
  GetBaseProfessionInfo = function() return { professionID = 185, professionName = "요리", skillLevel = 225 } end,
  GetAllRecipeIDs = function() return { 2538, 2540 } end,
  GetRecipeInfo = function(id) return { learned = true } end,
}
return allFrames
