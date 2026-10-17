--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Config = require(game.ReplicatedStorage.Shared.Config)

assert(not workspace:FindFirstChild("JunkyardLaunch"), "Junkyard Launch is already running")
local world = Instance.new("Folder")
world.Name = "JunkyardLaunch"
world.Parent = workspace
local function part(
	parent: Instance,
	name: string,
	size: Vector3,
	frame: CFrame,
	color: Color3,
	solid: boolean
): Part
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame, p.Color = name, size, frame, color
	p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, solid, false, solid
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local navy = Color3.fromRGB(30, 43, 58)
local gold = Color3.fromRGB(255, 193, 64)
local teal = Color3.fromRGB(63, 214, 174)
part(world, "Yard", Vector3.new(110, 2, 140), CFrame.new(0, -1, -30), Color3.fromRGB(112, 116, 105), true)
part(world, "Launchpad", Vector3.new(52, 0.6, 34), CFrame.new(0, 0.3, 16), navy, true)
part(
	world,
	"ScrapField",
	Vector3.new(72, 0.15, 62),
	CFrame.new(0, 0.08, -43),
	Color3.fromRGB(83, 91, 91),
	false
)
local depositPosition = Vector3.new(8, 0.75, 17)
local deposit = part(
	world,
	"DepositZone",
	Vector3.new(0.3, 18, 18),
	CFrame.new(depositPosition) * CFrame.Angles(0, 0, math.pi / 2),
	teal,
	false
)
deposit.Shape, deposit.Material = Enum.PartType.Cylinder, Enum.Material.Neon
local spawn = Instance.new("SpawnLocation")
spawn.Name, spawn.Size, spawn.CFrame = "YardSpawn", Vector3.new(6, 0.3, 6), CFrame.new(8, 0.9, 29)
spawn.Anchored, spawn.CanCollide, spawn.Neutral = true, true, true
spawn.Transparency, spawn.Duration = 1, 0
spawn.Parent = world
local function sign(
	adornee: BasePart,
	title: string,
	offset: number,
	width: number,
	distance: number
): TextLabel
	local anchor = Instance.new("Attachment")
	anchor.Name = "LabelAnchor"
	anchor.Position = adornee.CFrame:PointToObjectSpace(adornee.Position + Vector3.new(0, offset, 0))
	anchor.Parent = adornee
	local gui = Instance.new("BillboardGui")
	gui.Name, gui.Size = "Sign", UDim2.fromOffset(width, 40)
	gui.MaxDistance = distance
	gui.Adornee, gui.Parent = anchor, adornee
	local text = Instance.new("TextLabel")
	text.Size, text.BackgroundTransparency = UDim2.fromScale(1, 1), 0.15
	text.BackgroundColor3, text.TextColor3 = navy, Color3.new(1, 1, 1)
	text.Font, text.TextSize, text.Text = Enum.Font.GothamBold, 18, title
	text.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius, corner.Parent = UDim.new(0, 12), text
	return text
end
sign(deposit, "DEPOSIT SCRAP", 7, 180, 40)
local fieldSign = part(world, "FieldSign", Vector3.new(1, 1, 1), CFrame.new(20, 1, -42), navy, false)
fieldSign.Transparency = 1
sign(fieldSign, "SCRAP FIELD", 5, 164, 64)

local rocket = Instance.new("Model")
rocket.Name, rocket.Parent = "Rocket", world
local base = CFrame.new(-16, 0.6, 16)
local stages: { { BasePart } } = {}
local function rocketPart(stage: number, name: string, size: Vector3, offset: CFrame, color: Color3): Part
	local p = part(rocket, name, size, base * offset, color, false)
	table.insert(stages[stage], p)
	return p
end
for i = 1, 5 do
	stages[i] = {}
end
local engine = rocketPart(
	1,
	"Engine",
	Vector3.new(3, 5, 5),
	CFrame.new(0, 1.5, 0) * CFrame.Angles(0, 0, math.pi / 2),
	navy
)
engine.Shape = Enum.PartType.Cylinder
for stage = 2, 3 do
	local hull = rocketPart(
		stage,
		"Hull" .. stage,
		Vector3.new(4, 5, 5),
		CFrame.new(0, 3 + (stage - 2) * 4, 0) * CFrame.Angles(0, 0, math.pi / 2),
		if stage == 2 then gold else Color3.fromRGB(232, 237, 225)
	)
	hull.Shape = Enum.PartType.Cylinder
end
for _, side in { -1, 1 } do
	rocketPart(
		4,
		"Fin",
		Vector3.new(2.5, 5, 1),
		CFrame.new(side * 3, 3, 0) * CFrame.Angles(0, 0, side * -0.25),
		teal
	)
	rocketPart(
		4,
		"Fin",
		Vector3.new(1, 5, 2.5),
		CFrame.new(0, 3, side * 3) * CFrame.Angles(side * 0.25, 0, 0),
		teal
	)
