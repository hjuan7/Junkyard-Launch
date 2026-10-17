--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Config = require(game.ReplicatedStorage.Shared.Config)
local player = Players.LocalPlayer
local world = workspace:WaitForChild("JunkyardLaunch")
local white = Color3.fromRGB(242, 248, 249)
local gold = Color3.fromRGB(255, 207, 91)
local teal = Color3.fromRGB(71, 211, 179)
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn = "JunkyardHUD", false
gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
gui.Parent = player:WaitForChild("PlayerGui")
local card = Instance.new("Frame")
card.Name = "Card"
card.AnchorPoint, card.Position = Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 8)
card.Size, card.BackgroundColor3 = UDim2.new(0.9, 0, 0, 146), Color3.fromRGB(22, 35, 48)
card.BorderSizePixel, card.Parent = 0, gui
local bounds = Instance.new("UISizeConstraint")
bounds.MaxSize, bounds.Parent = Vector2.new(520, 146), card
local corner = Instance.new("UICorner")
corner.CornerRadius, corner.Parent = UDim.new(0, 16), card
local stroke = Instance.new("UIStroke")
stroke.Color, stroke.Transparency, stroke.Parent = teal, 0.3, card
local function label(name: string, y: number, height: number, size: number, color: Color3): TextLabel
	local text = Instance.new("TextLabel")
	text.Name, text.BackgroundTransparency = name, 1
	text.Position, text.Size = UDim2.fromOffset(14, y), UDim2.new(1, -28, 0, height)
	text.Font, text.TextSize, text.TextColor3 = Enum.Font.GothamBold, size, color
	text.Parent = card
	return text
end
local title = label("Title", 8, 20, 16, gold)
title.Text = "JUNKYARD LAUNCH"
local carriedLabel = label("Carried", 32, 28, 20, white)
local depositedLabel = label("Deposited", 32, 28, 18, teal)
carriedLabel.Size, depositedLabel.Size = UDim2.new(0.5, -21, 0, 28), UDim2.new(0.5, -21, 0, 28)
depositedLabel.Position = UDim2.new(0.5, 7, 0, 32)
local stage = label("Stage", 67, 20, 15, teal)
local hint = label("Hint", 106, 32, 14, Color3.fromRGB(207, 222, 229))
hint.Font, hint.TextWrapped = Enum.Font.Gotham, true
local meter = Instance.new("Frame")
meter.Position, meter.Size = UDim2.fromOffset(14, 94), UDim2.new(1, -28, 0, 6)
meter.BorderSizePixel, meter.BackgroundColor3, meter.Parent = 0, Color3.fromRGB(55, 75, 88), card
local fill = Instance.new("Frame")
fill.Size, fill.BorderSizePixel, fill.BackgroundColor3, fill.Parent = UDim2.fromScale(0, 1), 0, teal, meter
for _, frame in { meter, fill } do
	local rounding = Instance.new("UICorner")
	rounding.CornerRadius, rounding.Parent = UDim.new(1, 0), frame
end
-- Reuse one highlight and one ring; no per-pickup effects or delayed tasks accumulate.
local highlight = Instance.new("Highlight")
highlight.Name, highlight.Adornee = "ConstructionFlash", world:WaitForChild("Rocket")
highlight.DepthMode = Enum.HighlightDepthMode.Occluded
highlight.FillColor, highlight.OutlineColor = gold, gold
highlight.FillTransparency, highlight.OutlineTransparency, highlight.Parent = 1, 1, gui
local ring = world:WaitForChild("DepositZone"):Clone()
ring:ClearAllChildren()
ring.Name, ring.Transparency = "DepositPulse", 1
ring.CanCollide, ring.CanTouch, ring.CanQuery = false, false, false
ring.Parent = workspace
local ringSize = ring.Size
local fillTween: Tween? = nil
local flashTween: Tween? = nil
local ringTween: Tween? = nil
local notice, noticeUntil = "", 0
local lastAmount = player:GetAttribute("Carried") or 0
local lastStage = world:GetAttribute("Stage") or 0
local lastCompleted = world:GetAttribute("Completed") or 0
local launchSeenAt = 0
local function message(text: string)
	notice, noticeUntil = text, os.clock() + 1.8
end
local function updateHint()
	local amount = player:GetAttribute("Carried") or 0
	local capacity = player:GetAttribute("Capacity") or Config.Capacity
	local count = world:GetAttribute("Stage") or 0
	hint.Text = if count == 5
		then "ROCKET COMPLETE! Launching — keep collecting."
		elseif amount >= capacity then "PACK FULL! Return to the green deposit ring."
		elseif os.clock() < noticeUntil then notice
		elseif amount > 0 then "Collect more, or walk into the green ring to deposit."
		else "Follow the gold arrows. Walk near scrap to collect."
