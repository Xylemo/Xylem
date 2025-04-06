-- Gui to Lua
-- Version: 3.2

-- Instances:


--[[
	 __  __              _____   _   _ 
	|  \/  |     /\     |_   _| | \ | |
	| \  / |    /  \      | |   |  \| |
	| |\/| |   / /\ \     | |   | . ` |
	| |  | |  / ____ \   _| |_  | |\  |
	|_|  |_| /_/    \_\ |_____| |_| \_|
--]]
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGuiService = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")


local TweenTime = 0.1
local Level = 1

local GlobalTweenInfo = TweenInfo.new(TweenTime)
local AlteredTweenInfo = TweenInfo.new(TweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local function Tween(GuiObject, Dictionary)
	local TweenBase = TweenService:Create(GuiObject, GlobalTweenInfo, Dictionary)
	TweenBase:Play()
	return TweenBase
end

local function GetXY(GuiObject)
	local X, Y = Mouse.X - GuiObject.AbsolutePosition.X, Mouse.Y - GuiObject.AbsolutePosition.Y
	local MaxX, MaxY = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
	X, Y = math.clamp(X, 0, MaxX), math.clamp(Y, 0, MaxY)
	return X, Y, X/MaxX, Y/MaxY
end


local activeUIElements = {}
local transparencyCache = {}

local function CloseUI(Draggable, Open)
	transparencyCache = {}

	local tweens = {}

	for _, obj in ipairs(Draggable:GetDescendants()) do
		if obj:IsA("GuiObject") and obj.Name ~= "Background" then
			local stroke = obj:FindFirstChildWhichIsA("UIStroke")
			local shouldCache = false

			if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
				if obj.TextTransparency < 1 then shouldCache = true end
			end
			if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
				if obj.ImageTransparency < 1 and obj.Image ~= "" then shouldCache = true end
			end
			if obj.BackgroundTransparency < 1 then
				shouldCache = true
			end

			if stroke and stroke.Transparency < 1 then
				transparencyCache[stroke] = { Transparency = stroke.Transparency }
				local strokeTween = TweenService:Create(stroke, TweenInfo.new(0.5), { Transparency = 1 })
				strokeTween:Play()
				table.insert(tweens, strokeTween)
			end

			if shouldCache then
				transparencyCache[obj] = {
					BackgroundTransparency = obj.BackgroundTransparency
				}
				if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
					transparencyCache[obj].TextTransparency = obj.TextTransparency
				end
				if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
					transparencyCache[obj].ImageTransparency = obj.ImageTransparency
				end

				local props = { BackgroundTransparency = 1 }
				if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
					props.TextTransparency = 1
				end
				if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
					props.ImageTransparency = 1
				end

				local tween = TweenService:Create(obj, TweenInfo.new(0.5), props)
				tween:Play()
				table.insert(tweens, tween)
			end
		end
	end

	if #tweens > 0 then
		coroutine.wrap(function()
			tweens[#tweens].Completed:Wait()
			Open.Visible = true
			Draggable.Interactable = false
			TweenService:Create(Open.CloseImage, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageTransparency = 0
			}):Play()
		end)()
	end
end



local function OpenUI(Open)
	for obj, values in pairs(transparencyCache) do
		local props = {}
		
		

		if obj:IsA("GuiObject") then
			
			
			if values.BackgroundTransparency ~= nil then
				props.BackgroundTransparency = values.BackgroundTransparency
			end
			if values.TextTransparency ~= nil and (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
				props.TextTransparency = values.TextTransparency
			end
			if values.ImageTransparency ~= nil and (obj:IsA("ImageLabel") or obj:IsA("ImageButton")) then
				props.ImageTransparency = values.ImageTransparency
			end
		elseif obj:IsA("UIStroke") then
			if values.Transparency ~= nil then
				props.Transparency = values.Transparency
			end
		end

		local tween = TweenService:Create(obj, TweenInfo.new(0.5), props)
		tween:Play()
	end

	transparencyCache = {} 
end




local UILibrary = {}

function UILibrary.Load(GUITitle)

	local Corner = Instance.new("UICorner")

	local XylemMain = Instance.new("ScreenGui")
	XylemMain.Name = "XylemMain"
	XylemMain.ZIndexBehavior = Enum.ZIndexBehavior.Global
	XylemMain.ResetOnSpawn = false
	XylemMain.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	
	
	local Open = Instance.new("ImageButton")
	Open.Parent = XylemMain
	Open.AnchorPoint = Vector2.new(0.5, 0.5)
	Open.BackgroundColor3 = Color3.fromRGB(34, 36, 38)
	Open.BackgroundTransparency = 1
	Open.BorderColor3 = Color3.fromRGB(17, 255, 0)
	Open.BorderSizePixel = 0
	Open.Position = UDim2.new(0.5, 0, -0.026, 0)
	Open.Size = UDim2.new(0, 30, 0, 30)
	Open.ScaleType = Enum.ScaleType.Fit
	Open.Visible = false
	Open.AutoButtonColor = false

	local CloseImage = Instance.new("ImageLabel")
	CloseImage.Parent = Open
	CloseImage.Name = "CloseImage"
	CloseImage.Active = true
	CloseImage.AnchorPoint = Vector2.new(0.5, 0.5)
	CloseImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	CloseImage.BorderColor3 = Color3.fromRGB(17, 255, 0)
	CloseImage.BackgroundTransparency = 1
	CloseImage.BorderSizePixel = 0
	CloseImage.Position = UDim2.new(0.5, 0, 0.5, 0)
	CloseImage.Size = UDim2.new(0, 16, 0, 16)
	CloseImage.Image = "rbxassetid://110773590348537"
	CloseImage.ImageTransparency = 1
	CloseImage.ImageColor3 = Color3.fromRGB(255, 227, 69)

	local Draggable = Instance.new("Frame")
	Draggable.Name = "Draggable"
	Draggable.Parent = XylemMain
	Draggable.Active = true
	Draggable.BackgroundColor3 = Color3.fromRGB(53, 53, 53)
	Draggable.BackgroundTransparency = 1.000
	Draggable.BorderColor3 = Color3.fromRGB(37, 37, 37)
	Draggable.BorderSizePixel = 0
	Draggable.Draggable = true
	Draggable.Position = UDim2.new(0.5, 0, 0.5, 0)
	Draggable.Selectable = true
	Draggable.Size = UDim2.new(0.256, 0, 0.031, 0)
	Draggable.AnchorPoint = Vector2.new(0.5, 0.5)
	
	local UIactive = false
	local lastPosition = UDim2.new(1, -500, 1, -252)
	local hiddenPosition = UDim2.new(0.4, 0, -0.3, 0)
	
	local Pages = Instance.new("Frame")
	Pages.Name = "Pages"
	Pages.Parent = Draggable
	Pages.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Pages.BackgroundTransparency = 1.000
	Pages.BorderColor3 = Color3.fromRGB(27, 42, 53)
	Pages.Position = UDim2.new(0.095, 0, 0, 0)
	Pages.Size = UDim2.new(0.905, 0, 6.961, 0)

	local Background = Instance.new("Frame")
	Background.Name = "Background"
	Background.Parent = Draggable
	Background.BackgroundColor3 = Color3.fromRGB(24, 26, 27)
	Background.BorderColor3 = Color3.fromRGB(27, 42, 53)
	Background.BorderSizePixel = 0
	Background.Position = UDim2.new(0, 0, -0.03, 0)
	Background.Size = UDim2.new(0.988, 0, 7.515, 0)
	Background.ZIndex = 0
	
	local UICorner9 = Instance.new("UICorner")
	UICorner9.Parent = Background
	
	local UIStroke = Instance.new("UIStroke")
	UIStroke.Parent = Background
	UIStroke.Thickness = 1.8
	UIStroke.Transparency = 0.37
	UIStroke.Color = Color3.fromRGB(15, 15, 15)

	local Top = Instance.new("Frame")
	Top.Name = "Top"
	Top.Parent = Background
	Top.BackgroundColor3 = Color3.fromRGB(34, 36, 38)
	Top.BorderColor3 = Color3.fromRGB(27, 42, 53)
	Top.BorderSizePixel = 0
	Top.Position = UDim2.new(0.011, 0, 0.016, 0)
	Top.Size = UDim2.new(0.084, 0, 0.968, 0)
	Top.ZIndex = 0

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Parent = Top
	UIPadding.PaddingTop = UDim.new(0.02, 0)

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = Top
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0.02, 0)

	local UICorner = Instance.new("UICorner")
	UICorner.Parent = Top


	local Settings = Instance.new("ImageButton")
	Settings.Parent = Background
	Settings.AnchorPoint = Vector2.new(0.5, 0.5)
	Settings.BackgroundColor3 = Color3.fromRGB(58, 62, 66)
	Settings.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Settings.BorderSizePixel = 0
	Settings.Position = UDim2.new(0.05, 0, 0.9, 0)
	Settings.Size = UDim2.new(0, 30, 0, 30)
	Settings.ScaleType = Enum.ScaleType.Fit
	Settings.AutoButtonColor = false
	Settings.BackgroundTransparency = 1

	Corner.Parent = Settings

	local ImageLabel = Instance.new("ImageLabel")

	ImageLabel.Parent = Settings
	ImageLabel.Active = true
	ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	ImageLabel.Size = UDim2.new(0, 16, 0, 16)
	ImageLabel.Image = "rbxassetid://98682618410846"
	ImageLabel.ImageColor3 = Color3.fromRGB(124, 132, 141)

	local Title = Instance.new("Frame")
	Title.Name = "Title"
	Title.Parent = Draggable
	Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Title.BackgroundTransparency = 1.000
	Title.BorderColor3 = Color3.fromRGB(27, 42, 53)
	Title.BorderSizePixel = 0
	Title.Position = UDim2.new(0.14, 0, 0.022, 0)
	Title.Size = UDim2.new(0.84, 0, 0.957, 0)


	local TitleText = Instance.new("TextLabel")
	TitleText.Parent = Title
	TitleText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TitleText.BackgroundTransparency = 1.000
	TitleText.BorderColor3 = Color3.fromRGB(27, 42, 53)
	TitleText.BorderSizePixel = 0
	TitleText.Size = UDim2.new(1, 0, 1, 0)
	TitleText.Font = Enum.Font.SourceSansBold
	TitleText.Text = "Main"
	TitleText.TextColor3 = Color3.fromRGB(230, 233, 235)
	TitleText.TextSize = 23.000
	TitleText.TextStrokeColor3 = Color3.fromRGB(41, 50, 53)
	TitleText.TextXAlignment = Enum.TextXAlignment.Left
	TitleText.RichText = true


	local Close = Instance.new("ImageButton")
	Close.Parent = Title
	Close.AnchorPoint = Vector2.new(0.5, 0.5)
	Close.BackgroundColor3 = Color3.fromRGB(58, 62, 66)
	Close.BackgroundTransparency = 1.000
	Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Close.BorderSizePixel = 0
	Close.Position = UDim2.new(0.949999988, 0, 0.5, 0)
	Close.Size = UDim2.new(0, 16, 0, 16)
	Close.Image = "rbxassetid://84804420509226"
	Close.ImageColor3 = Color3.fromRGB(124, 132, 141)
	Close.ScaleType = Enum.ScaleType.Fit
	
	
	
	Close.MouseButton1Down:Connect(function()
		UIactive = not UIactive
		lastPosition = Draggable.Position
		CloseImage.ImageTransparency = 1
		if not UIactive then
			TweenService:Create(Draggable, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Position = UDim2.new(0.5, 0,-0.041, 0)
			}):Play()

			CloseUI(Draggable, Open)

			TweenService:Create(Draggable, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Size = UDim2.new(0.018, 0, 0.0044, 0)
			}):Play()
		end
	end)
	
	Open.MouseButton1Down:Connect(function()
		Draggable.Interactable = true
		Open.Visible = false
		CloseImage.ImageTransparency = 1
		
		UIactive = not UIactive
		if UIactive then
			TweenService:Create(Draggable, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Position = lastPosition
			}):Play()

			TweenService:Create(Draggable, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Size = UDim2.new(0.256, 0, 0.031, 0)
			}):Play()


			OpenUI()
		end
	end)



	local PageLibrary = {}

	function PageLibrary.AddPage(PageImage, PageName, IsMain)
		
		TitleText.Text = IsMain and PageName or TitleText.Text

		local Page = Instance.new("ScrollingFrame")
		Page.Parent = Pages
		Page.Active = true
		Page.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Page.BackgroundTransparency = 1.000
		Page.BorderColor3 = Color3.fromRGB(27, 42, 53)
		Page.Position = UDim2.new(0, 0, 0.163, 0)
		Page.Size = UDim2.new(0.986, 0, 0.88, 0)
		Page.BottomImage = ""
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		Page.MidImage = ""
		Page.ScrollBarThickness = 0
		Page.TopImage = ""
		Page.Visible = IsMain
		Page.AutomaticCanvasSize = "Y"
		
		local UIListLayout = Instance.new("UIListLayout")
		UIListLayout.Parent = Page
		UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.Padding = UDim.new(0, 0)
		UIListLayout.FillDirection = "Horizontal"
		
		
		local Left = Instance.new("Frame")
		Left.Name = "Left"
		Left.Parent = Page
		Left.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Left.BackgroundTransparency = 1.000
		Left.BorderColor3 = Color3.fromRGB(27, 42, 53)
		Left.Position = UDim2.new(0.029, 0, 0, 0)
		Left.Size = UDim2.new(0, 213, 0, 240)

		local UIListLayout_2 = Instance.new("UIListLayout")
		UIListLayout_2.Parent = Left
		UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_2.Padding = UDim.new(0.04, 0)

		local UIPadding_2 = Instance.new("UIPadding")
		UIPadding_2.Parent = Left
		UIPadding_2.PaddingLeft = UDim.new(0.02, 0)
		UIPadding_2.PaddingTop = UDim.new(0.003, 0)

		local Right = Instance.new("Frame")

		Right.Name = "Right"
		Right.Parent = Page
		Right.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Right.BackgroundTransparency = 1.000
		Right.BorderColor3 = Color3.fromRGB(27, 42, 53)
		Right.Position = UDim2.new(0.497, 0, 0, 0)
		Right.Size = UDim2.new(0, 213, 0, 240)

		local UIListLayout_6 = Instance.new("UIListLayout")

		UIListLayout_6.Parent = Right
		UIListLayout_6.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_6.Padding = UDim.new(0.004, 0)

		local UIPadding_3 = Instance.new("UIPadding")

		UIPadding_3.Parent = Right
		UIPadding_3.PaddingLeft = UDim.new(0.02, 0)
		UIPadding_3.PaddingTop = UDim.new(0.003, 0)


		local ImageButton_3 = Instance.new("ImageButton")
		ImageButton_3.Parent = Top
		ImageButton_3.AnchorPoint = Vector2.new(0.5, 0.5)
		ImageButton_3.BackgroundColor3 = Color3.fromRGB(58, 62, 66)
		ImageButton_3.BackgroundTransparency = IsMain and 0.7 or 1
		ImageButton_3.BorderColor3 = IsMain and Color3.fromRGB(255, 0, 4) or Color3.fromRGB(17, 255, 0)
		ImageButton_3.BorderSizePixel = 0
		ImageButton_3.Position = UDim2.new(0.5, 0, 0.1, 0)
		ImageButton_3.Size = UDim2.new(0, 30, 0, 30)
		ImageButton_3.ScaleType = Enum.ScaleType.Fit

		local UICorner_3 = Instance.new("UICorner")
		UICorner_3.Parent = ImageButton_3

		local TabSide = Instance.new("ImageLabel")
		TabSide.Parent = ImageButton_3
		TabSide.Name = "TabSide"
		TabSide.Active = true
		TabSide.AnchorPoint = Vector2.new(0.5, 0.5)
		TabSide.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TabSide.BorderColor3 = Color3.fromRGB(17, 255, 0)
		TabSide.BackgroundTransparency = 1.000
		TabSide.BorderSizePixel = 0
		TabSide.Position = UDim2.new(0.5, 0, 0.5, 0)
		TabSide.Size = UDim2.new(0, 16, 0, 16)
		TabSide.Image = PageImage
		TabSide.ImageColor3 = IsMain and Color3.fromRGB(255, 227, 69) or Color3.fromRGB(124, 132, 141)


		ImageButton_3.AutoButtonColor = false

		local activeColor = Color3.fromRGB(255, 0, 4)
		local inactiveColor = Color3.fromRGB(17, 255, 0)
		local hoverTransparency = 0.7
		local normalTransparency = 1

		ImageButton_3.MouseEnter:Connect(function()
			if ImageButton_3.BorderColor3 == inactiveColor then
				TweenService:Create(ImageButton_3, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = hoverTransparency
				}):Play()
			end
		end)

		ImageButton_3.MouseLeave:Connect(function()
			if ImageButton_3.BorderColor3 == inactiveColor then
				TweenService:Create(ImageButton_3, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = normalTransparency
				}):Play()
			end
		end)

		ImageButton_3.MouseButton1Down:Connect(function()
			local isInactive = ImageButton_3.BorderColor3 == inactiveColor
			ImageButton_3.BorderColor3 = isInactive and activeColor or inactiveColor
			Page.Visible = isInactive

			for _, class in pairs(Top:GetChildren()) do
				if class:IsA("ImageButton") and class ~= ImageButton_3 and class.BorderColor3 == activeColor then
					class.BorderColor3 = inactiveColor

					TweenService:Create(class.TabSide, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						ImageColor3 = Color3.fromRGB(124, 132, 141)
					}):Play()

					TweenService:Create(class, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundTransparency = normalTransparency
					}):Play()
				end
			end

			for _, class in pairs(Pages:GetChildren()) do
				if class:IsA("ScrollingFrame") and class ~= Page then
					class.Visible = false
				end
			end

			TweenService:Create(TabSide, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				ImageColor3 = isInactive and Color3.fromRGB(255, 227, 69) or Color3.fromRGB(124, 132, 141)
			}):Play()

			if isInactive then
				TitleText.Text = PageName
				CloseImage.Image = PageImage
			end
		end)


		local TabLibrary = {}

		function TabLibrary.AddTab(TabTitle, DescTextArg, Side, Callback)
			
			local Color = false
			
			local selecting = true
			local keyn

			local Tab = Instance.new("Frame")
			Tab.Name = TabTitle

			if Side == "Left" then
				Tab.Parent = Left
			elseif Side == "Right" then
				Tab.Parent = Right
			end

			Tab.AnchorPoint = Vector2.new(0.5, 0.5)
			Tab.BackgroundColor3 = Color3.fromRGB(34, 36, 38)
			Tab.BackgroundTransparency = 1.000
			Tab.BorderColor3 = Color3.fromRGB(27, 42, 53)
			Tab.BorderSizePixel = 0
			Tab.Position = UDim2.new(0.489, 0, 0.54, 0)
			Tab.Size = UDim2.new(0.978, 0, 0.3, 0)

			local Features = Instance.new("ImageLabel")
			Features.Name = "Features"
			Features.Parent = Tab
			Features.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Features.BackgroundTransparency = 1.000
			Features.BorderColor3 = Color3.fromRGB(27, 42, 53)
			Features.Position = UDim2.new(0, 0, 0, 70)
			Features.Size = UDim2.new(0, 204, 0, 25)
			Features.ZIndex = 2
			Features.ImageColor3 = Color3.fromRGB(183, 197, 211)
			Features.ImageTransparency = 1
			Features.ScaleType = Enum.ScaleType.Fit
			Features.SliceScale = 0

			local List = Instance.new("Frame")
			List.Name = "List"
			List.Parent = Features
			List.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			List.BackgroundTransparency = 1
			List.BorderColor3 = Color3.fromRGB(27, 42, 53)
			List.Position = UDim2.new(0.056, 0, 0, 0)
			List.Size = UDim2.new(0, 183, 0, 15)
			List.ZIndex = 2

			local UIListLayout_3 = Instance.new("UIListLayout")
			UIListLayout_3.Parent = List
			UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_3.Padding = UDim.new(0, 4)

			local Top = Instance.new("Frame")

			Top.Name = "Top"
			Top.Parent = Tab
			Top.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Top.BackgroundTransparency = 1.000
			Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Top.BorderSizePixel = 0
			Top.Position = UDim2.new(0, 11, 0, 5)
			Top.Size = UDim2.new(0, 143, 0, 20)

			local Title_2 = Instance.new("TextLabel")

			Title_2.Name = "Title"
			Title_2.Parent = Top
			Title_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Title_2.BackgroundTransparency = 1.000
			Title_2.BorderColor3 = Color3.fromRGB(27, 42, 53)
			Title_2.BorderSizePixel = 0
			Title_2.Position = UDim2.new(0, 0, 0.0290366728, 0)
			Title_2.Size = UDim2.new(0, 0, 0.942, 0)
			Title_2.ZIndex = 10
			Title_2.Font = Enum.Font.SourceSansBold
			Title_2.Text = TabTitle
			Title_2.AutomaticSize = "X"
			Title_2.TextColor3 = Color3.fromRGB(232, 235, 237)
			Title_2.TextSize = 17.000
			Title_2.TextStrokeColor3 = Color3.fromRGB(41, 50, 53)
			Title_2.TextXAlignment = Enum.TextXAlignment.Left
			Title_2.TextYAlignment = Enum.TextYAlignment.Top


			local UIListLayout_4 = Instance.new("UIListLayout")

			UIListLayout_4.Parent = Top
			UIListLayout_4.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout_4.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout_4.VerticalAlignment = Enum.VerticalAlignment.Center
			UIListLayout_4.Padding = UDim.new(0.03, 0)

			local DescText = Instance.new("TextLabel")
			
			local Back = Instance.new("Frame")
			Back.Name = "Back"
			Back.Parent = Tab
			Back.BackgroundColor3 = Color3.fromRGB(34, 36, 38)
			Back.BorderColor3 = Color3.fromRGB(27, 42, 53)
			Back.BorderSizePixel = 0
			Back.Size = UDim2.new(1, 0, 1, 0)

			
			local UIStroke2 = Instance.new("UIStroke")
			UIStroke2.Parent = Back
			UIStroke2.Thickness = 0.7
			UIStroke2.Transparency = 1
			UIStroke2.Color = Color3.fromRGB(253, 225, 68)


			local UICorner_12 = Instance.new("UICorner")

			UICorner_12.Parent = Back


			DescText.Name = "DescText"
			DescText.Parent = Tab
			DescText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			DescText.BackgroundTransparency = 1.000
			DescText.BorderColor3 = Color3.fromRGB(27, 42, 53)
			DescText.BorderSizePixel = 0
			DescText.Position = UDim2.new(0, 11, 0, 25)
			DescText.Size = UDim2.new(0, 183, 0, 48)
			DescText.ZIndex = 10
			DescText.Font = Enum.Font.SourceSansSemibold
			DescText.Text = DescTextArg
			DescText.TextColor3 = Color3.fromRGB(190, 195, 199)
			DescText.TextSize = 13.000
			DescText.TextStrokeColor3 = Color3.fromRGB(41, 50, 53)
			DescText.TextWrapped = true
			DescText.TextXAlignment = Enum.TextXAlignment.Left
			
			
			local Keybind = Instance.new("ImageButton")

			Keybind.Name = "Keybind"
			Keybind.Parent = Top
			Keybind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Keybind.BackgroundTransparency = 1
			Keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Keybind.BorderSizePixel = 0
			Keybind.Position = UDim2.new(0.4, 0, 0.14, 0)
			Keybind.Size = UDim2.new(0, 16, 0, 16)
			Keybind.Image = "rbxassetid://115741363119714"
			Keybind.ImageColor3 = Color3.fromRGB(124, 132, 141)
			Keybind.ZIndex = 2
			
			
			local KBack = Instance.new("TextLabel")
			KBack.Name = "Back"
			KBack.Parent = Keybind
			KBack.Text = "Press to a set keybind"
			KBack.BackgroundColor3 = Color3.fromRGB(58, 62, 66)
			KBack.BorderColor3 = Color3.fromRGB(27, 42, 53)
			KBack.Position = UDim2.new(1.459, 0,-0.05, 0)
			KBack.Size = UDim2.new(1, 0, 1, 0)
			KBack.BorderSizePixel = 0
			KBack.BackgroundTransparency = 1
			KBack.ZIndex = 7
			KBack.TextSize = 14
			KBack.Font = Enum.Font.SourceSansBold
			KBack.TextColor3 = Color3.fromRGB(190, 195, 199)
			KBack.TextStrokeTransparency = 1
			KBack.AutomaticSize = "X"
			KBack.TextWrapped = false
			KBack.TextTransparency = 1
			


			local UICorner_13 = Instance.new("UICorner")

			UICorner_13.Parent = KBack
				
				
			local BackD = Instance.new("Frame")
			BackD.Name = "Back"
			BackD.Parent = KBack
			BackD.BackgroundColor3 = Color3.fromRGB(58, 62, 66)
			BackD.BorderColor3 = Color3.fromRGB(27, 42, 53)
			BackD.Position = UDim2.new(0, 0,-0.05, 0)
			BackD.Size = UDim2.new(1.2, 0, 1.2, 0)
			BackD.BorderSizePixel = 0
			BackD.BackgroundTransparency = 1
			
			BackD.ZIndex = 5
			
			local UICorner_19 = Instance.new("UICorner")

			UICorner_19.Parent = BackD
			
			local UIStroke3 = Instance.new("UIStroke")
			UIStroke3.Parent = BackD
			UIStroke3.Thickness = 1
			UIStroke3.Color = Color3.fromRGB(103, 110, 117)
			UIStroke3.Transparency = 1
			
			local Toogle = Instance.new("ImageButton")
			Toogle.Name = "Toogle"
			Toogle.Parent = Tab
			Toogle.AnchorPoint = Vector2.new(0.5, 0.5)
			Toogle.BackgroundColor3 = Color3.fromRGB(100, 108, 115)
			Toogle.BorderColor3 = Color3.fromRGB(27, 42, 53)
			Toogle.BorderSizePixel = 0
			Toogle.Position = UDim2.new(0, 177, 0, 16)
			Toogle.Size = UDim2.new(0, 34, 0, 15)
			Toogle.ZIndex = 2
			Toogle.AutoButtonColor = false

			local UICorner_10 = Instance.new("UICorner")

			UICorner_10.CornerRadius = UDim.new(1000, 0)
			UICorner_10.Parent = Toogle

			local Circle_2 = Instance.new("Frame")

			Circle_2.Name = "Circle"
			Circle_2.Parent = Toogle
			Circle_2.AnchorPoint = Vector2.new(0.5, 0.5)
			Circle_2.BackgroundColor3 = Color3.fromRGB(24, 26, 27)
			Circle_2.BorderColor3 = Color3.fromRGB(27, 42, 53)
			Circle_2.BorderSizePixel = 0
			Circle_2.Position = UDim2.new(0.235, 0, 0, 7)
			Circle_2.Size = UDim2.new(0, 10, 0, 10)
			Circle_2.ZIndex = 2
			
			local UICorner_11 = Instance.new("UICorner")

			UICorner_11.CornerRadius = UDim.new(100, 0)
			UICorner_11.Parent = Circle_2
			
			
			local function playTween(obj, props)
				TweenService:Create(obj, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
			end

			Toogle.MouseEnter:Connect(function()
				playTween(Toogle, { BackgroundTransparency = 0.3 })
			end)

			Toogle.MouseLeave:Connect(function()
				playTween(Toogle, { BackgroundTransparency = 0 })
			end)

			Keybind.MouseEnter:Connect(function()
				playTween(KBack, {
					TextTransparency = 0,
					Position = UDim2.new(1.459, 0, -0.05, 0),
					Size = UDim2.new(1, 0, 1, 0)
				})
				playTween(UIStroke3, { Transparency = 0 })
				playTween(BackD, { BackgroundTransparency = 0 })
			end)

			Keybind.MouseLeave:Connect(function()
				playTween(KBack, {
					TextTransparency = 1,
					Position = UDim2.new(1.2, 0, -0.05, 0),
					Size = UDim2.new(0.9, 0, 0.9, 0)
				})
				playTween(UIStroke3, { Transparency = 1 })
				playTween(BackD, { BackgroundTransparency = 1 })
			end)

			Toogle.MouseButton1Down:Connect(function()
				Color = not Color
				Callback(Color)

				if Color then
					playTween(Toogle, { BackgroundColor3 = Color3.fromRGB(255, 227, 69) })
					playTween(Circle_2, { Position = UDim2.new(0.75, 0, 0, 7) })
					playTween(UIStroke2, { Transparency = 0 })
				else
					playTween(Toogle, { BackgroundColor3 = Color3.fromRGB(100, 108, 115) })
					playTween(Circle_2, { Position = UDim2.new(0.235, 0, 0, 7) })
					playTween(UIStroke2, { Transparency = 1 })
				end
			end)

			
			
			
			Keybind.MouseButton1Click:Connect(function(input, gameProcessed)
				if gameProcessed then return end
				selecting = false
				if selecting == false then
					KBack.Text = "  . . .  "
				end
			end)
			
			UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then return end
				if selecting == true then
					if input.KeyCode == keyn then
						if Color == false then
							Color = not Color
							Callback(true)
							local tween = TweenService:Create(Toogle,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0),{
								BackgroundColor3 = Color3.fromRGB(255, 227, 69)
							})
							local tween2 = TweenService:Create(Circle_2,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0),{
								Position = UDim2.new(0.75, 0, 0, 7)
							})
							local tween3 = TweenService:Create(UIStroke2,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0),{
								Transparency = 0
							})
							tween3:Play()
							tween2:Play()
							tween:Play()
						else
							Color = not Color
							Callback(false)
							local tween = TweenService:Create(Toogle,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0),{
								BackgroundColor3 = Color3.fromRGB(100, 108, 115)
							})
							local tween2 = TweenService:Create(Circle_2,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0),{
								Position = UDim2.new(0.235, 0, 0, 7)
							})
							local tween3 = TweenService:Create(UIStroke2,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,false,0),{
								Transparency = 1
							})
							tween3:Play()
							tween2:Play()
							tween:Play()
						end

					end
				else
					local key = string.split(tostring(input.KeyCode), ".")
					KBack.Text = key[3]
					keyn = input.KeyCode
					selecting = true
				end
			end)
			
			
			
			
			local FeatureLibrary = {}

			function FeatureLibrary.AddSlider(ConfigurationDictionary, Callback)
				
				local Configuration = ConfigurationDictionary
				local Minimum = Configuration.Minimum or Configuration.minimum or Configuration.Min or Configuration.min
				local Maximum = Configuration.Maximum or Configuration.maximum or Configuration.Max or Configuration.max
				local Default = Configuration.Default or Configuration.default or Configuration.Def or Configuration.def

				if Minimum > Maximum then
					local StoreValue = Minimum
					Minimum = Maximum
					Maximum = StoreValue
				end
				
				Tab.AutomaticSize = Enum.AutomaticSize.Y
				
				
				local Slide = Instance.new("ImageButton")
				Slide.Name = "Slide"
				Slide.Parent = List
				Slide.Size = UDim2.new(0.903, 0,1.467, 0)
				Slide.BackgroundTransparency = 1
				Slide.ZIndex = 2
				Slide.Image = ""
				Slide.AutoButtonColor = false
			


				local Slider = Instance.new("Frame")
				Slider.Name = "Slider"
				Slider.BackgroundColor3 = Color3.fromRGB(100, 108, 115)
				Slider.BorderSizePixel = 0
				Slider.Parent = Slide
				Slider.Size = UDim2.new(0.861, 0,0.136, 0)
				Slider.Position = UDim2.new(0, 0,0.182, 0)
				Slider.ZIndex = 2

				
				local SliderFill = Instance.new("Frame")
				SliderFill.Name = "SliderFill"
				SliderFill.BackgroundColor3 = Color3.fromRGB(255, 227, 69)
				SliderFill.BorderSizePixel = 0
				SliderFill.Parent = Slider
				SliderFill.Position = UDim2.new(0, 0,0, 0)
				SliderFill.ZIndex = 3
				
				local SliderBox = Instance.new("Frame")
				SliderBox.Name = "SliderBox"
				SliderBox.BackgroundColor3 = Color3.fromRGB(17, 18, 19)
				SliderBox.BorderSizePixel = 0
				SliderBox.Parent = Slide
				SliderBox.Position = UDim2.new(0.915, 0,-0.136, 0)
				SliderBox.Size = UDim2.new(0.182, 0,0.818, 0)
				SliderBox.ZIndex = 2
				
				local UIStroke8 = Instance.new("UIStroke")
				UIStroke8.Parent = SliderBox
				UIStroke8.Thickness = 1
				UIStroke8.Transparency = 0
				UIStroke8.Color = Color3.fromRGB(43, 47, 50)

				local UICorner_8 = Instance.new("UICorner")
				UICorner_8.CornerRadius = UDim.new(0.3, 00)
				UICorner_8.Parent = SliderBox
				
				local CircleSlide = Instance.new("Frame")
				CircleSlide.Name = "SliderBox"
				CircleSlide.BackgroundColor3 = Color3.fromRGB(17, 18, 19)
				CircleSlide.BorderSizePixel = 0
				CircleSlide.Parent = Slider
				CircleSlide.Position = UDim2.new(0.5, 0,0.5, 0)
				CircleSlide.Size = UDim2.new(0, 10,0, 10)
				CircleSlide.ZIndex = 4
				CircleSlide.AnchorPoint = Vector2.new(0.5, 0.5)

				local UIStroke9 = Instance.new("UIStroke")
				UIStroke9.Parent = CircleSlide
				UIStroke9.Thickness = 1
				UIStroke9.Transparency = 0
				UIStroke9.Color = Color3.fromRGB(255, 227, 69)

				local UICorner_9 = Instance.new("UICorner")
				UICorner_9.CornerRadius = UDim.new(1, 0)
				UICorner_9.Parent = CircleSlide

				local SliderNumber = Instance.new("TextBox")
				SliderNumber.Name = "SliderNumber"
				SliderNumber.Parent = SliderBox
				SliderNumber.Size = UDim2.new(1, 0,1, 0)
				SliderNumber.Position = UDim2.new(0, 0,0, 0)
				SliderNumber.BackgroundTransparency = 1
				SliderNumber.TextColor3 = Color3.fromRGB(190, 195, 199)
				SliderNumber.TextSize = 13
				SliderNumber.TextXAlignment = "Center"
				SliderNumber.Font = Enum.Font.SourceSansSemibold
				SliderNumber.Text = tostring(Default)
				SliderNumber.ZIndex = 3
				
				Default = math.clamp(Default or Minimum, Minimum, Maximum)
				local DefaultScale = (Default - Minimum) / (Maximum - Minimum)

				SliderFill.Size = UDim2.new(DefaultScale, 0, 1, 0)
				
				CircleSlide.Position = UDim2.new(DefaultScale, 0,0.5, 0)

				local dragging = false

				local function updateSlider(xScale)
					xScale = math.clamp(xScale, 0, 1)
					local value = math.floor(Minimum + ((Maximum - Minimum) * xScale))
					Callback(value)
					SliderNumber.Text = tostring(value)
					Tween(SliderFill, { Size = UDim2.new(xScale, 0, 1, 0) })
					Tween(CircleSlide, { Position = UDim2.new(xScale, 0, 0.5, 0) })
				end

				local function updateFromMouse()
					local _, _, xScale = GetXY(Slider)
					updateSlider(xScale)
				end

				Slide.MouseButton1Down:Connect(function()
					dragging = true
				end)

				UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						updateFromMouse()
					end
				end)

				UserInputService.InputEnded:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)

				local sliderMove = Mouse.Move:Connect(function()
					if dragging then
						updateFromMouse()
					end
				end)

				SliderNumber.FocusLost:Connect(function(enterPressed)
					if not enterPressed then return end

					local input = tonumber(SliderNumber.Text)
					if input then
						local clamped = math.clamp(input, Minimum, Maximum)
						local xScale = (clamped - Minimum) / (Maximum - Minimum)
						updateSlider(xScale)
					else
						local currentX = (tonumber(SliderNumber.Text) or Minimum - Minimum) / (Maximum - Minimum)
						updateSlider(currentX)
					end
				end)


			end
		return FeatureLibrary
		end
		return TabLibrary
	end
	return PageLibrary
end
return UILibrary
