--=============================================================
--  脚本中心 GUI（双页面：公告 / 功能）
--  纯客户端脚本，可直接放到 StarterPlayerScripts 或执行器运行
--  快捷键：RightShift 显示/隐藏界面
--=============================================================

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

--========================= 基础工具 =========================

local function new(className, props)
	local inst = Instance.new(className)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	return inst
end

local function getHumanoid()
	local char = LocalPlayer.Character
	if not char then return nil end
	return char:FindFirstChildOfClass("Humanoid")
end

--========================= 主题配色 =========================

local Theme = {
	Background = Color3.fromRGB(22, 22, 28),
	Panel      = Color3.fromRGB(30, 30, 38),
	Card       = Color3.fromRGB(38, 38, 48),
	Accent     = Color3.fromRGB(88, 101, 242),
	Text       = Color3.fromRGB(240, 240, 245),
	SubText    = Color3.fromRGB(160, 160, 175),
	Stroke     = Color3.fromRGB(52, 52, 64),
	Green      = Color3.fromRGB(60, 200, 120),
}
--========================= 用户配置 =========================

local CONFIG = {
	Title     = "脚本中心",
	Subtitle  = "v1.0  |  按 RightShift 开关界面",
	ToggleKey = Enum.KeyCode.RightShift,

	-- 公告页内容（可随意增删）
	Announcements = {
		{
			Title   = "欢迎使用脚本中心",
			Date    = "2025-01-01",
			Content = "这是第一条公告。你可以在脚本的 CONFIG.Announcements 表里自由添加、修改公告内容。",
		},
		{
			Title   = "功能页已上线",
			Date    = "2025-01-02",
			Content = "切换到「功能」页面即可开启加速、无限跳跃、全亮等实用功能，所有功能均为本地生效。",
		},
		{
			Title   = "使用提示",
			Date    = "2025-01-03",
			Content = "部分功能在角色重生后需要重新应用，脚本已自动处理，无需手动操作。",
		},
	},
}

--========================= 功能定义 =========================

local featureStates = {}

local infJumpEnabled  = false
local lightingBackup  = nil