end
local function update()
	local amount = player:GetAttribute("Carried") or 0
	local capacity = player:GetAttribute("Capacity") or Config.Capacity
	local total = world:GetAttribute("Deposited") or 0
	local count = world:GetAttribute("Stage") or 0
	local completed = world:GetAttribute("Completed") or 0
	carriedLabel.Text = if amount >= capacity
		then string.format("FULL  %d / %d", amount, capacity)
		else string.format("PACK  %d / %d", amount, capacity)
	depositedLabel.Text = string.format("DEPOSITED  %d", total)
	carriedLabel.TextColor3 = if amount >= capacity or amount > lastAmount then gold else white
	stroke.Color = if amount >= capacity then gold else teal
	stage.Text = if count == 5
		then "5 / 5  •  READY TO LAUNCH"
		elseif count == 0 then "BUILD  0 / 5  •  ENGINE NEXT"
		else string.format("BUILD  %d / 5  •  %s", count, Config.StageNames[count])
	if count > lastStage then
		if flashTween then
			flashTween:Cancel()
		end
		highlight.FillTransparency, highlight.OutlineTransparency = 0.5, 0.1
		flashTween = TweenService:Create(
			highlight,
			TweenInfo.new(0.8),
			{ FillTransparency = 1, OutlineTransparency = 1 }
		)
		flashTween:Play()
		message("STAGE BUILT! " .. Config.StageNames[count])
		if count == 5 then
			launchSeenAt = os.clock()
		end
	end
	if completed > lastCompleted then
		message("ROCKET LAUNCHED! Build the next one.")
	end
	if fillTween then
		fillTween:Cancel()
	end
	fillTween = TweenService:Create(fill, TweenInfo.new(0.2), { Size = UDim2.fromScale(count / 5, 1) })
	fillTween:Play()
	lastAmount, lastStage, lastCompleted = amount, count, completed
	updateHint()
end
player:GetAttributeChangedSignal("DepositSerial"):Connect(function()
	message(string.format("+%d SCRAP DEPOSITED", player:GetAttribute("LastDepositAmount") or 0))
	if ringTween then
		ringTween:Cancel()
	end
	ring.Size, ring.Transparency = ringSize, 0.25
	ringTween = TweenService:Create(
		ring,
		TweenInfo.new(0.65),
		{ Size = ringSize + Vector3.new(0, 6, 6), Transparency = 1 }
	)
	ringTween:Play()
	updateHint()
end)
for _, name in { "Carried", "Capacity" } do
	player:GetAttributeChangedSignal(name):Connect(update)
end
for _, name in { "Deposited", "Stage", "Completed" } do
	world:GetAttributeChangedSignal(name):Connect(update)
end
local function layout()
	local viewport = workspace.CurrentCamera.ViewportSize
	local compact = viewport.Y < 500 or viewport.X < 600
	local bottom = compact and viewport.X > viewport.Y
	card.AnchorPoint = Vector2.new(0.5, if bottom then 1 else 0)
	card.Position = if bottom then UDim2.new(0.5, 0, 1, -8) else UDim2.new(0.5, 0, 0, 8)
	hint.Size = UDim2.new(1, -28, 0, if compact then 24 else 32)
	local height = if compact then 88 else 146
	card.Size = UDim2.new(if bottom then 0.6 else 0.9, 0, 0, height)
	bounds.MaxSize = Vector2.new(if bottom then 360 else 520, height)
	title.Visible = not compact
	title.TextSize = 16
	carriedLabel.Position = UDim2.fromOffset(14, if compact then 0 else 32)
	depositedLabel.Position = UDim2.new(0.5, 7, 0, if compact then 0 else 32)
	carriedLabel.TextSize, depositedLabel.TextSize = if compact then 16 else 20, if compact then 14 else 18
	stage.Position, stage.TextSize =
		UDim2.fromOffset(14, if compact then 28 else 67), if compact then 13 else 15
	meter.Position = UDim2.fromOffset(14, if compact then 50 else 94)
	hint.Position, hint.TextSize =
		UDim2.fromOffset(14, if compact then 56 else 106), if compact then 12 else 14
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(layout)
local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
	elapsed += dt
	if elapsed < 0.1 then
		return
	end
	elapsed = 0
	if (world:GetAttribute("Stage") or 0) == 5 then
		local seconds = math.max(0, math.ceil(Config.ReadySeconds - (os.clock() - launchSeenAt)))
		stage.Text = string.format("5 / 5  •  LAUNCH IN %ds", seconds)
	end
	updateHint()
end)
layout()
update()
