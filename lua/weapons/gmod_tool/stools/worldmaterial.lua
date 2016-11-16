if CLIENT then
	language.Add("tool.worldmaterial.name", "World Material Tool")
	language.Add("tool.worldmaterial.desc", "Override any given non-displacement map texture!")
	language.Add("tool.worldmaterial.left", "Override the current texture.")
	language.Add("tool.worldmaterial.right", "Copy the current texture")
	language.Add("tool.worldmaterial.reload", "Reset the current maptexture")
	language.Add("tool.worldmaterial.e", "Change mode")
end

TOOL.Category = "Render"
TOOL.Name = "World Material"
TOOL.ClientConVar["override"] = "debug/env_cubemap_model"
TOOL.ClientConVar["1_r"] = "255"
TOOL.ClientConVar["1_g"] = "255"
TOOL.ClientConVar["1_b"] = "255"
TOOL.ClientConVar["2_r"] = "255"
TOOL.ClientConVar["2_g"] = "255"
TOOL.ClientConVar["2_b"] = "255"
TOOL.ClientConVar["basetexture_copy"] = "1"
TOOL.ClientConVar["basetexture_reset"] = "1"
TOOL.ClientConVar["basetexture_set"] = "1"

TOOL.Information = {
	{
		name = "left"
	},
	{
		name = "right"
	},
	{
		name = "reload"
	},
	{
		name = "e",
		icon = "gui/e.png"
	}
}

local function Ticked(pl, str, action)
	if SERVER then return pl:GetInfoNum("worldmaterial_" .. str .. "_" .. action, 0) == 1 or false end

	return GetConVar("worldmaterial_" .. str .. "_" .. action):GetInt() == 1 or false
end

function TOOL:LeftClick(trace)
	if CLIENT then return true end

	if Ticked(self:GetOwner(), "basetexture", "set") then
		WorldMaterials:Set(trace, self:GetOwner():GetInfo("worldmaterial_override"), "$basetexture", self:GetOwner())
	end
end

-- Right click copies the material
function TOOL:RightClick(trace)
	if SERVER then return end

	if trace.HitTexture ~= "**displacement**" then
		if Ticked(self:GetOwner(), "basetexture", "copy") then
			GetConVar("worldmaterial_override"):SetString(Material(trace.HitTexture):GetString("$basetexture"))
			chat.AddText(Color(255, 128, 0), "Copied basetexture " .. GetConVar("worldmaterial_override"):GetString())
		end
	end
end

-- Reload reverts the material
function TOOL:Reload(trace)
	if CLIENT then return end

	if Ticked(self:GetOwner(), "basetexture", "reset") then
		WorldMaterials:Restore(trace, "$basetexture", self:GetOwner())
	end
	

	return true
end

function TOOL.BuildCPanel(CPanel)
	CPanel.vars = {
		["$basetexture"] = "basetexture",
	}

	WorldMaterialBuildPanel(CPanel)
end

TOOL.BackupMaterial = Material("debug/debugwhite")

if CLIENT then
	TOOL.CurrentActiveMaterial = Material(GetConVarString("worldmaterial_override"))
	TOOL.CurrentMat = GetConVarString("worldmaterial_override")
end

function TOOL:DrawToolScreen(width, height)
	if self.CurrentMat ~= GetConVarString("worldmaterial_override") then
		self.CurrentActiveMaterial = Material(GetConVarString("worldmaterial_override"))
		self.CurrentMat = GetConVarString("worldmaterial_override")
	end

	surface.SetDrawColor(Color(255, 255, 255))
	surface.DrawRect(0, 0, width, height)
	surface.SetMaterial(self.CurrentActiveMaterial or self.BackupMaterial)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0, 0, width, height)
end

if SERVER then return end
local w, h = ScrW(), ScrH()
TOOL.ColorA = Color(76, 78, 96, 150)
TOOL.ColorB = Color(249, 118, 76)

function TOOL:DrawHUD()
	draw.RoundedBox(0, w - 5 - w / 5, 5, w / 5, 300, self.ColorA)
	draw.RoundedBox(0, w - 5 - w / 5, 5, w / 5, 25, self.ColorB)
end