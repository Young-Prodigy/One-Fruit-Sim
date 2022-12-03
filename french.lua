if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
local Window = Rayfield:CreateWindow({
	Name = "One Fruit Simulator Unreleased Script",
	LoadingTitle = "Private Script",
	LoadingSubtitle = "Tate Hub Productions",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = nil, -- Create a custom folder for your hub/game
		FileName = "Big Ol D Hub"
	},
	Discord = {
		Enabled = false,
		Invite = "nrgVRjz7k9", -- The Discord invite code, do not include discord.gg/
		RememberJoins = true -- Set this to false to make them join the discord every time they load it up
	},
	KeySystem = true, -- Set this to true to use our key system
	KeySettings = {
		Title = "Sirius Hub",
		Subtitle = "Key System",
		Note = "Join the discord (discord.gg/nrgVRjz7k9)",
		FileName = "SiriusKey",
		SaveKey = true,
		GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
		Key = "TopG"
	}
})

local Client = game.Players.LocalPlayer
local ReplicatedStorage = game.ReplicatedStorage
local Mobs = workspace["__GAME"]["__Mobs"]

local Bridge = require(ReplicatedStorage.BridgeNet)
local ToolNet = Bridge.CreateBridge("TOOL_EVENT")
local AttackNet = Bridge.CreateBridge("ATTACK_EVENT")
local RemoteNet = Bridge.CreateBridge("REMOTE_EVENT")

local Settings = {
	AutoPunch = false,
	SelectedEnemy = nil,
}

local EnemyTable = {} --Create a table called EnemyTable
for _, v in pairs(Mobs:GetChildren()) do --For every child in Mobs
	for _, enemy in pairs(v:GetChildren()) do --For every child in the child
		if enemy:FindFirstChild("NpcConfiguration") then --If the child has a child called NpcConfiguration
			if not table.find(EnemyTable, enemy.NpcConfiguration:GetAttribute("Name")) then --If the table does not already have an entry for the enemy
				table.insert(EnemyTable, enemy.NpcConfiguration:GetAttribute("Name")) --Add the enemy to the table
			end
		end
	end
end

local function RemoveTableDupes(tab)
	local hash = {}
	local res = {}
	for _, v in ipairs(tab) do
		if not hash[v] then
			res[#res + 1] = v
			hash[v] = true
		end
	end
	return res
end

local outputtedEnemies = RemoveTableDupes(EnemyTable)

--ToolNet:Fire("Combat", 1, false, Client.Character.Combat, "Melee")
--ToolNet:Fire("Defence", Client.Character.Defence, "Defence")
--AttackNet:Fire(getClosestMob(), Client.Character.Combat)

local function getClosestMob(name)
	local closest, maxDist = nil, 9e9
	for _, v in pairs(Mobs:GetChildren()) do
		for _, mob in pairs(v:GetChildren()) do
			if mob:FindFirstChild("NpcConfiguration") and mob.NpcConfiguration:GetAttribute("Health") > 0 then
				if mob.NpcConfiguration:GetAttribute("Name") == name then
					local dist = (mob.PrimaryPart.Position - Client.Character.PrimaryPart.Position).magnitude
					if dist < maxDist then
						maxDist = dist
						closest = mob
					end
				end
			end
		end
	end
	return closest
end

--[[
1. The function takes in a string parameter which is the name of the mob you want to get the closest one of
2. It then creates two variables, closest and maxDist. The closest variable is the closest mob to the player and maxDist is the maximum distance between the player and the closest mob
3. It then loops through all of the mobs in the game and checks if they are valid enemies (have a NpcConfiguration and their health is greater than 0)
4. If the mob is a valid enemy, it checks if the mob's name matches the name parameter
5. If the mob's name matches the name parameter, it checks if the mob is closer to the player than the previous closest mob. If it is, it sets the closest variable to the mob and the maxDist variable to the distance between the mob and the player
6. Once the loop is done, it returns the closest mob 
]]

local function getWeapon()
	local weapon = Client.Character:FindFirstChildOfClass("Tool")
	if weapon and weapon:GetAttribute("Type") ~= "Defence" then
		return weapon
	end
end

local function getFruit()
	local fruit = Client.Character:FindFirstChildOfClass("Tool")
	if fruit and fruit:GetAttribute("Type") == "Fruit" then
		return fruit
	end
end

-- check if new mobs are spawned and if they arent in the table, add them
Mobs.ChildAdded:Connect(function(child)
	for _, v in pairs(child:GetChildren()) do
		if v:FindFirstChild("NpcConfiguration") then
			if not table.find(EnemyTable, v.NpcConfiguration:GetAttribute("Name")) then
				table.insert(EnemyTable, v.NpcConfiguration:GetAttribute("Name"))
			end
		end
	end
end)

local Functions = {}
do
	function Functions.AutoFarm()
		while true do
			task.wait()
			if Settings.AutoFarm then
				pcall(function()
					local weapon = getWeapon()
					local enemy = getClosestMob(Settings.SelectedEnemy)
					if weapon and enemy then
						Client.Character:PivotTo(enemy.PrimaryPart.CFrame * CFrame.new(0, 10, 20))
						wait(1)
						AttackNet:Fire(enemy, weapon)
					end
				end)
			end
		end
	end

function Alltools()
    while true do
        task.wait()
        for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetChildren()) do
            if v:IsA("Tool") or v:IsA("HopperBin") then
                v.Parent = speaker.Character
            end
        end
    end
end
loadstring(game:HttpGet("https://raw.githubusercontent.com/Young-Prodigy/One-Fruit-Sim/main/One%20Fruit%20Sim.lua"))()

local Tab = Window:CreateTab("Main", 4483362458) -- Title, Image

Tab:CreateToggle({
	Name = "Auto Farm",
	CurrentValue = false,
	Callback = function(Value)
		Settings.AutoFarm = Value
	end,
})

Tab:CreateDropdown({
	Name = "Select Enemy",
	Options = outputtedEnemies,
	CurrentOption = "CLICK ME",
	Callback = function(Option)
		Settings.SelectedEnemy = Option
	end,
})

Tab:CreateButton({
	Name = "Remove Effects for suna",
	Callback = function()
        game:GetService("ReplicatedStorage").Game["__Extra"].Vfx.Suna:Destroy()
	end,
})

Tab:CreateButton({
	Name = "Remove Effects for Mera",
	Callback = function()
        game:GetService("ReplicatedStorage").Game["__Assets"].SkillAssets["Mera Mera no Mi"]:Destroy()
	end,
})

Tab:CreateButton({
	Name = "Remove Effects for Pika",
	Callback = function()
        game:GetService("ReplicatedStorage").Game["__Extra"].Vfx.Light:Destroy()
	end,
})

for _, v in pairs(Functions) do
	task.spawn(v)
end
end
