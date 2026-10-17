--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local world = workspace:WaitForChild("JunkyardLaunch")
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn = "JunkyardHUD", false
gui.Parent = player:WaitForChild("PlayerGui")
local card = Instance.new("Frame")
card.AnchorPoint, card.Position = Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 12)
card.Size, card.BackgroundColor3 = UDim2.new(0.9, 0, 0, 154), Color3.fromRGB(22, 35, 48)
card.BorderSizePixel, card.Parent = 0, gui
local bounds = Instance.new("UISizeConstraint")
bounds.MaxSize, bounds.Parent = Vector2.new(560, 154), card
local corner = Instance.new("UICorner")
corner.CornerRadius, corner.Parent = UDim.new(0, 16), card
local stroke = Instance.new("UIStroke")
stroke.Color, stroke.Transparency, stroke.Parent = Color3.fromRGB(71, 211, 179), 0.3, card
local function label(name: string, y: number, height: number, size: number, color: Color3): TextLabel
	local text = Instance.new("TextLabel")
	text.Name, text.BackgroundTransparency = name, 1
	text.Position, text.Size = UDim2.fromOffset(16, y), UDim2.new(1, -32, 0, height)
	text.Font, text.TextSize, text.TextColor3 = Enum.Font.GothamBold, size, color
	text.Parent = card
	return text
end
local title = label("Title", 10, 23, 18, Color3.fromRGB(255, 196, 77))
title.Text = "JUNKYARD LAUNCH"
local counters = label("Counters", 38, 30, 21, Color3.new(1, 1, 1))
counters.TextScaled = true
local counterBounds = Instance.new("UITextSizeConstraint")
counterBounds.MinTextSize, counterBounds.MaxTextSize, counterBounds.Parent = 12, 21, counters
local stage = label("Stage", 76, 22, 16, Color3.fromRGB(71, 211, 179))
local hint = label("Hint", 110, 34, 14, Color3.fromRGB(186, 205, 213))
hint.Font, hint.TextWrapped = Enum.Font.Gotham, true
local meter = Instance.new("Frame")
meter.Position, meter.Size = UDim2.fromOffset(16, 102), UDim2.new(1, -32, 0, 5)
meter.BorderSizePixel, meter.BackgroundColor3, meter.Parent = 0, Color3.fromRGB(55, 75, 88), card
local fill = Instance.new("Frame")
fill.Size, fill.BorderSizePixel, fill.BackgroundColor3, fill.Parent =
	UDim2.fromScale(0, 1), 0, Color3.fromRGB(71, 211, 179), meter
local currentTween: Tween? = nil
local function update()
	local amount = player:GetAttribute("Carried") or 0
	local capacity = player:GetAttribute("Capacity") or 12
	local total = world:GetAttribute("Deposited") or 0
	local count = world:GetAttribute("Stage") or 0
	counters.Text = string.format("CARRIED %d / %d     DEPOSITED %d", amount, capacity, total)
	stage.Text = if count == 5
		then "ROCKET COMPLETE!"
		else string.format("ROCKET CONSTRUCTION  %d / 5", count)
	hint.Text = if amount >= capacity
		then "Pack full! Return to the green deposit ring."
		elseif amount > 0 then "Keep collecting, or return to the green deposit ring."
		else "Walk through the scrap field. Your magnet collects nearby chunks."
	if currentTween then
		currentTween:Cancel()
	end
	currentTween = TweenService:Create(fill, TweenInfo.new(0.15), { Size = UDim2.fromScale(count / 5, 1) })
	currentTween:Play()
end
for _, name in { "Carried", "Capacity" } do
	player:GetAttributeChangedSignal(name):Connect(update)
end
for _, name in { "Deposited", "Stage" } do
	world:GetAttributeChangedSignal(name):Connect(update)
end
update()