-- 无限跳跃监听（只创建一次）
UserInputService.JumpRequest:Connect(function()
	if not infJumpEnabled then return end
	local hum = getHumanoid()
	if hum and hum.Health > 0 then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

local Features = {
	{
		Name = "加速",
		Desc = "行走速度提升至 32",
		Callback = function(on)
			local hum = getHumanoid()
			if hum then
				hum.WalkSpeed = on and 32 or 16
			end
		end,
	},
	{
		Name = "高跳",
		Desc = "跳跃力提升至 80",
		Callback = function(on)
			local hum = getHumanoid()
			if hum then
				hum.UseJumpPower = true
				hum.JumpPower = on and 80 or 50
			end
		end,
	},
	{
		Name = "无限跳跃",
		Desc = "空中可反复跳跃",
		Callback = function(on)
			infJumpEnabled = on
		end,
	},
	{
		Name = "全亮视野",
		Desc = "提高亮度，去除雾气",
		Callback = function(on)
			if on then
				if not lightingBackup then
					lightingBackup = {
						Brightness     = Lighting.Brightness,
						Ambient        = Lighting.Ambient,
						OutdoorAmbient = Lighting.OutdoorAmbient,
						ClockTime      = Lighting.ClockTime,
						FogEnd         = Lighting.FogEnd,
					}
				end
				Lighting.Brightness     = 3
				Lighting.Ambient        = Color3.fromRGB(178, 178, 178)
				Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
				Lighting.ClockTime      = 14
				Lighting.FogEnd         = 100000
			else
				if lightingBackup then
					Lighting.Brightness     = lightingBackup.Brightness
					Lighting.Ambient        = lightingBackup.Ambient
					Lighting.OutdoorAmbient = lightingBackup.OutdoorAmbient
					Lighting.ClockTime      = lightingBackup.ClockTime
					Lighting.FogEnd         = lightingBackup.FogEnd
					lightingBackup = nil
				end
			end
		end,
	},
}

for _, f in ipairs(Features) do
	featureStates[f.Name] = false
end
--========================= 清理旧界面 =========================

local oldGui = PlayerGui:FindFirstChild("ScriptHubGui")
if oldGui then
	oldGui:Destroy()
end

--========================= 创建主界面 =========================

local screenGui = new("ScreenGui", {
	Name           = "ScriptHubGui",
	ResetOnSpawn   = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder   = 100,
	Parent         = PlayerGui,
})

local main = new("Frame", {
	Name             = "Main",
	AnchorPoint      = Vector2.new(0.5, 0.5),
	Position         = UDim2.fromScale(0.5, 0.5),
	Size             = UDim2.fromOffset(520, 340),
	BackgroundColor3 = Theme.Background,
	BorderSizePixel  = 0,
	Parent           = screenGui,
})
new("UICorner", { CornerRadius = UDim.new(0, 12), Parent = main })
new("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = main })

--========================= 标题栏 =========================

local titleBar = new("Frame", {
	Name                 = "TitleBar",
	Size                 = UDim2.new(1, 0, 0, 56),
	BackgroundTransparency = 1,
	Parent               = main,
})

new("TextLabel", {
	Name              = "Title",
	Position          = UDim2.fromOffset(18, 12),
	Size              = UDim2.fromOffset(300, 22),
	BackgroundTransparency = 1,
	Font              = Enum.Font.GothamBold,
	Text              = CONFIG.Title,
	TextColor3        = Theme.Text,
	TextSize          = 18,
	TextXAlignment    = Enum.TextXAlignment.Left,
	Parent            = titleBar,
})

new("TextLabel", {
	Name              = "Subtitle",
	Position          = UDim2.fromOffset(18, 33),
	Size              = UDim2.fromOffset(320, 14),
	BackgroundTransparency = 1,
	Font              = Enum.Font.Gotham,
	Text              = CONFIG.Subtitle,
	TextColor3        = Theme.SubText,
	TextSize          = 11,
	TextXAlignment    = Enum.TextXAlignment.Left,
	Parent            = titleBar,
})

local closeBtn = new("TextButton", {
	Name             = "Close",
	AnchorPoint      = Vector2.new(1, 0),
	Position         = UDim2.new(1, -14, 0, 14),
	Size             = UDim2.fromOffset(30, 30),
	BackgroundColor3 = Theme.Card,
	Text             = "×",
	TextColor3       = Theme.SubText,
	TextSize         = 20,
	Font             = Enum.Font.GothamBold,
	AutoButtonColor  = false,
	Parent           = titleBar,
})
new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = closeBtn })

closeBtn.MouseEnter:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(200, 60, 60),
		TextColor3 = Color3.fromRGB(255, 255, 255),
	}):Play()
end)
closeBtn.MouseLeave:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.15), {
		BackgroundColor3 = Theme.Card,
		TextColor3 = Theme.SubText,
	}):Play()
end)
closeBtn.MouseButton1Click:Connect(function()
	main.Visible = false
end)

--========================= 标签栏 =========================

local tabBar = new("Frame", {
	Name             = "TabBar",
	Position         = UDim2.fromOffset(12, 64),
	Size             = UDim2.new(1, -24, 0, 36),
	BackgroundColor3 = Theme.Panel,
	BorderSizePixel  = 0,
	Parent           = main,
})
new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = tabBar })

local tabButtons = {}
local tabNames = { "公告", "功能" }