end
local nose = rocketPart(5, "Nose", Vector3.new(4.8, 5, 4.8), CFrame.new(0, 10.5, 0), gold)
nose.Shape = Enum.PartType.Ball
part(world, "RocketBase", Vector3.new(13, 0.4, 13), base, Color3.fromRGB(59, 75, 90), true)
rocket.WorldPivot = base
local rocketSign = sign(engine, "BUILD 0 / 5", 17, 144, 34)
local deposited, buildScrap, completed = 0, 0, 0
local readyAt: number? = nil
local function renderRocket()
	local stage = math.min(5, math.floor(buildScrap / Config.StageCost))
	for i, pieces in stages do
		for _, p in pieces do
			p.Transparency = if i <= stage then 0 else 0.9
		end
	end
	world:SetAttribute("Stage", stage)
	world:SetAttribute("BuildScrap", buildScrap)
	world:SetAttribute("Deposited", deposited)
	world:SetAttribute("Completed", completed)
	rocketSign.Text = if stage == 5 then "READY!" else string.format("BUILD %d / 5", stage)
	if stage == 5 and not readyAt then
		readyAt = os.clock() + Config.ReadySeconds
	end
end
renderRocket()

type Scrap = { model: Model, home: CFrame, readyAt: number, collectedAt: number, collector: Player? }
local scraps: { Scrap } = {}
local colors = { gold, Color3.fromRGB(160, 188, 197), Color3.fromRGB(209, 112, 72) }
for row = 1, 4 do
	for column = 1, 6 do
		local model = Instance.new("Model")
		model.Name, model.Parent = "Scrap", world
		local home = CFrame.new((column - 3.5) * 10, 1.4, -18 - row * 11)
			* CFrame.Angles(0, (column + row) * 0.7, 0)
		part(model, "Chunk", Vector3.new(2.7, 1.5, 2.1), home, colors[(row + column) % 3 + 1], false)
		part(
			model,
			"BentPlate",
			Vector3.new(2.2, 0.5, 2),
			home * CFrame.new(0.4, 0.8, 0) * CFrame.Angles(0, 0, 0.4),
			navy,
			false
		)
		model.WorldPivot = home
		table.insert(scraps, { model = model, home = home, readyAt = 0, collectedAt = 0, collector = nil })
	end
end
local carried: { [Player]: number } = {}
local function addPlayer(player: Player)
	carried[player] = 0
	player.RespawnLocation = spawn
	player:SetAttribute("Carried", 0)
	player:SetAttribute("Capacity", Config.Capacity)
	player.CharacterAdded:Connect(function(character)
		carried[player] = 0
		player:SetAttribute("Carried", 0)
		local root = character:WaitForChild("HumanoidRootPart", 10)
		if root and player.Parent == Players then
			character:PivotTo(CFrame.new(8, 4, 29))
		end
	end)
end
Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(function(player)
	carried[player] = nil
end)
for _, player in Players:GetPlayers() do
	addPlayer(player)
end

local accumulator = 0
RunService.Heartbeat:Connect(function(dt)
	accumulator += dt
	if accumulator < 0.1 then
		return
	end
	accumulator = 0
	local now = os.clock()
	local roots: { [Player]: BasePart } = {}
	for player, amount in carried do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if root and root:IsA("BasePart") and humanoid and humanoid.Health > 0 then
			roots[player] = root
			if amount > 0 and (root.Position - depositPosition).Magnitude <= Config.DepositRadius then
				carried[player] = 0
				player:SetAttribute("Carried", 0)
				deposited += amount
				buildScrap += amount
				renderRocket()
			end
		end
	end
	for _, scrap in scraps do
		if now >= scrap.readyAt then
			if scrap.collector then
				scrap.model:PivotTo(scrap.home)
				for _, p in scrap.model:GetChildren() do
					if p:IsA("BasePart") then
						p.Transparency = 0
					end
				end
				scrap.collector = nil
			end
			local nearest: Player? = nil
			local distance = Config.MagnetRadius
			for player, root in roots do
				local gap = (root.Position - scrap.home.Position).Magnitude
				if (carried[player] or 0) < Config.Capacity and gap < distance then
					nearest, distance = player, gap
				end
			end
			if nearest then
				-- Claim availability before the award; no client requests or touched races.
				scrap.readyAt, scrap.collectedAt, scrap.collector = now + Config.RespawnSeconds, now, nearest
				carried[nearest] = (carried[nearest] or 0) + 1
				nearest:SetAttribute("Carried", carried[nearest])
			end
		elseif scrap.collector then
			local root = roots[scrap.collector]
			local alpha = math.clamp((now - scrap.collectedAt) / 0.2, 0, 1)
			if root then
				scrap.model:PivotTo(scrap.home:Lerp(root.CFrame, alpha))
			end
			for _, p in scrap.model:GetChildren() do
				if p:IsA("BasePart") then
					p.Transparency = alpha
				end
			end
		end
	end
	if readyAt then
		rocket:PivotTo(base * CFrame.new(0, math.max(0, 2 - (readyAt - now)) * 20, 0))
		if now >= readyAt then
			completed += 1
			buildScrap -= Config.StageCost * 5
			readyAt = nil
			rocket:PivotTo(base)
			renderRocket()
		end
	end
end)