for i, name in ipairs(tabNames) do
	local btn = new("TextButton", {
		Name                 = "Tab" .. i,
		Position             = (i == 1) and UDim2.fromOffset(4, 4) or UDim2.new(0.5, 2, 0, 4),
		Size                 = UDim2.new(0.5, -6, 1, -8),
		BackgroundColor3     = Theme.Accent,
		BackgroundTransparency = 1,
		Text                 = name,
		Font                 = Enum.Font.GothamMedium,
		TextSize             = 14,
		TextColor3           = Theme.SubText,
		AutoButtonColor      = false,
		Parent               = tabBar,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
	tabButtons[i] = btn
end
--========================= 内容容器 =========================

local content = new("Frame", {
	Name                 = "Content",
	Position             = UDim2.fromOffset(12, 108),
	Size                 = UDim2.new(1, -24, 1, -120),
	BackgroundTransparency = 1,
	Parent               = main,
})

--========================= 页面一：公告 =========================

local annPage = new("ScrollingFrame", {
	Name                 = "Announcements",
	Size                 = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel      = 0,
	ScrollBarThickness   = 4,
	ScrollBarImageColor3 = Theme.Accent,
	CanvasSize           = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize  = Enum.AutomaticSize.Y,
	Parent               = content,
})
new("UIListLayout", {
	Padding    = UDim.new(0, 8),
	SortOrder  = Enum.SortOrder.LayoutOrder,
	Parent     = annPage,
})
new("UIPadding", {
	PaddingRight = UDim.new(0, 8),
	Parent       = annPage,
})

for i, data in ipairs(CONFIG.Announcements) do
	local card = new("Frame", {
		Name             = "Ann" .. i,
		LayoutOrder      = i,
		Size             = UDim2.new(1, 0, 0, 76),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel  = 0,
		Parent           = annPage,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = card })
	new("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = card })

	local bar = new("Frame", {
		Position         = UDim2.fromOffset(10, 10),
		Size             = UDim2.new(0, 3, 1, -20),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel  = 0,
		Parent           = card,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })

	new("TextLabel", {
		Position           = UDim2.fromOffset(22, 10),
		Size               = UDim2.new(1, -110, 0, 18),
		BackgroundTransparency = 1,
		Font               = Enum.Font.GothamBold,
		TextSize           = 14,
		TextColor3         = Theme.Text,
		TextXAlignment     = Enum.TextXAlignment.Left,
		Text               = data.Title,
		Parent             = card,
	})

	new("TextLabel", {
		AnchorPoint        = Vector2.new(1, 0),
		Position           = UDim2.new(1, -12, 0, 11),
		Size               = UDim2.fromOffset(80, 16),
		BackgroundTransparency = 1,
		Font               = Enum.Font.Gotham,
		TextSize           = 11,
		TextColor3         = Theme.SubText,
		TextXAlignment     = Enum.TextXAlignment.Right,
		Text               = data.Date,
		Parent             = card,
	})

	new("TextLabel", {
		Position           = UDim2.fromOffset(22, 32),
		Size               = UDim2.new(1, -36, 0, 36),
		BackgroundTransparency = 1,
		Font               = Enum.Font.Gotham,
		TextSize           = 12,
		TextColor3         = Theme.SubText,
		TextXAlignment     = Enum.TextXAlignment.Left,
		TextYAlignment     = Enum.TextYAlignment.Top,
		TextWrapped        = true,
		Text               = data.Content,
		Parent             = card,
	})
end

--========================= 开关组件 =========================

local function createToggle(parent, initial, onChange)
	local state = initial and true or false

	local track = new("TextButton", {
		Name             = "Toggle",
		AnchorPoint      = Vector2.new(0, 0.5),
		Position         = UDim2.new(1, -58, 0.5, 0),
		Size             = UDim2.fromOffset(44, 24),
		BackgroundColor3 = state and Theme.Green or Theme.Stroke,
		Text             = "",
		AutoButtonColor  = false,
		Parent           = parent,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

	local knob = new("Frame", {
		Name             = "Knob",
		AnchorPoint      = Vector2.new(0, 0.5),
		Position         = state and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		Size             = UDim2.fromOffset(18, 18),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel  = 0,
		Parent           = track,
	})
	new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

	local function render()
		TweenService:Create(track, TweenInfo.new(0.15), {
			BackgroundColor3 = state and Theme.Green or Theme.Stroke,
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.15), {
			Position = state and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		}):Play()
	end

	track.MouseButton1Click:Connect(function()
		state = not state
		render()
		onChange(state)
	end)

	return track
end
--========================= 页面二：功能 =========================

local featPage = new("ScrollingFrame", {
	Name                 = "Features",
	Size                 = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel      = 0,
	ScrollBarThickness   = 4,
	ScrollBarImageColor3 = Theme.Accent,
	CanvasSize           = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize  = Enum.AutomaticSize.Y,
	Visible              = false,
	Parent               = content,
})
new("UIListLayout", {
	Padding   = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent    = featPage,
})
new("UIPadding", {
	PaddingRight = UDim.new(0, 8),
	Parent       = featPage,
})

for i, feature in ipairs(Features) do
	local row = new("Frame", {
		Name             = "Feat" .. i,
		LayoutOrder      = i,
		Size             = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel  = 0,
		Parent           = featPage,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = row })
	new("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = row })

	new("TextLabel", {
		Position           = UDim2.fromOffset(14, 9),
		Size               = UDim2.new(1, -90, 0, 18),
		BackgroundTransparency = 1,
		Font               = Enum.Font.GothamMedium,
		TextSize           = 14,
		TextColor3         = Theme.Text,
		TextXAlignment     = Enum.TextXAlignment.Left,
		Text               = feature.Name,
		Parent             = row,
	})

	new("TextLabel", {
		Position           = UDim2.fromOffset(14, 29),
		Size               = UDim2.new(1, -90, 0, 16),
		BackgroundTransparency = 1,
		Font               = Enum.Font.Gotham,
		TextSize           = 11,
		TextColor3         = Theme.SubText,
		TextXAlignment     = Enum.TextXAlignment.Left,
		Text               = feature.Desc,
		Parent             = row,
	})

	createToggle(row, featureStates[feature.Name], function(state)
		featureStates[feature.Name] = state
		local ok, err = pcall(feature.Callback, state)
		if not ok then
			warn("[脚本中心] 功能执行失败：" .. tostring(err))
		end
	end)
end

--========================= 页面切换 =========================

local pages = { annPage, featPage }

local function selectTab(index)
	for i, page in ipairs(pages) do
		page.Visible = (i == index)
	end
	for i, btn in ipairs(tabButtons) do
		local active = (i == index)
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundTransparency = active and 0 or 1,
			TextColor3 = active and Color3.fromRGB(255, 255, 255) or Theme.SubText,
		}):Play()
	end
end

for i, btn in ipairs(tabButtons) do
	btn.MouseButton1Click:Connect(function()
		selectTab(i)
	end)
end

selectTab(1)
--========================= 窗口拖动 =========================

do
	local dragging, dragInput, dragStart, startPos

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging  = true
			dragStart = input.Position
			startPos  = main.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	titleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

--========================= 浮动打开按钮 =========================

local fab = new("TextButton", {
	Name             = "OpenButton",
	AnchorPoint      = Vector2.new(1, 1),
	Position         = UDim2.new(1, -20, 1, -20),
	Size             = UDim2.fromOffset(46, 46),
	BackgroundColor3 = Theme.Accent,
	Text             = "⚙",
	TextSize         = 22,
	TextColor3       = Color3.fromRGB(255, 255, 255),
	Font             = Enum.Font.GothamBold,
	AutoButtonColor  = false,
	Parent           = screenGui,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fab })
fab.MouseButton1Click:Connect(function()
	main.Visible = true
end)

--========================= 快捷键开关 =========================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == CONFIG.ToggleKey then
		main.Visible = not main.Visible
	end
end)

--========================= 角色重生后自动恢复功能 =========================

LocalPlayer.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid", 10)
	task.wait(0.3)
	for _, f in ipairs(Features) do
		if featureStates[f.Name] then
			local ok, err = pcall(f.Callback, true)
			if not ok then
				warn("[脚本中心] 重生恢复失败：" .. tostring(err))
			end
		end
	end
end)

print("[脚本中心] 加载完成，按 " .. CONFIG.ToggleKey.Name .. " 显示/隐藏界面")