-- Developed by bkkpro1980.
-- You are free to use this library in your projects.
-- However, please do not claim authorship or present it as your own work.
-- Any such misrepresentation may result in appropriate action being taken.

-- This version of InfilSense Lib has been modified to be used with InfilSense EP
-- modified usage
--[[
	- slider settings args[5] is shouldSave (boolean)
	- slider StartupAvailable = willStartup
	- the last args of each Interaction function is command id list for quick cmd (table)
]]

-- IGNORE

--!nolint UnknownGlobal
--!nocheck

-- IGNORE

module = {}
module.__index = module

cloneref = cloneref or clonereference or function(v) return v end
CAS = cloneref(game:GetService("ContextActionService"))
UIS = cloneref(game:GetService("UserInputService"))
COREGUI = cloneref(game:GetService("CoreGui"))
TS = cloneref(game:GetService("TweenService"))

local ti = TweenInfo.new(.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0)
local libName = "Unnamed Script"
local version = "Unknown Version"
local saveFileLoc = "unnamed"

local container
local background
local scrollFrame
local close
local headers
local nextPrev

local pageNum = 1
local lastPageNum
local pagesAmount = 0
local uiPages = {}
local values = {}
local savedData

--[[ FILE SYSTEM FUNCTIONS \]]--
local HttpService = game:GetService("HttpService")

function saveConfig(filename, configTable)
	-- Encode the table to JSON using HttpService
	local encS, encoded = pcall(HttpService.JSONEncode, HttpService, configTable)
	if not encS then
		return false
	end

	-- Save to file
	local saveS, _err = pcall(writefile, filename, encoded)
	if not saveS then
		return false
	end

	return true
end

function loadConfig(filename)
	-- Check if file exists
	if not isfile(filename) then
		return configManager.clear()
	end

	-- Read file
	local readS, fileContent = pcall(readfile, filename)
	if not readS then
		repeat readS, fileContent = pcall(readfile, filename) until readS
		--return configManager.clear()
	end

	-- Decode JSON using HttpService
	local decS, decoded = pcall(HttpService.JSONDecode, HttpService, fileContent)
	if not decS then
		repeat decS, decoded = pcall(HttpService.JSONDecode, HttpService, fileContent) until decS
		--return configManager.clear()
	end

	return decoded
end

configManager = {
	add = function(command,dict,value)
		-- Validate input
		if not command or typeof(command) ~= "string" then
			return false, "Invalid command string"
		end

		-- Initialize empty config if file doesn't exist
		if not isfile(saveFileLoc..".json") then
			writefile(saveFileLoc..".json", "{\"Startup\":{},\"Keybinds\":{},\"Settings\":{},\"MenuToggle\":\"RightShift\"}")
		end

		-- Load existing config
		local config = loadConfig(saveFileLoc..".json") or {}
		
		-- Ensure config is a table
		if typeof(config) ~= "table" then
			config = {}
		end

		-- Initialize Startup table if it doesn't exist
		if dict then
			if not config[dict] then
				config[dict] = {}
			end
			config[dict][command] = value
		else
			config[command] = value
		end

		-- Save the updated config
		local success, _err = saveConfig(saveFileLoc..".json", config)
		if not success then
			return false
		end

		return true
	end,
	
	remove = function(command,dict)
		-- Validate input
		if not command or typeof(command) ~= "string" then
			return false, "Invalid command string"
		end

		if not isfile(saveFileLoc..".json") then
			writefile(saveFileLoc..".json", "{\"Startup\":{},\"Keybinds\":{},\"Settings\":{},\"MenuToggle\":\"RightShift\"}")
		end

		local config = loadConfig(saveFileLoc..".json") or {}
		
		if typeof(config) ~= "table" then
			config = {}
		end

		if dict then
			if not config[dict] then
				config[dict] = {}
			end
			config[dict][command] = nil
		else
			config[command] = nil
		end

		-- Save the updated config
		local success, _err = saveConfig(saveFileLoc..".json", config)
		if not success then
			return false
		end

		return true
	end,
	
	list = function(dict)
		if not isfile(saveFileLoc..".json") then return {} end
		local config = loadConfig(saveFileLoc..".json") or {}
		if typeof(dict) == "string" then
			return config[dict] or {}
		else
			return config or {}
		end
	end,
	
	clear = function()
		writefile(saveFileLoc..".json", "{\"Startup\":{},\"Keybinds\":{},\"Settings\":{},\"MenuToggle\":\"RightShift\"}")
		return loadConfig(saveFileLoc..".json")
	end
}
--[[ END OF FILE SYSTEM FUNCTIONS \]]--

-- HELPER FUNCTIONS
function randomString()
	local length = math.random(10, 20)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

local function isValidKey(keyText)
	keyText = keyText:gsub("Enum.KeyCode.", "")

	return pcall(
		function()
			return Enum.KeyCode[keyText] ~= nil
		end
	)
end

local function stringToKeyCode(str)
	local keyName = str:gsub("Enum.KeyCode.", "")
	return Enum.KeyCode[keyName]
end

local function manageKeybind(command, func, key)
	if not command then return false end

	if func then
		--print("Binding key for command: " .. command .. " to key: " .. key.Name)

		configManager.add(command,"Keybinds",key.Name)
		CAS:UnbindAction(command)
		CAS:BindAction(
			command,
			function(actionName, inputState, inputObject)
				if inputState == Enum.UserInputState.End then
					values[command] = not values[command]
					func(values[command],true)
				end
			end,
			false,
			key
		)

		return true
	else
		configManager.remove(command,"Keybinds")
		CAS:UnbindAction(command)
		return false
	end
end

function bindKey(capturingKey, connection, keybindlabel, command, commandFunc)
	if capturingKey then return end

	capturingKey = true
	keybindlabel.Text = "Press a key...  (Click to unbind)"
	local timeout = 5
	local captureStart = tick()

	connection = UIS.InputBegan:Connect(function(input)
		if tick() - captureStart > timeout then
			keybindlabel.Text = "Capture Timed Out"
			capturingKey = false
			connection:Disconnect()
			return
		end

		if input then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				manageKeybind(command, commandFunc, input.KeyCode)
				keybindlabel.Text = "Bound to: " .. tostring(input.KeyCode.Name)
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
				manageKeybind(command)
				keybindlabel.Text = "Click to set a keybind"
			else
				keybindlabel.Text = "Invalid Input!"
				task.delay(1.5, function()
					keybindlabel.Text = "Click To Set A Keybind"
				end)
			end
			capturingKey = false
			connection:Disconnect()
		end
	end)
	task.delay(timeout, function()
		if capturingKey then
			keybindlabel.Text = "Capture Timed Out"
			task.delay(1.5, function()
				keybindlabel.Text = "Click To Set A Keybind"
			end)
			capturingKey = false
			if connection then
				connection:Disconnect()
			end
		end
	end)
end

local function startupFunc(command)
	if not command then return false end
	local config = loadConfig(saveFileLoc..".json")
	config = config["Startup"] and config["Startup"][command] or false
	
	if not config then
		print("Setting startup for command: " .. command)
		configManager.add(command,"Startup",true)
		return true
	else
		configManager.remove(command,"Startup")
		return false
	end
end
-- HELPER FUNCTIONS

function module:SetName(name)
	libName = name
end

function module:SetVersion(ver)
	version = ver
end

function module:SetSaveFileName(name)
	saveFileLoc = name
end

function module:RenameSaveFile(name,rename)
		local oldFile = name..".json"
		local newFile = rename..".json"
		if not isfile(oldFile) then
			return false,"Original file does not exist."
		end
		if isfile(newFile) then
			return false,"A file with the new name already exists."
		end
		local readS,content = pcall(readfile,oldFile)
		if not readS then
			return false,"Failed to read the original file."
		end
		local writeS = pcall(writefile,newFile,content)
		if not writeS then
			return false,"Failed to write to the new file."
		end
		local delS = pcall(delfile,oldFile)
		if not delS then
			return false,"Failed to delete the original file."
		end
		return true
	end

local guiClosed = false
local tween1
local tween2
local function toggleGui(actionName, inputState, _, bg, ov)
	if (actionName == "MenuToggle" and inputState == Enum.UserInputState.Begin) or bg == false or ov then
		if bg == nil then bg = true end
		if guiClosed then
			if tween1 then if tween1.PlaybackState == Enum.PlaybackState.Playing then tween1:Cancel() end end
			if tween2 then if tween2.PlaybackState == Enum.PlaybackState.Playing then tween2:Cancel() end end
			tween1 = TS:Create(container, ti, {Position = UDim2.new(.5, 0, .5, 0)})
			if bg then
				tween2 = TS:Create(background, ti, {Position = UDim2.new(.5, 0, .5, 0)})
				tween2:Play()
			end
			tween1:Play()
			guiClosed = false
			close.Modal = true
		else
			if tween1 then if tween1.PlaybackState == Enum.PlaybackState.Playing then tween1:Cancel() end end
			if tween2 then if tween2.PlaybackState == Enum.PlaybackState.Playing then tween2:Cancel() end end
			tween1 = TS:Create(container, ti, {Position = UDim2.new(.5, 0, -.5, 0)})
			if bg then
				tween2 = TS:Create(background, ti, {Position = UDim2.new(.5, 0, -.5, 0)})
				tween2:Play()
			end
			tween1:Play()
			guiClosed = true
			close.Modal = false
		end
	end
end

-- Selection
local selectScrollFrame
local selectFrame
local selectClose

local selectClosed = Instance.new("BoolValue")
selectClosed.Name = "selectClosed"
selectClosed.Parent = selectFrame
selectClosed.Value = true
local selectTween
local function toggleSelectionMenu(labelText)
	local label = selectFrame:FindFirstChild("top") and selectFrame.top:FindFirstChild("label")
	if not selectFrame or not selectClose or not label then return end
	if selectClosed.Value then
		label.Text = labelText
		if selectTween then if selectTween.PlaybackState == Enum.PlaybackState.Playing then selectTween:Cancel() end end
		selectTween = TS:Create(selectFrame, ti, {Position = UDim2.new(.5, 0, .5, 0)})
		selectTween:Play()
		selectClosed.Value = false
		selectClose.Modal = true
	else
		if selectTween then if selectTween.PlaybackState == Enum.PlaybackState.Playing then selectTween:Cancel() end end
		selectTween = TS:Create(selectFrame, ti, {Position = UDim2.new(.5, 0, -.5, 0)})
		selectTween:Play()
		selectClosed.Value = true
		selectClose.Modal = false
	end
end

local function clearSelectionButtons()
	for _,button in ipairs(selectScrollFrame:GetChildren()) do
		if button:IsA("ImageButton") then button:Destroy() end
	end
end

local function createSelectionButtons(tableA, valueInstance)
	local function createSingle(label2,value)
		local Button = Instance.new("ImageButton")
		local padding = Instance.new("UIPadding")
		local stroke = Instance.new("UIStroke")
		local label = Instance.new("TextLabel")
		local valueDisplay = Instance.new("TextLabel")
		local padding2 = Instance.new("UIPadding")

		Button.Name = "Button"
		Button.Parent = selectScrollFrame
		Button.AnchorPoint = Vector2.new(.5, .5)
		Button.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
		Button.BackgroundTransparency = .9
		Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Button.BorderSizePixel = 0
		Button.LayoutOrder = 1
		Button.Size = UDim2.new(1, 0, 0, 40)
		Button.AutoButtonColor = false

		padding.Name = "padding"
		padding.Parent = Button
		padding.PaddingBottom = UDim.new(0, 10)
		padding.PaddingLeft = UDim.new(0, 20)
		padding.PaddingRight = UDim.new(0, 20)
		padding.PaddingTop = UDim.new(0, 10)

		stroke.Name = "stroke"
		stroke.Parent = Button
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		stroke.Color = Color3.fromRGB(255, 255, 255)
		stroke.LineJoinMode = Enum.LineJoinMode.Miter
		stroke.Thickness = 0
		stroke.Transparency = .8

		label.Name = "label"
		label.Parent = Button
		label.AnchorPoint = Vector2.new(0, .5)
		label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		label.BackgroundTransparency = 1
		label.BorderColor3 = Color3.fromRGB(0, 0, 0)
		label.BorderSizePixel = 0
		label.Position = UDim2.new(0, 0, .5, 0)
		label.Size = UDim2.new(.5, 0, 1, 0)
		label.Font = Enum.Font.Montserrat
		label.Text = label2
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextSize = 18
		label.TextTransparency = .1
		label.TextXAlignment = Enum.TextXAlignment.Left

		valueDisplay.Name = "valueDisplay"
		valueDisplay.Parent = Button
		valueDisplay.AnchorPoint = Vector2.new(1, .5)
		valueDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		valueDisplay.BackgroundTransparency = 1
		valueDisplay.BorderColor3 = Color3.fromRGB(0, 0, 0)
		valueDisplay.BorderSizePixel = 0
		valueDisplay.Position = UDim2.new(1, 0, .5, 0)
		valueDisplay.Size = UDim2.new(.5, 0, 1, 0)
		valueDisplay.Font = Enum.Font.Montserrat
		valueDisplay.Text = value
		valueDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
		valueDisplay.TextSize = 14
		valueDisplay.TextTransparency = .1
		valueDisplay.TextXAlignment = Enum.TextXAlignment.Right

		padding2.Parent = selectScrollFrame
		padding2.Name = "padding"
		padding2.PaddingBottom = UDim.new(0, -2)
		padding2.PaddingLeft = UDim.new(0, 5)
		padding2.PaddingRight = UDim.new(0, 5)
		padding2.PaddingTop = UDim.new(0, 2)
		
		task.spawn(function()
			Button.MouseEnter:Connect(function()
				TS:Create(Button, ti, {BackgroundTransparency = .95}):Play()
				TS:Create(Button.stroke, ti, {Thickness = 2}):Play()
			end)

			Button.MouseButton1Down:Connect(function()
				TS:Create(Button, ti, {BackgroundTransparency = .7}):Play()
				TS:Create(Button.stroke, ti, {Thickness = 3}):Play()
			end)

			Button.InputEnded:Connect(function()
				TS:Create(Button, ti, {BackgroundTransparency = .9}):Play()
				TS:Create(Button.stroke, ti, {Thickness = 0}):Play()
			end)

			Button.Activated:Connect(function()
				valueInstance.Value = value
				toggleGui(nil,nil,nil,false)
				toggleSelectionMenu()
				clearSelectionButtons()
			end)
		end)
	end

	for label,value in pairs(tableA) do
		createSingle(label,value)
	end
end
-- Selection

local function updateButtons(nextButton, prevButton)
	if pageNum == 1 then
		if prevButton then prevButton.Visible = false end
		if nextButton then
			nextButton.Size = UDim2.new(0.2, 420, 0, 50)
			nextButton.Visible = true
			nextButton:FindFirstChild("label").Text = "Next Page (" .. (pageNum + 1) .. ")"
		end
	elseif pageNum == lastPageNum then
		if nextButton then nextButton.Visible = false end
		if prevButton then
			prevButton.Size = UDim2.new(0.2, 420, 0, 50)
			prevButton.Visible = true
			prevButton:FindFirstChild("label").Text = "Previous Page (" .. (pageNum - 1) .. ")"
		end
	else
		if nextButton and prevButton then
			nextButton.Size = UDim2.new(0.2, 120, 0, 50)
			prevButton.Size = UDim2.new(0.2, 120, 0, 50)
			nextButton.Visible = true
			prevButton.Visible = true
			nextButton:FindFirstChild("label").Text = "Next Page (" .. (pageNum + 1) .. ")"
			prevButton:FindFirstChild("label").Text = "Previous Page (" .. (pageNum - 1) .. ")"
		end
	end
end

local quickcmdUI
local quickcmdList = {}
local quickcmdListOrder = {}
local quickcmdActive = false
local quickcmdDB = false
local function quickcmd(value,binded)
    if quickcmdDB then return end
    if binded then
        if not quickcmdActive or not quickcmdUI:FindFirstChild("text") then return end
        quickcmdDB = true
        local ti = TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
        TS:Create(quickcmdUI,ti,{Position = UDim2.new(.5,0,0,5)}):Play()
        quickcmdUI.text:CaptureFocus()
        return
    end
    if type(value) ~= "boolean" or not quickcmdUI or binded then return end
    quickcmdActive = value
end

local function initialize()
	local keybindlabel
	local function changeGuiToggleKey(keyText, keyCode)
		keybindlabel.Text = "Bound to: " .. keyText
		CAS:UnbindAction("MenuToggle")
		CAS:BindAction("MenuToggle", toggleGui, false, keyCode)
	end

	local mainGui
	local function createMainGui()
		local keybind = Instance.new("ImageButton")
		local keybindlabelratio = Instance.new("UIAspectRatioConstraint")
		local keybindstroke = Instance.new("UIStroke")
		keybindlabel = Instance.new("TextLabel")

		container = Instance.new("Frame")
		container.Name = "container"
		container.AnchorPoint = Vector2.new(.5, .5)
		container.BackgroundTransparency = 1
		container.Position = UDim2.new(.5, 0, .5, 0)
		container.Size = UDim2.new(1, 0, 1, 0)
		container.ZIndex = 9999
		
		background = Instance.new("ImageButton")
		background.Name = "background"
		background.AnchorPoint = Vector2.new(.5, .5)
		background.Image = "rbxassetid://14407899530"
		background.BackgroundTransparency = 1
		background.ImageTransparency = .2
		background.Position = UDim2.new(.5, 0, .5, 0)
		background.Size = UDim2.new(1, 0, 1, 0)
		background.ZIndex = 9998
		
		local padding = Instance.new("UIPadding")
		padding.Name = "padding"
		padding.Parent = container
		padding.PaddingTop = UDim.new(0, 50)
		
		scrollFrame = Instance.new("ScrollingFrame")
		scrollFrame.Name = "scroll"
		scrollFrame.AnchorPoint = Vector2.new(.5, 0)
		scrollFrame.BackgroundTransparency = 1
		scrollFrame.Position = UDim2.new(0.5, 0, -0.04, 100)
		scrollFrame.Size = UDim2.new(1, -20, 0.8, -110)
		scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scrollFrame.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		scrollFrame.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
		scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
		scrollFrame.ScrollBarImageTransparency = .5
		scrollFrame.ScrollBarThickness = 2
		scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
		scrollFrame.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		scrollFrame.Parent = container
		
		local scrollPadding = Instance.new("UIPadding")
		scrollPadding.Name = "padding"
		scrollPadding.PaddingBottom = UDim.new(0, 5)
		scrollPadding.PaddingLeft = UDim.new(0, 5)
		scrollPadding.PaddingRight = UDim.new(0, 5)
		scrollPadding.PaddingTop = UDim.new(0, 5)
		scrollPadding.Parent = scrollFrame

		local scrollPage = Instance.new("UIPageLayout")
		scrollPage.Name = "page"
		scrollPage.SortOrder = Enum.SortOrder.LayoutOrder
		scrollPage.EasingStyle = Enum.EasingStyle.Quint
		scrollPage.GamepadInputEnabled = false
		scrollPage.ScrollWheelInputEnabled = false
		scrollPage.TouchInputEnabled = false
		scrollPage.Parent = scrollFrame
		uiPages[#uiPages+1] = scrollPage
		
		close = Instance.new("ImageButton")
		close.Name = "close"
		close.Modal = true
		close.BackgroundTransparency = 1
		close.Position = UDim2.new(0, 20, 0, -10)
		close.Size = UDim2.new(0, 50, 0, 50)
		close.Image = ""
		close.Parent = container
		
		local closeIcon = Instance.new("ImageLabel")
		closeIcon.Name = "icon"
		closeIcon.AnchorPoint = Vector2.new(.5, .5)
		closeIcon.BackgroundTransparency = 1
		closeIcon.Position = UDim2.new(.5, 0, .5, 0)
		closeIcon.Size = UDim2.new(.5, 0, .5, 0)
		closeIcon.Image = "rbxassetid://11293981586"
		closeIcon.Parent = close

		keybind.Name = "keybind"
		keybind.AnchorPoint = Vector2.new(.5, .5)
		keybind.Parent = close
		keybind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		keybind.BackgroundTransparency = .9
		keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
		keybind.BorderSizePixel = 0
		keybind.Position = UDim2.new(.5, 0, 1.5, 0)
		keybind.Size = UDim2.new(1.5, 0, 1, 0)
		keybind.ImageTransparency = 1
		
		keybindstroke.Name = "stroke"
		keybindstroke.Parent = keybind
		keybindstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		keybindstroke.Color = Color3.fromRGB(255, 255, 255)
		keybindstroke.LineJoinMode = Enum.LineJoinMode.Miter
		keybindstroke.Thickness = 0
		keybindstroke.Transparency = .8

		keybindlabel.Name = "label"
		keybindlabel.Parent = keybind
		keybindlabel.AnchorPoint = Vector2.new(.5, .5)
		keybindlabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		keybindlabel.BackgroundTransparency = 1
		keybindlabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		keybindlabel.BorderSizePixel = 0
		keybindlabel.Position = UDim2.new(.5, 0, .5, 0)
		keybindlabel.Size = UDim2.new(1, 0, 1, 0)
		keybindlabel.Font = Enum.Font.Montserrat
		keybindlabel.Text = "Bound to: RightShift"
		keybindlabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		keybindlabel.TextSize = 11
		keybindlabel.TextWrapped = true

		keybindlabelratio.Name = "ratio"
		keybindlabelratio.Parent = keybindlabel
		
		headers = Instance.new("Frame")
		headers.Name = "headers"
		headers.Size = UDim2.new(1, 0, 0, 60)
		headers.BackgroundTransparency = 1
		headers.Parent = container
		
		local headersPage = Instance.new("UIPageLayout")
		headersPage.Name = "page"
		headersPage.SortOrder = Enum.SortOrder.LayoutOrder
		headersPage.EasingStyle = Enum.EasingStyle.Cubic
		headersPage.GamepadInputEnabled = false
		headersPage.ScrollWheelInputEnabled = false
		headersPage.TouchInputEnabled = false
		headersPage.Parent = headers
		uiPages[#uiPages+1] = headersPage
		
		nextPrev = Instance.new("Frame")
		nextPrev.Name = "nextprev"
		nextPrev.BackgroundTransparency = 1
		nextPrev.AnchorPoint = Vector2.new(.5, 0)
		nextPrev.Position = UDim2.new(0.5, 0, -0.255, 100)
		nextPrev.Size = UDim2.new(1, -20, 1.14, -110)
		nextPrev.Parent = container
		
		local nextPrevPage = Instance.new("UIPageLayout")
		nextPrevPage.Name = "page"
		nextPrevPage.SortOrder = Enum.SortOrder.LayoutOrder
		nextPrevPage.EasingStyle = Enum.EasingStyle.Cubic
		nextPrevPage.GamepadInputEnabled = false
		nextPrevPage.ScrollWheelInputEnabled = false
		nextPrevPage.TouchInputEnabled = false
		nextPrevPage.Parent = nextPrev
		uiPages[#uiPages+1] = nextPrevPage

		local ver = Instance.new("TextLabel")
		ver.Name = "ver"
		ver.Parent = container
		ver.AnchorPoint = Vector2.new(1, 0)
		ver.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ver.BackgroundTransparency = 1
		ver.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ver.BorderSizePixel = 0
		ver.Position = UDim2.new(1, -20, 0, -10)
		ver.Size = UDim2.new(0, 75, 0, 50)
		ver.Font = Enum.Font.Montserrat
		task.spawn(function()
			while true do
				ver.Text = "InfilSense UI Library - bkkpro1980\n\n"..libName.."\nVersion:\n"..version
				task.wait()
			end
		end)
		ver.TextColor3 = Color3.fromRGB(255, 255, 255)
		ver.TextSize = 14
		ver.TextWrapped = false
		ver.TextXAlignment = Enum.TextXAlignment.Right
		
		mainGui = Instance.new("ScreenGui", COREGUI)
		mainGui.Name = randomString()
		mainGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
		mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		mainGui.ResetOnSpawn = false
		container.Parent = mainGui
		background.Parent = mainGui

		task.spawn(function()
			keybind.MouseEnter:Connect(function()
				TS:Create(keybind, ti, {BackgroundTransparency = .95}):Play()
				TS:Create(keybind.stroke, ti, {Thickness = 2}):Play()
			end)

			keybind.MouseButton1Down:Connect(function()
				TS:Create(keybind, ti, {BackgroundTransparency = .7}):Play()
				TS:Create(keybind.stroke, ti, {Thickness = 3}):Play()
			end)

			keybind.InputEnded:Connect(function()
				TS:Create(keybind, ti, {BackgroundTransparency = .9}):Play()
				TS:Create(keybind.stroke, ti, {Thickness = 0}):Play()
			end)

			if isfile(saveFileLoc..".json") then
				local keyText = loadConfig(saveFileLoc..".json")
				keyText = keyText["MenuToggle"] or "RightShift"
				keybindlabel.Text = "Bound to: " .. keyText
				if isValidKey(keyText) then
					local keyCode = stringToKeyCode(keyText)
					if keyCode then
						changeGuiToggleKey(keyText, keyCode)
					else
						changeGuiToggleKey("RightShift", Enum.KeyCode.RightShift)
					end
				else
					changeGuiToggleKey("RightShift", Enum.KeyCode.RightShift)
				end
			else
				changeGuiToggleKey("RightShift", Enum.KeyCode.RightShift)
			end
			
			local capturingKey = false
			local connection = nil
			keybind.Activated:Connect(function()
				if capturingKey then return end

				capturingKey = true
				keybind.label.Text = "Press a key..."
				local timeout = 5
				local captureStart = tick()

				connection = UIS.InputBegan:Connect(function(input)
					if tick() - captureStart > timeout then
						keybind.label.Text = "Capture Timed Out"
						capturingKey = false
						connection:Disconnect()
						return
					end

					if input then
						if input.UserInputType == Enum.UserInputType.Keyboard then
							print("Binding key for command: " .. "MenuToggle" .. " to key: " .. input.KeyCode.Name)
							configManager.add("MenuToggle",nil,input.KeyCode.Name)
							changeGuiToggleKey(input.KeyCode.Name, input.KeyCode)
						elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
							configManager.add("MenuToggle",nil,"RightShift")
							changeGuiToggleKey("RightShift", Enum.KeyCode.RightShift)
						end
					else
						keybindlabel.Text = "Invalid Input!"
						task.delay(1.5, function()
							if isfile(saveFileLoc..".json") then
								local keyText = loadConfig(saveFileLoc..".json")
								keyText = keyText["MenuToggle"] or "RightShift"
								keybindlabel.Text = "Bound to: " .. keyText
								if isValidKey(keyText) then
									local keyCode = stringToKeyCode(keyText)
									if keyCode then
										changeGuiToggleKey(keyText, keyCode)
									end
								end
							else
								keybindlabel.Text = "Bound to: RightShift"
								configManager.add("MenuToggle",nil,"RightShift")
								changeGuiToggleKey("RightShift", Enum.KeyCode.RightShift)
							end
						end)
					end
					capturingKey = false
					connection:Disconnect()
				end)
				task.delay(timeout, function()
					if capturingKey then
						keybindlabel.Text = "Capture Timed Out"
						task.delay(1.5, function()
							if isfile(saveFileLoc..".json") then
								local keyText = loadConfig(saveFileLoc..".json")
								keyText = keyText["MenuToggle"] or "RightShift"
								keybindlabel.Text = "Bound to: " .. keyText
								if isValidKey(keyText) then
									local keyCode = stringToKeyCode(keyText)
									if keyCode then
										changeGuiToggleKey(keyText, keyCode)
									end
								end
							else
								changeGuiToggleKey("RightShift", Enum.KeyCode.RightShift)
							end
						end)
						capturingKey = false
						if connection then
							connection:Disconnect()
						end
					end
				end)
			end)
		end)
	end

	createMainGui()

	local function createSelectionFrame()
		local selection = Instance.new("Frame")
		local top = Instance.new("Frame")
		local label = Instance.new("TextLabel")
		local UIPadding = Instance.new("UIPadding")
		local close = Instance.new("ImageButton")
		local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		local UIPadding_2 = Instance.new("UIPadding")
		local ImageLabel = Instance.new("ImageLabel")
		local scroll = Instance.new("ScrollingFrame")
		local UIListLayout = Instance.new("UIListLayout")

		selection.Name = "selection"
		selection.Parent = mainGui
		selection.AnchorPoint = Vector2.new(.5, .5)
		selection.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		selection.BackgroundTransparency = .8
		selection.BorderColor3 = Color3.fromRGB(0, 0, 0)
		selection.BorderSizePixel = 0
		selection.Position = UDim2.new(.5, 0, -.5, 0)
		selection.Size = UDim2.new(.5, 0, .5, 0)
		selection.ZIndex = 10000
		selectFrame = selection

		top.Name = "top"
		top.Parent = selection
		top.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
		top.BackgroundTransparency = .7
		top.BorderColor3 = Color3.fromRGB(0, 0, 0)
		top.BorderSizePixel = 0
		top.Position = UDim2.new(0, 0, 0, 0)
		top.Size = UDim2.new(1, 0, 0, 30)

		label.Name = "label"
		label.Parent = top
		label.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
		label.BackgroundTransparency = 1
		label.BorderColor3 = Color3.fromRGB(0, 0, 0)
		label.BorderSizePixel = 0
		label.Size = UDim2.new(1, 0, 1, 0)
		label.Font = Enum.Font.Montserrat
		label.Text = "label"
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextSize = 14
		label.TextXAlignment = Enum.TextXAlignment.Left

		UIPadding.Parent = label
		UIPadding.PaddingLeft = UDim.new(0, 10)

		close.Name = "close"
		close.Parent = top
		close.AnchorPoint = Vector2.new(1, .5)
		close.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
		close.BackgroundTransparency = 1
		close.BorderColor3 = Color3.fromRGB(0, 0, 0)
		close.BorderSizePixel = 0
		close.Position = UDim2.new(1, 0, .5, 0)
		close.Size = UDim2.new(.5, 0, 1, 0)
		close.Modal = false
		selectClose = close

		UIAspectRatioConstraint.Parent = close
		UIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height

		UIPadding_2.Parent = close
		UIPadding_2.PaddingBottom = UDim.new(0, 5)
		UIPadding_2.PaddingLeft = UDim.new(0, 5)
		UIPadding_2.PaddingRight = UDim.new(0, 5)
		UIPadding_2.PaddingTop = UDim.new(0, 5)

		ImageLabel.Parent = close
		ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ImageLabel.BackgroundTransparency = 1
		ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ImageLabel.BorderSizePixel = 0
		ImageLabel.Size = UDim2.new(1, 0, 1, 0)
		ImageLabel.Image = "rbxassetid://11293981586"

		scroll.Name = "scroll"
		scroll.Parent = selection
		scroll.Active = true
		scroll.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
		scroll.BackgroundTransparency = 1
		scroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
		scroll.BorderSizePixel = 0
		scroll.Position = UDim2.new(0, 0, 0, 30)
		scroll.Size = UDim2.new(1, 0, 1, -30)
		scroll.CanvasSize = UDim2.new(0, 0, 1, 0)
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.ScrollBarThickness = 2
		selectScrollFrame = scroll

		UIListLayout.Parent = scroll
		UIListLayout.Padding = UDim.new(0,5)
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

		task.spawn(function()
			close.Activated:Connect(function()
				toggleGui(nil,nil,nil,false)
				toggleSelectionMenu()
				clearSelectionButtons()
			end)
		end)
	end
	createSelectionFrame()

	selectClosed.Changed:Connect(function()
		if selectClosed.Value then
			close.Active = false
			if isfile(saveFileLoc..".json") then
				local keyText = loadConfig(saveFileLoc..".json")
				keyText = keyText["MenuToggle"] or "RightShift"
				keybindlabel.Text = "Bound to: " .. keyText
				if isValidKey(keyText) then
					local keyCode = stringToKeyCode(keyText)
					if keyCode then
						changeGuiToggleKey(keyText, keyCode)
					else
						changeGuiToggleKey("RightShift", Enum.KeyCode.RightShift)
					end
				else
					changeGuiToggleKey("RightShift", Enum.KeyCode.RightShift)
				end
			else
				changeGuiToggleKey("RightShift", Enum.KeyCode.RightShift)
			end
		else
			close.Active = true
			CAS:UnbindAction("MenuToggle")
		end
	end)

	local function createQuickCmdUi()
		quickcmdUI = Instance.new("Frame")
		local text = Instance.new("TextBox")
		local UIPadding = Instance.new("UIPadding")

		quickcmdUI.Name = "quickcmd"
		quickcmdUI.Parent = mainGui
		quickcmdUI.AnchorPoint = Vector2.new(.5, 0)
		quickcmdUI.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		quickcmdUI.BackgroundTransparency = .9
		quickcmdUI.BorderColor3 = Color3.fromRGB(0, 0, 0)
		quickcmdUI.BorderSizePixel = 0
		quickcmdUI.Position = UDim2.new(.5, 0, 0, -50)
		quickcmdUI.Size = UDim2.new(0, 250, 0, 50)

		text.Name = "text"
		text.Parent = quickcmdUI
		text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		text.BackgroundTransparency = .9
		text.BorderColor3 = Color3.fromRGB(0, 0, 0)
		text.BorderSizePixel = 0
		text.Size = UDim2.new(1, 0, 1, 0)
		text.Font = Enum.Font.Montserrat
		text.PlaceholderColor3 = Color3.fromRGB(42, 42, 42)
		text.PlaceholderText = "Command list is in the server"
		text.Text = ""
		text.TextColor3 = Color3.fromRGB(0, 0, 0)
		text.TextSize = 16
		text.TextWrapped = true

		UIPadding.Parent = quickcmdUI
		UIPadding.PaddingBottom = UDim.new(0, 5)
		UIPadding.PaddingLeft = UDim.new(0, 5)
		UIPadding.PaddingRight = UDim.new(0, 5)
		UIPadding.PaddingTop = UDim.new(0, 5)

		text.FocusLost:Connect(function(enter)
			if enter then
				local id = string.split(text.Text, " ")
				local rawCmd = id[1]
				local cmdKey = quickcmdList[tonumber(rawCmd)] and tonumber(rawCmd) or string.lower(rawCmd)

				if quickcmdList[cmdKey] then
					table.remove(id, 1) -- remove the command word

					task.spawn(function()
						local toggleKey = quickcmdList[cmdKey][3]
						values[toggleKey] = not values[toggleKey]

						local func = quickcmdList[cmdKey][1]
						if #id > 0 then
							func(unpack(id)) -- works with 1, 2, 3... args
						else
							func(values[toggleKey])
						end
					end)

					text.Text = ""
				else
					text.Text = "Invalid command ID"
				end

				task.wait(0.5)
			end
			local ti = TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
			TS:Create(quickcmdUI,ti,{Position = UDim2.new(.5,0,0,-50)}):Play()
			quickcmdDB = false
			return
		end)
	end
	createQuickCmdUi()
end

-- Creating tings
local function createPage(pageName)
	pagesAmount = pagesAmount + 1

	local header = Instance.new("TextLabel")
	header.Name = pageName
	header.Text = pageName
	header.LayoutOrder = pagesAmount
	header.AnchorPoint = Vector2.new(.5, 0)
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, 0, 0, 60)
	header.Font = Enum.Font.MontserratMedium
	header.TextSize = 30
	header.TextColor3 = Color3.fromRGB(255, 255, 255)
	header.Parent = headers
	
	local nextPrevPage = Instance.new("Frame")
	nextPrevPage.Name = pageName
	nextPrevPage.BackgroundTransparency = 1
	nextPrevPage.Size = UDim2.new(1, 0, 1, 0)
	nextPrevPage.Parent = nextPrev
	
	local list = Instance.new("UIListLayout")
	list.Name = "list"
	list.Padding = UDim.new(0, 10)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.FillDirection = Enum.FillDirection.Horizontal
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.VerticalAlignment = Enum.VerticalAlignment.Bottom
	list.Parent = nextPrevPage
	
	local _2 = Instance.new("ImageButton")
	local nextLabel = Instance.new("TextLabel")
	local nextPadding = Instance.new("UIPadding")
	local nextIcon = Instance.new("ImageLabel")

	_2.Name = "2"
	_2.Parent = nextPrevPage
	_2.AnchorPoint = Vector2.new(.5, .5)
	_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	_2.BackgroundTransparency = .9
	_2.LayoutOrder = 2
	_2.Size = UDim2.new(0.2, 210, 0, 50)
	_2.AutoButtonColor = false

	nextLabel.Name = "label"
	nextLabel.Parent = _2
	nextLabel.AnchorPoint = Vector2.new(0, .5)
	nextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	nextLabel.BackgroundTransparency = 1
	nextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	nextLabel.BorderSizePixel = 0
	nextLabel.Position = UDim2.new(0, 0, .5, 0)
	nextLabel.Size = UDim2.new(.5, 0, 1, 0)
	nextLabel.Font = Enum.Font.Montserrat
	nextLabel.Text = "Next Page"
	nextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nextLabel.TextSize = 18
	nextLabel.TextXAlignment = Enum.TextXAlignment.Left

	nextPadding.Name = "nextPadding"
	nextPadding.Parent = _2
	nextPadding.PaddingBottom = UDim.new(0, 10)
	nextPadding.PaddingLeft = UDim.new(0, 20)
	nextPadding.PaddingRight = UDim.new(0, 20)
	nextPadding.PaddingTop = UDim.new(0, 10)

	nextIcon.Name = "nextIcon"
	nextIcon.Parent = _2
	nextIcon.AnchorPoint = Vector2.new(1, .5)
	nextIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	nextIcon.BackgroundTransparency = 1
	nextIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	nextIcon.BorderSizePixel = 0
	nextIcon.Position = UDim2.new(1, 0, .5, 0)
	nextIcon.Size = UDim2.new(0, 20, 0, 20)
	nextIcon.Image = "rbxassetid://11422142913"
	nextIcon.ImageTransparency = .5
	
	local _1 = Instance.new("ImageButton")
	local prevLabel = Instance.new("TextLabel")
	local prevPadding = Instance.new("UIPadding")
	local icon = Instance.new("ImageLabel")

	_1.Name = "1"
	_1.Parent = nextPrevPage
	_1.AnchorPoint = Vector2.new(.5, .5)
	_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	_1.BackgroundTransparency = .9
	_1.LayoutOrder = 1
	_1.Size = UDim2.new(0.2, 210, 0, 50)
	_1.AutoButtonColor = false

	prevLabel.Name = "label"
	prevLabel.Parent = _1
	prevLabel.AnchorPoint = Vector2.new(0, .5)
	prevLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	prevLabel.BackgroundTransparency = 1
	prevLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	prevLabel.BorderSizePixel = 0
	prevLabel.Position = UDim2.new(0, 0, .5, 0)
	prevLabel.Size = UDim2.new(.5, 0, 1, 0)
	prevLabel.Font = Enum.Font.Montserrat
	prevLabel.Text = "Previous Page"
	prevLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	prevLabel.TextSize = 18
	prevLabel.TextXAlignment = Enum.TextXAlignment.Left

	prevPadding.Name = "prevPadding"
	prevPadding.Parent = _1
	prevPadding.PaddingBottom = UDim.new(0, 10)
	prevPadding.PaddingLeft = UDim.new(0, 20)
	prevPadding.PaddingRight = UDim.new(0, 20)
	prevPadding.PaddingTop = UDim.new(0, 10)

	icon.Name = "icon"
	icon.Parent = _1
	icon.AnchorPoint = Vector2.new(1, .5)
	icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	icon.BackgroundTransparency = 1
	icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	icon.BorderSizePixel = 0
	icon.Position = UDim2.new(1, 0, .5, 0)
	icon.Size = UDim2.new(0, 20, 0, 20)
	icon.Image = "rbxassetid://11422143469"
	icon.ImageTransparency = .5
	
	local mainPage = Instance.new("Frame")
	local mainList = Instance.new("UIListLayout")
	
	mainPage.Name = pageName
	mainPage.Parent = scrollFrame
	mainPage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	mainPage.BackgroundTransparency = 1.000
	mainPage.BorderColor3 = Color3.fromRGB(0, 0, 0)
	mainPage.BorderSizePixel = 0
	mainPage.Size = UDim2.new(1, 0, 1, 0)
	
	mainList.Name = "list"
	mainList.Parent = mainPage
	mainList.SortOrder = Enum.SortOrder.LayoutOrder
	mainList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	mainList.Padding = UDim.new(0, 10)
	
	task.spawn(function()
		_2.Activated:Connect(function()
			if pageNum ~= lastPageNum then
				for _, uiPage in ipairs(uiPages) do
					uiPage:Next()
				end
				pageNum = pageNum + 1
				local _2 = nextPrev:FindFirstChildOfClass("UIPageLayout").CurrentPage:FindFirstChild("2")
				local _1 = nextPrev:FindFirstChildOfClass("UIPageLayout").CurrentPage:FindFirstChild("1")
				updateButtons(_2, _1)

				local currentPage = scrollFrame:FindFirstChildOfClass("UIPageLayout") and scrollFrame:FindFirstChildOfClass("UIPageLayout").CurrentPage
				for _, vv in ipairs(scrollFrame:GetChildren()) do
					if vv:IsA("Frame") and vv == currentPage then
						for _, vvv in ipairs(vv:GetChildren()) do
							if vvv:IsA("ImageButton") then
								vvv.Visible = true
							end
						end
					end
				end
				task.wait(.5)
				for _, vv in ipairs(scrollFrame:GetChildren()) do
					if vv:IsA("Frame") and vv ~= currentPage then
						for _, vvv in ipairs(vv:GetChildren()) do
							if vvv:IsA("ImageButton") then
								vvv.Visible = false
							end
						end
					end
				end
			end
		end)
		_1.Activated:Connect(function()
			if pageNum ~= 1 then
				for _, uiPage in ipairs(uiPages) do
					uiPage:Previous()
				end
				pageNum = pageNum - 1
				local _2 = nextPrev:FindFirstChildOfClass("UIPageLayout").CurrentPage:FindFirstChild("2")
				local _1 = nextPrev:FindFirstChildOfClass("UIPageLayout").CurrentPage:FindFirstChild("1")
				updateButtons(_2, _1)

				local currentPage = scrollFrame:FindFirstChildOfClass("UIPageLayout") and scrollFrame:FindFirstChildOfClass("UIPageLayout").CurrentPage
				for _, vv in ipairs(scrollFrame:GetChildren()) do
					if vv:IsA("Frame") and vv == currentPage then
						for _, vvv in ipairs(vv:GetChildren()) do
							if vvv:IsA("ImageButton") then
								vvv.Visible = true
							end
						end
					end
				end
				task.wait(.5)
				for _, vv in ipairs(scrollFrame:GetChildren()) do
					if vv:IsA("Frame") and vv ~= currentPage then
						for _, vvv in ipairs(vv:GetChildren()) do
							if vvv:IsA("ImageButton") then
								vvv.Visible = false
							end
						end
					end
				end
			end
		end)
	end)

	return mainPage
end

local function createButton(...)
	local args = {...}

	local buttonInfo = args[1]
	if type(buttonInfo) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end
	local buttonName = buttonInfo["Title"] or "Title not specified"
	local buttonDesc = buttonInfo["Desc"] or "Description not specified"
	local buttonText = buttonInfo["Action"] or "Action not specified"

	local commandFunc = args[2]
	if type(commandFunc) ~= "function" then warn("["..libName.."]: Invalid Arguments!"); return end

	local otherInfo = args[3]
	if type(otherInfo) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end
	local command = otherInfo["UniqueCommandId"]
	local canStartup = otherInfo["StartupAvailable"]
	local bind = otherInfo["Bindable"]

	local mainPage = args[4]
	if not mainPage then warn("["..libName.."]: Something went wrong while trying to create a button!"); return end

	local Button = Instance.new("ImageButton")
	local padding = Instance.new("UIPadding")
	local stroke = Instance.new("UIStroke")
	local label = Instance.new("TextLabel")
	local value = Instance.new("TextLabel")
	local desc = Instance.new("TextLabel")
	local startup = Instance.new("ImageButton")
	local startupimage = Instance.new("ImageLabel")
	local startupimageratio = Instance.new("UIAspectRatioConstraint")
	local startupstroke = Instance.new("UIStroke")
	local startuplabel = Instance.new("TextLabel")
	local keybind = Instance.new("ImageButton")
	local keybindlabelratio = Instance.new("UIAspectRatioConstraint")
	local keybindstroke = Instance.new("UIStroke")
	local keybindlabel = Instance.new("TextLabel")
	
	Button.Name = "Button"
	Button.LayoutOrder = #mainPage:GetChildren()
	Button.Parent = mainPage
	Button.AnchorPoint = Vector2.new(.5, .5)
	Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Button.BackgroundTransparency = .9
	Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Button.BorderSizePixel = 0
	Button.LayoutOrder = 1
	Button.Size = UDim2.new(0.2, 420, 0, 50)
	Button.AutoButtonColor = false

	padding.Name = "padding"
	padding.Parent = Button
	padding.PaddingBottom = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 20)
	padding.PaddingRight = UDim.new(0, 20)
	padding.PaddingTop = UDim.new(0, 10)
	
	stroke.Name = "stroke"
	stroke.Parent = Button
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.LineJoinMode = Enum.LineJoinMode.Miter
	stroke.Thickness = 0
	stroke.Transparency = .8

	label.Name = "label"
	label.Parent = Button
	label.AnchorPoint = Vector2.new(0, .5)
	label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	label.BackgroundTransparency = 1
	label.BorderColor3 = Color3.fromRGB(0, 0, 0)
	label.BorderSizePixel = 0
	label.Position = UDim2.new(0, 0, .25, 0)
	label.Size = UDim2.new(.5, 0, 1, 0)
	label.Font = Enum.Font.Montserrat
	label.Text = buttonName
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 18
	label.TextTransparency = .1
	label.TextXAlignment = Enum.TextXAlignment.Left

	value.Name = "value"
	value.Parent = Button
	value.AnchorPoint = Vector2.new(1, .5)
	value.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	value.BackgroundTransparency = 1
	value.BorderColor3 = Color3.fromRGB(0, 0, 0)
	value.BorderSizePixel = 0
	value.Position = UDim2.new(1, 0, .5, 0)
	value.Size = UDim2.new(.5, 0, 1, 0)
	value.Font = Enum.Font.Montserrat
	value.Text = buttonText
	value.TextColor3 = Color3.fromRGB(255, 255, 255)
	value.TextSize = 18
	value.TextTransparency = .5
	value.TextXAlignment = Enum.TextXAlignment.Right

	desc.Name = "desc"
	desc.Parent = Button
	desc.AnchorPoint = Vector2.new(0, .5)
	desc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	desc.BackgroundTransparency = 1
	desc.BorderColor3 = Color3.fromRGB(0, 0, 0)
	desc.BorderSizePixel = 0
	desc.Position = UDim2.new(0, 0, .8, 0)
	desc.Size = UDim2.new(.5, 0, 1, 0)
	desc.Font = Enum.Font.Montserrat
	desc.Text = buttonDesc
	desc.TextColor3 = Color3.fromRGB(255, 255, 255)
	desc.TextSize = 14
	desc.TextTransparency = .1
	desc.TextXAlignment = Enum.TextXAlignment.Left

	if canStartup then
		startup.Name = "startup"
		startup.Parent = Button
		startup.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		startup.BackgroundTransparency = .9
		startup.BorderColor3 = Color3.fromRGB(0, 0, 0)
		startup.BorderSizePixel = 0
		startup.Position = UDim2.new(-.141, 0, -.333, 0)
		startup.Size = UDim2.new(.09, 0, 1.667, 0)
		startup.ImageTransparency = 1
		
		startupstroke.Name = "stroke"
		startupstroke.Parent = startup
		startupstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		startupstroke.Color = Color3.fromRGB(255, 255, 255)
		startupstroke.LineJoinMode = Enum.LineJoinMode.Miter
		startupstroke.Thickness = 0
		startupstroke.Transparency = .8

		startupimage.Name = "image"
		startupimage.Parent = startup
		startupimage.AnchorPoint = Vector2.new(0.5, .5)
		startupimage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		startupimage.BackgroundTransparency = 1
		startupimage.BorderColor3 = Color3.fromRGB(0, 0, 0)
		startupimage.BorderSizePixel = 0
		startupimage.Position = UDim2.new(.5, 0, .4, 0)
		startupimage.Size = UDim2.new(.5, 0, .5, 0)
		startupimage.Image = "rbxassetid://14187539043"

		startuplabel.Name = "label"
		startuplabel.Parent = startup
		startuplabel.AnchorPoint = Vector2.new(.5, .5)
		startuplabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		startuplabel.BackgroundTransparency = 1
		startuplabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		startuplabel.BorderSizePixel = 0
		startuplabel.Position = UDim2.new(.5, 0, .8, 0)
		startuplabel.Size = UDim2.new(1, 0, 1, 0)
		startuplabel.Font = Enum.Font.Montserrat
		startuplabel.Text = "Startup?"
		startuplabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		startuplabel.TextSize = 11

		startupimageratio.Name = "ratio"
		startupimageratio.Parent = startupimage

		local config = savedData["Startup"] and savedData["Startup"][command]
		if config == true then
			startupimage.Image = "rbxassetid://14187538370"
			task.spawn(function()
				commandFunc(values[command])
			end)
		end
	end

	if bind then
		keybind.Name = "keybind"
		keybind.Parent = Button
		keybind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		keybind.BackgroundTransparency = .9
		keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
		keybind.BorderSizePixel = 0
		keybind.Position = UDim2.new(1.052, 0, -.366, 0)
		keybind.Size = UDim2.new(.09, 0, 1.666, 0)
		keybind.ImageTransparency = 1

		keybindstroke.Name = "stroke"
		keybindstroke.Parent = keybind
		keybindstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		keybindstroke.Color = Color3.fromRGB(255, 255, 255)
		keybindstroke.LineJoinMode = Enum.LineJoinMode.Miter
		keybindstroke.Thickness = 0
		keybindstroke.Transparency = .8

		keybindlabel.Name = "label"
		keybindlabel.Parent = keybind
		keybindlabel.AnchorPoint = Vector2.new(.5, .5)
		keybindlabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		keybindlabel.BackgroundTransparency = 1
		keybindlabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		keybindlabel.BorderSizePixel = 0
		keybindlabel.Position = UDim2.new(.5, 0, .5, 0)
		keybindlabel.Size = UDim2.new(1, 0, 1, 0)
		keybindlabel.Font = Enum.Font.Montserrat
		keybindlabel.Text = "Click To Set A Keybind"
		keybindlabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		keybindlabel.TextSize = 11
		keybindlabel.TextWrapped = true

		keybindlabelratio.Name = "ratio"
		keybindlabelratio.Parent = keybindlabel

		local config = savedData["Keybinds"] and savedData["Keybinds"][command]
		if config and type(config) == "string" and isValidKey(config) then
			keybindlabel.Text = "Bound to: " .. tostring(config)
			local keyCode = stringToKeyCode(config)
			task.spawn(function()
				manageKeybind(command,commandFunc,keyCode)
			end)
		end
	end
	
	task.spawn(function()
		values[command] = false

		Button.MouseEnter:Connect(function()
			TS:Create(Button, ti, {BackgroundTransparency = .95}):Play()
			TS:Create(Button.stroke, ti, {Thickness = 2}):Play()
		end)

		Button.MouseButton1Down:Connect(function()
			TS:Create(Button, ti, {BackgroundTransparency = .7}):Play()
			TS:Create(Button.stroke, ti, {Thickness = 3}):Play()
		end)

		Button.InputEnded:Connect(function()
			TS:Create(Button, ti, {BackgroundTransparency = .9}):Play()
			TS:Create(Button.stroke, ti, {Thickness = 0}):Play()
		end)
		
		Button.Activated:Connect(function()
			values[command] = not values[command]
			commandFunc(values[command])
		end)

		if canStartup then
			startup.MouseEnter:Connect(function()
				TS:Create(startup, ti, {BackgroundTransparency = .95}):Play()
				TS:Create(startup.stroke, ti, {Thickness = 2}):Play()
			end)

			startup.MouseButton1Down:Connect(function()
				TS:Create(startup, ti, {BackgroundTransparency = .7}):Play()
				TS:Create(startup.stroke, ti, {Thickness = 3}):Play()
			end)

			startup.InputEnded:Connect(function()
				TS:Create(startup, ti, {BackgroundTransparency = .9}):Play()
				TS:Create(startup.stroke, ti, {Thickness = 0}):Play()
			end)
			
			startup.Activated:Connect(function()
				if startupFunc(command) then
					startupimage.Image = "rbxassetid://14187538370"
				else
					startupimage.Image = "rbxassetid://14187539043"
				end
			end)
		end

		if bind then
			keybind.MouseEnter:Connect(function()
				TS:Create(keybind, ti, {BackgroundTransparency = .95}):Play()
				TS:Create(keybind.stroke, ti, {Thickness = 2}):Play()
			end)

			keybind.MouseButton1Down:Connect(function()
				TS:Create(keybind, ti, {BackgroundTransparency = .7}):Play()
				TS:Create(keybind.stroke, ti, {Thickness = 3}):Play()
			end)

			keybind.InputEnded:Connect(function()
				TS:Create(keybind, ti, {BackgroundTransparency = .9}):Play()
				TS:Create(keybind.stroke, ti, {Thickness = 0}):Play()
			end)
			
			local capturingKey = false
			local connection = nil
			keybind.Activated:Connect(function()
				bindKey(capturingKey,connection,keybindlabel,command,commandFunc)
			end)
		end
	end)
end

local function createTextBox(...)
	local args = {...}

	local buttonInfo = args[1]
	if type(buttonInfo) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end
	local buttonName = buttonInfo["Title"] or "Title not specified"
	local buttonDesc = buttonInfo["Desc"] or "Description not specified"
	local buttonText = buttonInfo["Action"] or "Action not specified"

	local commandFunc = args[2]
	if type(commandFunc) ~= "function" then warn("["..libName.."]: Invalid Arguments!"); return end

	local otherInfo = args[3]
	if type(otherInfo) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end
	local command = otherInfo["UniqueCommandId"]
	local canStartup = otherInfo["StartupAvailable"]
	local bind = otherInfo["Bindable"]

	local mainPage = args[4]
	if not mainPage then warn("["..libName.."]: Something went wrong while trying to create a button!"); return end
	
	local Button = Instance.new("ImageButton")
	local padding = Instance.new("UIPadding")
	local stroke = Instance.new("UIStroke")
	local label = Instance.new("TextLabel")
	local textbox = Instance.new("TextBox")
	local desc = Instance.new("TextLabel")
	local startup = Instance.new("ImageButton")
	local startupimage = Instance.new("ImageLabel")
	local startupimageratio = Instance.new("UIAspectRatioConstraint")
	local startupstroke = Instance.new("UIStroke")
	local startuplabel = Instance.new("TextLabel")
	local keybind = Instance.new("ImageButton")
	local keybindlabelratio = Instance.new("UIAspectRatioConstraint")
	local keybindstroke = Instance.new("UIStroke")
	local keybindlabel = Instance.new("TextLabel")

	Button.Name = "TextBox"
	Button.LayoutOrder = #mainPage:GetChildren()
	Button.Parent = mainPage
	Button.AnchorPoint = Vector2.new(.5, .5)
	Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Button.BackgroundTransparency = .9
	Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Button.BorderSizePixel = 0
	Button.LayoutOrder = 1
	Button.Size = UDim2.new(0.2, 420, 0, 50)
	Button.AutoButtonColor = false

	padding.Name = "padding"
	padding.Parent = Button
	padding.PaddingBottom = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 20)
	padding.PaddingRight = UDim.new(0, 20)
	padding.PaddingTop = UDim.new(0, 10)

	stroke.Name = "stroke"
	stroke.Parent = Button
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.LineJoinMode = Enum.LineJoinMode.Miter
	stroke.Thickness = 0
	stroke.Transparency = .8

	label.Name = "label"
	label.Parent = Button
	label.AnchorPoint = Vector2.new(0, .5)
	label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	label.BackgroundTransparency = 1
	label.BorderColor3 = Color3.fromRGB(0, 0, 0)
	label.BorderSizePixel = 0
	label.Position = UDim2.new(0, 0, .25, 0)
	label.Size = UDim2.new(.5, 0, 1, 0)
	label.Font = Enum.Font.Montserrat
	label.Text = buttonName
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 18
	label.TextTransparency = .1
	label.TextXAlignment = Enum.TextXAlignment.Left

	textbox.Parent = Button
	textbox.AnchorPoint = Vector2.new(1, .5)
	textbox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	textbox.BackgroundTransparency = 1
	textbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
	textbox.BorderSizePixel = 0
	textbox.Position = UDim2.new(1, 0, .5, 0)
	textbox.Size = UDim2.new(.3, 0, 1, 0)
	textbox.Font = Enum.Font.Montserrat
	textbox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
	textbox.PlaceholderText = buttonText
	textbox.Text = ""
	textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
	textbox.TextSize = 18
	textbox.TextXAlignment = Enum.TextXAlignment.Right

	desc.Name = "desc"
	desc.Parent = Button
	desc.AnchorPoint = Vector2.new(0, .5)
	desc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	desc.BackgroundTransparency = 1
	desc.BorderColor3 = Color3.fromRGB(0, 0, 0)
	desc.BorderSizePixel = 0
	desc.Position = UDim2.new(0, 0, .8, 0)
	desc.Size = UDim2.new(.5, 0, 1, 0)
	desc.Font = Enum.Font.Montserrat
	desc.Text = buttonDesc
	desc.TextColor3 = Color3.fromRGB(255, 255, 255)
	desc.TextSize = 14
	desc.TextTransparency = .1
	desc.TextXAlignment = Enum.TextXAlignment.Left

	if canStartup then
		startup.Name = "startup"
		startup.Parent = Button
		startup.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		startup.BackgroundTransparency = .9
		startup.BorderColor3 = Color3.fromRGB(0, 0, 0)
		startup.BorderSizePixel = 0
		startup.Position = UDim2.new(-.141, 0, -.333, 0)
		startup.Size = UDim2.new(.09, 0, 1.667, 0)
		startup.ImageTransparency = 1
		
		startupstroke.Name = "stroke"
		startupstroke.Parent = startup
		startupstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		startupstroke.Color = Color3.fromRGB(255, 255, 255)
		startupstroke.LineJoinMode = Enum.LineJoinMode.Miter
		startupstroke.Thickness = 0
		startupstroke.Transparency = .8

		startupimage.Name = "image"
		startupimage.Parent = startup
		startupimage.AnchorPoint = Vector2.new(0.5, .5)
		startupimage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		startupimage.BackgroundTransparency = 1
		startupimage.BorderColor3 = Color3.fromRGB(0, 0, 0)
		startupimage.BorderSizePixel = 0
		startupimage.Position = UDim2.new(.5, 0, .4, 0)
		startupimage.Size = UDim2.new(.5, 0, .5, 0)
		startupimage.Image = "rbxassetid://14187539043"

		startuplabel.Name = "label"
		startuplabel.Parent = startup
		startuplabel.AnchorPoint = Vector2.new(.5, .5)
		startuplabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		startuplabel.BackgroundTransparency = 1
		startuplabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		startuplabel.BorderSizePixel = 0
		startuplabel.Position = UDim2.new(.5, 0, .8, 0)
		startuplabel.Size = UDim2.new(1, 0, 1, 0)
		startuplabel.Font = Enum.Font.Montserrat
		startuplabel.Text = "Startup?"
		startuplabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		startuplabel.TextSize = 11

		startupimageratio.Name = "ratio"
		startupimageratio.Parent = startupimage

		local config = savedData["Startup"] and savedData["Startup"][command]
		if config == true then
			startupimage.Image = "rbxassetid://14187538370"
			task.spawn(function()
				commandFunc(values[command])
			end)
		end
	end

	if bind then
		keybind.Name = "keybind"
		keybind.Parent = Button
		keybind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		keybind.BackgroundTransparency = .9
		keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
		keybind.BorderSizePixel = 0
		keybind.Position = UDim2.new(1.052, 0, -.366, 0)
		keybind.Size = UDim2.new(.09, 0, 1.666, 0)
		keybind.ImageTransparency = 1

		keybindstroke.Name = "stroke"
		keybindstroke.Parent = keybind
		keybindstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		keybindstroke.Color = Color3.fromRGB(255, 255, 255)
		keybindstroke.LineJoinMode = Enum.LineJoinMode.Miter
		keybindstroke.Thickness = 0
		keybindstroke.Transparency = .8

		keybindlabel.Name = "label"
		keybindlabel.Parent = keybind
		keybindlabel.AnchorPoint = Vector2.new(.5, .5)
		keybindlabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		keybindlabel.BackgroundTransparency = 1
		keybindlabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		keybindlabel.BorderSizePixel = 0
		keybindlabel.Position = UDim2.new(.5, 0, .5, 0)
		keybindlabel.Size = UDim2.new(1, 0, 1, 0)
		keybindlabel.Font = Enum.Font.Montserrat
		keybindlabel.Text = "Click To Set A Keybind"
		keybindlabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		keybindlabel.TextSize = 11
		keybindlabel.TextWrapped = true

		keybindlabelratio.Name = "ratio"
		keybindlabelratio.Parent = keybindlabel

		local config = savedData["Keybinds"] and savedData["Keybinds"][command]
		if config and type(config) == "string" and isValidKey(config) then
			keybindlabel.Text = "Bound to: " .. tostring(config)
			local keyCode = stringToKeyCode(config)
			task.spawn(function()
				manageKeybind(command,commandFunc,keyCode)
			end)
		end
	end

	task.spawn(function()
		Button.MouseEnter:Connect(function()
			TS:Create(Button, ti, {BackgroundTransparency = .95}):Play()
			TS:Create(Button.stroke, ti, {Thickness = 2}):Play()
		end)

		Button.MouseButton1Down:Connect(function()
			TS:Create(Button, ti, {BackgroundTransparency = .7}):Play()
			TS:Create(Button.stroke, ti, {Thickness = 3}):Play()
		end)

		Button.InputEnded:Connect(function()
			TS:Create(Button, ti, {BackgroundTransparency = .9}):Play()
			TS:Create(Button.stroke, ti, {Thickness = 0}):Play()
		end)

		Button.Activated:Connect(function()
			commandFunc(textbox.Text)
		end)
		
		textbox.FocusLost:Connect(function()
			if textbox.Text ~= "" then
				commandFunc(textbox.Text)
			end
		end)

		if canStartup then
			startup.MouseEnter:Connect(function()
				TS:Create(startup, ti, {BackgroundTransparency = .95}):Play()
				TS:Create(startup.stroke, ti, {Thickness = 2}):Play()
			end)

			startup.MouseButton1Down:Connect(function()
				TS:Create(startup, ti, {BackgroundTransparency = .7}):Play()
				TS:Create(startup.stroke, ti, {Thickness = 3}):Play()
			end)

			startup.InputEnded:Connect(function()
				TS:Create(startup, ti, {BackgroundTransparency = .9}):Play()
				TS:Create(startup.stroke, ti, {Thickness = 0}):Play()
			end)
			
			startup.Activated:Connect(function()
				if startupFunc(command) then
					startupimage.Image = "rbxassetid://14187538370"
				else
					startupimage.Image = "rbxassetid://14187539043"
				end
			end)
		end

		if bind then
			keybind.MouseEnter:Connect(function()
				TS:Create(keybind, ti, {BackgroundTransparency = .95}):Play()
				TS:Create(keybind.stroke, ti, {Thickness = 2}):Play()
			end)

			keybind.MouseButton1Down:Connect(function()
				TS:Create(keybind, ti, {BackgroundTransparency = .7}):Play()
				TS:Create(keybind.stroke, ti, {Thickness = 3}):Play()
			end)

			keybind.InputEnded:Connect(function()
				TS:Create(keybind, ti, {BackgroundTransparency = .9}):Play()
				TS:Create(keybind.stroke, ti, {Thickness = 0}):Play()
			end)
			
			local capturingKey = false
			local connection = nil
			keybind.Activated:Connect(function()
				bindKey(capturingKey,connection,keybindlabel,command,commandFunc)
			end)
		end
	end)

	return textbox
end

local function createSelection(...)
	local args = {...}

	local buttonInfo = args[1]
	if type(buttonInfo) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end
	local buttonName = buttonInfo["Title"] or "Title not specified"
	local buttonDesc = buttonInfo["Desc"] or "Description not specified"
	local buttonText = buttonInfo["Action"] or "Action not specified"

	local commandFunc = args[2]
	if type(commandFunc) ~= "function" then warn("["..libName.."]: Invalid Arguments!"); return end

	local otherInfo = args[3]
	if type(otherInfo) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end
	local command = otherInfo["UniqueCommandId"]
	--local canStartup = otherInfo["StartupAvailable"]
	--local bind = otherInfo["Bindable"]

	local mainPage = args[4]
	if not mainPage then warn("["..libName.."]: Something went wrong while trying to create a button!"); return end

	if not args[5] or type(args[5]) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end
	
	local Button = Instance.new("ImageButton")
	local padding = Instance.new("UIPadding")
	local stroke = Instance.new("UIStroke")
	local label = Instance.new("TextLabel")
	local desc = Instance.new("TextLabel")
	local value = Instance.new("ImageButton")
	local value_2 = Instance.new("TextLabel")
	local selected = Instance.new("StringValue")

	Button.Name = "Selection"
	Button.LayoutOrder = #mainPage:GetChildren()
	Button.Parent = mainPage
	Button.AnchorPoint = Vector2.new(0.5, 0.5)
	Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Button.BackgroundTransparency = 0.900
	Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Button.BorderSizePixel = 0
	Button.LayoutOrder = 3
	Button.Size = UDim2.new(0.2, 420, 0, 50)
	Button.AutoButtonColor = false

	padding.Name = "padding"
	padding.Parent = Button
	padding.PaddingBottom = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 20)
	padding.PaddingRight = UDim.new(0, 20)
	padding.PaddingTop = UDim.new(0, 10)

	stroke.Name = "stroke"
	stroke.Parent = Button
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.LineJoinMode = Enum.LineJoinMode.Miter
	stroke.Thickness = 0
	stroke.Transparency = .8

	label.Name = "label"
	label.Parent = Button
	label.AnchorPoint = Vector2.new(0, .5)
	label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	label.BackgroundTransparency = 1
	label.BorderColor3 = Color3.fromRGB(0, 0, 0)
	label.BorderSizePixel = 0
	label.Position = UDim2.new(0, 0, .25, 0)
	label.Size = UDim2.new(.5, 0, 1, 0)
	label.Font = Enum.Font.Montserrat
	label.Text = buttonName
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 18
	label.TextTransparency = .1
	label.TextXAlignment = Enum.TextXAlignment.Left

	desc.Name = "desc"
	desc.Parent = Button
	desc.AnchorPoint = Vector2.new(0, .5)
	desc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	desc.BackgroundTransparency = 1
	desc.BorderColor3 = Color3.fromRGB(0, 0, 0)
	desc.BorderSizePixel = 0
	desc.Position = UDim2.new(0, 0, .8, 0)
	desc.Size = UDim2.new(.5, 0, 1, 0)
	desc.Font = Enum.Font.Montserrat
	desc.Text = buttonDesc
	desc.TextColor3 = Color3.fromRGB(255, 255, 255)
	desc.TextSize = 14
	desc.TextTransparency = .1
	desc.TextXAlignment = Enum.TextXAlignment.Left

	value.Name = "value"
	value.Parent = Button
	value.AnchorPoint = Vector2.new(1, .5)
	value.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	value.BackgroundTransparency = 1
	value.BorderColor3 = Color3.fromRGB(0, 0, 0)
	value.BorderSizePixel = 0
	value.Position = UDim2.new(1, 0, .5, 0)
	value.Size = UDim2.new(.5, 0, 1, 15)
	value.ImageTransparency = 1

	value_2.Name = "value"
	value_2.Parent = value
	value_2.AnchorPoint = Vector2.new(1, .5)
	value_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	value_2.BackgroundTransparency = 1
	value_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	value_2.BorderSizePixel = 0
	value_2.Position = UDim2.new(1, 0, .5, 0)
	value_2.Size = UDim2.new(1, 0, 1, 0)
	value_2.Font = Enum.Font.Montserrat
	value_2.Text = buttonText
	value_2.TextColor3 = Color3.fromRGB(255, 255, 255)
	value_2.TextSize = 18
	value_2.TextTransparency = .5
	value_2.TextWrapped = true
	value_2.TextXAlignment = Enum.TextXAlignment.Right

	selected.Name = "selected"
	selected.Parent = value

	task.spawn(function()
		Button.MouseEnter:Connect(function()
			TS:Create(Button, ti, {BackgroundTransparency = .95}):Play()
			TS:Create(Button.stroke, ti, {Thickness = 2}):Play()
		end)

		Button.MouseButton1Down:Connect(function()
			TS:Create(Button, ti, {BackgroundTransparency = .7}):Play()
			TS:Create(Button.stroke, ti, {Thickness = 3}):Play()
		end)

		Button.InputEnded:Connect(function()
			TS:Create(Button, ti, {BackgroundTransparency = .9}):Play()
			TS:Create(Button.stroke, ti, {Thickness = 0}):Play()
		end)

		Button.Activated:Connect(function()
			commandFunc(selected.Value)
		end)

		selected.Changed:Connect(function()
			value_2.Text = selected.Value
			values[command] = selected.Value
		end)

		value.Activated:Connect(function()
			createSelectionButtons(args[5],selected)
			toggleGui(nil,nil,nil,false)
			toggleSelectionMenu(buttonName)
		end)
	end)
end

local function createSlider(...)
	local args = {...}

	local buttonInfo = args[1]
	if type(buttonInfo) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end
	local buttonName = buttonInfo["Title"] or "Title not specified"
	local buttonDesc = buttonInfo["Desc"] or "Description not specified"
	--local buttonText = buttonInfo["Action"] or "Action not specified"

	local commandFunc = args[2]
	if type(commandFunc) ~= "function" then warn("["..libName.."]: Invalid Arguments!"); return end

	local otherInfo = args[3]
	if type(otherInfo) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end
	local command = otherInfo["UniqueCommandId"]
	local willStartup = otherInfo["StartupAvailable"]
	local bind = otherInfo["Bindable"]

	local mainPage = args[4]
	if not mainPage then warn("["..libName.."]: Something went wrong while trying to create a button!"); return end

	local settings = args[5]
	if not settings or type(settings) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end
	local sliderType = settings["sliderType"]
	local defValue = settings["defVal"]
	local lowVal = settings["lowVal"]
	local maxVal = settings["maxVal"]
	local shouldSave = settings["save"]
	if not (defValue and lowVal and maxVal) then warn("["..libName.."]: Invalid Arguments!"); return end

	local Button = Instance.new("ImageButton")
	local padding = Instance.new("UIPadding")
	local stroke = Instance.new("UIStroke")
	local label = Instance.new("TextLabel")
	local sliderTrack = Instance.new("Frame")
	local sliderThumb = Instance.new("ImageButton")
	local desc = Instance.new("TextLabel")
	local keybind = Instance.new("ImageButton")
	local keybindstroke = Instance.new("UIStroke")
	local keybindlabel = Instance.new("TextLabel")
	local keybindlabelratio = Instance.new("UIAspectRatioConstraint")
	
	Button.Name = "Slider"
	Button.LayoutOrder = #mainPage:GetChildren()
	Button.Parent = mainPage
	Button.AnchorPoint = Vector2.new(0.5, 0.5)
	Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Button.BackgroundTransparency = 0.9
	Button.BorderSizePixel = 0
	Button.Size = UDim2.new(0.2, 420, 0, 50)
	Button.AutoButtonColor = false

	padding.PaddingBottom = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 20)
	padding.PaddingRight = UDim.new(0, 20)
	padding.PaddingTop = UDim.new(0, 10)
	padding.Parent = Button

	stroke.Name = "stroke"
	stroke.Parent = Button
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.LineJoinMode = Enum.LineJoinMode.Miter
	stroke.Thickness = 0
	stroke.Transparency = .8

	label.Name = "label"
	label.AnchorPoint = Vector2.new(0, 0.5)
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 0, 0.25, 0)
	label.Size = UDim2.new(0.5, 0, 1, 0)
	label.Font = Enum.Font.Montserrat
	label.Text = buttonName .. ": " .. (sliderType == "bool" and tostring(defValue > .5) or tostring(defValue))
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 18
	label.TextTransparency = 0.1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = Button

	sliderTrack.Name = "slider"
	sliderTrack.AnchorPoint = Vector2.new(0.5, 1)
	sliderTrack.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sliderTrack.BackgroundTransparency = 0.5
	sliderTrack.BorderSizePixel = 0
	sliderTrack.Position = UDim2.new(0.5, 0, 1, 0)
	sliderTrack.Size = UDim2.new(1, 0, 0, 2)
	sliderTrack.Parent = Button

	sliderThumb.Name = "thumb"
	sliderThumb.AnchorPoint = Vector2.new(.5, .5)
	sliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sliderThumb.BackgroundTransparency = .5
	sliderThumb.BorderSizePixel = 0
	sliderThumb.Size = UDim2.new(0, 20, 0, 15)
	sliderThumb.Image = ""
	sliderThumb.ImageTransparency = 1
	sliderThumb.Position = UDim2.new((defValue - lowVal)/(maxVal - lowVal), 0, .5, 0)
	sliderThumb.Parent = sliderTrack

	desc.Name = "desc"
	desc.AnchorPoint = Vector2.new(1, .5)
	desc.BackgroundTransparency = 1
	desc.Position = UDim2.new(1, 0, .3, 0)
	desc.Size = UDim2.new(.5, 0, 1, 0)
	desc.Font = Enum.Font.Montserrat
	desc.Text = buttonDesc
	desc.TextColor3 = Color3.fromRGB(255, 255, 255)
	desc.TextSize = 14
	desc.TextTransparency = 0.1
	desc.TextXAlignment = Enum.TextXAlignment.Right
	desc.Parent = Button

	if bind then
		keybind.Name = "keybind"
		keybind.Parent = Button
		keybind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		keybind.BackgroundTransparency = .9
		keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
		keybind.BorderSizePixel = 0
		keybind.Position = UDim2.new(1.052, 0, -.366, 0)
		keybind.Size = UDim2.new(.09, 0, 1.666, 0)
		keybind.ImageTransparency = 1

		keybindstroke.Name = "stroke"
		keybindstroke.Parent = keybind
		keybindstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		keybindstroke.Color = Color3.fromRGB(255, 255, 255)
		keybindstroke.LineJoinMode = Enum.LineJoinMode.Miter
		keybindstroke.Thickness = 0
		keybindstroke.Transparency = .8

		keybindlabel.Name = "label"
		keybindlabel.Parent = keybind
		keybindlabel.AnchorPoint = Vector2.new(.5, .5)
		keybindlabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		keybindlabel.BackgroundTransparency = 1
		keybindlabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		keybindlabel.BorderSizePixel = 0
		keybindlabel.Position = UDim2.new(.5, 0, .5, 0)
		keybindlabel.Size = UDim2.new(1, 0, 1, 0)
		keybindlabel.Font = Enum.Font.Montserrat
		keybindlabel.Text = "Click To Set A Keybind"
		keybindlabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		keybindlabel.TextSize = 11
		keybindlabel.TextWrapped = true

		keybindlabelratio.Name = "ratio"
		keybindlabelratio.Parent = keybindlabel

		local config = savedData["Keybinds"] and savedData["Keybinds"][command]
		if config and type(config) == "string" and isValidKey(config) then
			keybindlabel.Text = "Bound to: " .. tostring(config)
			local keyCode = stringToKeyCode(config)
			task.spawn(function()
				manageKeybind(command,commandFunc,keyCode)
			end)
		end
	end

	local value = (sliderType == "bool" and defValue > .5 or defValue)
	task.spawn(function()
		local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local isDragging = false
		local moveConn
		local releaseConn
		
		if shouldSave and isfile(saveFileLoc..".json") then
			local config = loadConfig(saveFileLoc..".json")
			if config and config.Settings and config.Settings[command] ~= nil then
				value = config.Settings[command]
				local percent
				if sliderType == "bool" then
					percent = value and 1.0 or 0.0
				else
					percent = math.clamp((value - lowVal) / (maxVal - lowVal), 0, 1)
				end
				sliderThumb.Position = UDim2.new(percent, 0, 0.5, 0)
				label.Text = buttonName .. ": " .. (sliderType == "bool" and tostring(value) or string.format("%.2f", value))
			end
		end

		if willStartup then
			commandFunc(value)
		end

		Button.MouseEnter:Connect(function()
			if not isDragging then
				TS:Create(Button, ti, {BackgroundTransparency = .95}):Play()
				TS:Create(Button.stroke, ti, {Thickness = 2}):Play()
			end
		end)    

		--[[
		Button.MouseButton1Down:Connect(function()
			TS:Create(Button, ti, {BackgroundTransparency = .7}):Play()
			TS:Create(Button.stroke, ti, {Thickness = 3}):Play()
		end)

		Button.InputEnded:Connect(function()
			TS:Create(Button, ti, {BackgroundTransparency = .9}):Play()
			TS:Create(Button.stroke, ti, {Thickness = 0}):Play()
		end)
		]]
		
		--[[
		Button.Activated:Connect(function()
			commandFunc(value)
		end)
		]]

		if bind then
			keybind.MouseEnter:Connect(function()
				TS:Create(keybind, ti, {BackgroundTransparency = .95}):Play()
				TS:Create(keybind.stroke, ti, {Thickness = 2}):Play()
			end)

			keybind.MouseButton1Down:Connect(function()
				TS:Create(keybind, ti, {BackgroundTransparency = .7}):Play()
				TS:Create(keybind.stroke, ti, {Thickness = 3}):Play()
			end)

			keybind.InputEnded:Connect(function()
				TS:Create(keybind, ti, {BackgroundTransparency = .9}):Play()
				TS:Create(keybind.stroke, ti, {Thickness = 0}):Play()
			end)
			
			local capturingKey = false
			local connection = nil
			keybind.Activated:Connect(function()
				bindKey(capturingKey,connection,keybindlabel,command,commandFunc)
			end)

			local config = savedData["Keybinds"] and savedData["Keybinds"][command]
			if config and type(config) == "string" and isValidKey(config) then
				keybindlabel.Text = "Bound to: " .. tostring(config)
				local keyCode = stringToKeyCode(config)
				manageKeybind(command,commandFunc,keyCode)
			end
		end

		local canActivate = true
		sliderThumb.MouseButton1Down:Connect(function()
			if not canActivate then return end
			canActivate = false
			isDragging = true   
			local sliderAbsolutePos = sliderTrack.AbsolutePosition.X
			local sliderWidth = sliderTrack.AbsoluteSize.X
			local targetPos = sliderThumb.Position
			local runConn

			TS:Create(Button, ti, {BackgroundTransparency = .7}):Play()
			TS:Create(Button.stroke, ti, {Thickness = 3}):Play()
			
			local function handleMove(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
					local mouseX = input.Position.X
					local relativeX = math.clamp(mouseX - sliderAbsolutePos, 0, sliderWidth)
					local percent = relativeX / sliderWidth

					if sliderType == "num" then
						local snapInterval = 1
						local rawValue = lowVal + (maxVal - lowVal) * percent
						value = math.floor((rawValue / snapInterval) + .5) * snapInterval
						value = math.clamp(value, lowVal, maxVal)
						percent = (value - lowVal) / (maxVal - lowVal)
					elseif sliderType == "bool" then
						value = percent > .5
						percent = value and 1 or 0
					end
					values[command] = value

					targetPos = UDim2.new(percent, 0, .5, 0)
					label.Text = buttonName .. ": " .. (sliderType == "bool" and tostring(value) or string.format("%.2f", value))
				end
			end
			
			local function handleRelease(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
					isDragging = false
					TS:Create(Button, ti, {BackgroundTransparency = .9}):Play()
					TS:Create(Button.stroke, ti, {Thickness = 0}):Play()
					moveConn:Disconnect()
					moveConn = nil
					releaseConn:Disconnect()
					releaseConn = nil
					if shouldSave then
						configManager.add(command,"Settings",value)
					end
					task.spawn(function()
						commandFunc(value)
					end)
					if sliderType == "bool" then
						if runConn then runConn:Disconnect(); runConn = nil end
						local snapPercent = value and 1 or 0
						TS:Create(sliderThumb, ti, {Position = UDim2.new(snapPercent, 0, .5, 0)}):Play()
						canActivate = true
						return
					end
					local finalTween = TS:Create(sliderThumb, ti, {Position = targetPos})
					finalTween.Completed:Connect(function()
						if runConn then runConn:Disconnect(); runConn = nil end
						canActivate = true
					end)
					finalTween:Play()
					values[command] = value
				end
			end

			runConn = game:GetService("RunService").RenderStepped:Connect(function()
				if isDragging and targetPos then
					sliderThumb.Position = sliderThumb.Position:Lerp(targetPos, .15)
				end
			end)
			moveConn = UIS.InputChanged:Connect(handleMove)
			releaseConn = UIS.InputEnded:Connect(handleRelease)
		end)
	end)
end
-- Creating things

function module:Init()
	initialize()
	savedData = loadConfig(saveFileLoc..".json")

	local pages = {}
	local lib = {}
	lib.__index = lib

	function lib:ToggleCheck(command)
		if not command or values[command] == nil then return "Invalid command id" end
		return values[command]
	end

	function lib:ToggleGui()
		toggleGui(nil,nil,nil,nil,true)
	end

	function lib:AddPage(pageName)
		local mainPage = createPage(pageName)

		local page = {}
		page.__index = page
		pages[pageName] = page

		function page:AddButton(...)
			local args = {...}

			local buttonInfo = args[1]
			if type(buttonInfo) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end
			--local buttonName = buttonInfo["Title"] or "Title not specified"
			--local buttonDesc = buttonInfo["Desc"] or "Description not specified"
			--local buttonText = buttonInfo["Action"] or "Action not specified"

			local commandFunc = args[2]
			if type(commandFunc) ~= "function" then warn("["..libName.."]: Invalid Arguments!"); return end

			local otherInfo = args[3]
			if type(otherInfo) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end
			local command = otherInfo["UniqueCommandId"]
			--local canStartup = otherInfo["StartupAvailable"]
			--local bind = otherInfo["Bindable"]

			--if not (buttonName and buttonDesc and buttonText) then warn("["..libName.."]: You have not specified the required arguments!"); return end
			if not command or type(command) ~= "string" or command == "" or values[command] then
				local selectedString = nil
				repeat selectedString = randomString() until values[selectedString] == nil
				otherInfo["UniqueCommandId"] = selectedString
				command = selectedString
			end

			if type(args[4]) == "table" then
				for _,cmd in ipairs(args[4]) do
					quickcmdList[cmd] = {commandFunc,buttonInfo["Title"],otherInfo["UniqueCommandId"]}
					table.insert(quickcmdListOrder,cmd)
				end
			end

			createButton(buttonInfo, commandFunc, otherInfo, mainPage)

			local button = {}
			button.__index = button

			function button:getValue()
				return values[command]
			end

			function button:getId()
				return command
			end

			function button:getFunc()
				return commandFunc
			end

			return button
		end

		function page:AddTextbox(...)
			local args = {...}

			local buttonInfo = args[1]
			if type(buttonInfo) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end
			--local buttonName = buttonInfo["Title"] or "Title not specified"
			--local buttonDesc = buttonInfo["Desc"] or "Description not specified"
			--local buttonText = buttonInfo["Action"] or "Action not specified"

			local commandFunc = args[2]
			if type(commandFunc) ~= "function" then warn("["..libName.."]: Invalid Arguments!"); return end

			local otherInfo = args[3]
			if type(otherInfo) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end
			local command = otherInfo["UniqueCommandId"]
			--local canStartup = otherInfo["StartupAvailable"]
			--local bind = otherInfo["Bindable"]

			--if not (buttonName and buttonDesc and buttonText) then warn("["..libName.."]: You have not specified the required arguments!"); return end
			if not command or type(command) ~= "string" or command == "" or values[command] then
				local selectedString = nil
				repeat selectedString = randomString() until values[selectedString] == nil
				otherInfo["UniqueCommandId"] = selectedString
				command = selectedString
			end

			if type(args[4]) == "table" then
				for _,cmd in ipairs(args[4]) do
					quickcmdList[cmd] = {commandFunc,buttonInfo["Title"],otherInfo["UniqueCommandId"]}
					table.insert(quickcmdListOrder,cmd)
				end
			end

			local textbox = createTextBox(buttonInfo, commandFunc, otherInfo, mainPage)

			local button = {}
			button.__index = button

			function button:getValue()
				return textbox.Text
			end

			function button:getId()
				return command
			end

			function button:getFunc()
				return commandFunc
			end

			return button
		end

		function page:AddSelection(...)
			local args = {...}

			local buttonInfo = args[1]
			if type(buttonInfo) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end
			--local buttonName = buttonInfo["Title"] or "Title not specified"
			--local buttonDesc = buttonInfo["Desc"] or "Description not specified"
			--local buttonText = buttonInfo["Action"] or "Action not specified"

			local commandFunc = args[2]
			if type(commandFunc) ~= "function" then warn("["..libName.."]: Invalid Arguments!"); return end

			local otherInfo = args[3]
			if type(otherInfo) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end
			local command = otherInfo["UniqueCommandId"]
			--local canStartup = otherInfo["StartupAvailable"]
			--local bind = otherInfo["Bindable"]
			if not args[4] or type(args[4]) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end

			--if not (buttonName and buttonDesc and buttonText) then warn("["..libName.."]: You have not specified the required arguments!"); return end
			if not command or type(command) ~= "string" or command == "" or values[command] then
				local selectedString = nil
				repeat selectedString = randomString() until values[selectedString] == nil
				otherInfo["UniqueCommandId"] = selectedString
				command = selectedString
			end

			if type(args[5]) == "table" then
				for _,cmd in ipairs(args[5]) do
					quickcmdList[cmd] = {commandFunc,buttonInfo["Title"],otherInfo["UniqueCommandId"]}
					table.insert(quickcmdListOrder,cmd)
				end
			end

			createSelection(buttonInfo, commandFunc, otherInfo, mainPage, args[4])

			local button = {}
			button.__index = button

			function button:getValue()
				return values[command]
			end

			function button:getId()
				return command
			end

			function button:getFunc()
				return commandFunc
			end

			return button
		end

		function page:AddSlider(...)
			local args = {...}

			local buttonInfo = args[1]
			if type(buttonInfo) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end
			--local buttonName = buttonInfo["Title"] or "Title not specified"
			--local buttonDesc = buttonInfo["Desc"] or "Description not specified"
			--local buttonText = buttonInfo["Action"] or "Action not specified"

			local commandFunc = args[2]
			if type(commandFunc) ~= "function" then warn("["..libName.."]: Invalid Arguments!"); return end

			local otherInfo = args[3]
			if type(otherInfo) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end
			local command = otherInfo["UniqueCommandId"]
			--local canStartup = otherInfo["StartupAvailable"]
			--local bind = otherInfo["Bindable"]
			if not args[4] or type(args[4]) ~= "table" then warn("["..libName.."]: Invalid Arguments!"); return end

			--if not (buttonName and buttonDesc and buttonText) then warn("["..libName.."]: You have not specified the required arguments!"); return end
			if not command or type(command) ~= "string" or command == "" or values[command] then
				local selectedString = nil
				repeat selectedString = randomString() until values[selectedString] == nil
				otherInfo["UniqueCommandId"] = selectedString
				command = selectedString
			end

			if type(args[5]) == "table" then
				for _,cmd in ipairs(args[5]) do
					quickcmdList[cmd] = {commandFunc,buttonInfo["Title"],otherInfo["UniqueCommandId"]}
					table.insert(quickcmdListOrder,cmd)
				end
			end

			createSlider(buttonInfo, commandFunc, otherInfo, mainPage, args[4])

			local button = {}
			button.__index = button

			function button:getValue()
				return values[command]
			end

			function button:getId()
				return command
			end

			function button:getFunc()
				return commandFunc
			end

			return button
		end

		return page
	end

	function lib:GetPageFromTitle(title)
		return pages[title]
	end

	function lib:GetQuickCommandsList()
		print("[" .. libName .. "]: ---------- COMMANDS LIST OUTPUT START ----------\n")
		local grouped = {} -- key = title .. "|" .. uniqueId, value = list of cmds
		local keyOrder = {} -- preserve order for output

		for _, cmdKey in ipairs(quickcmdListOrder) do
			local data = quickcmdList[cmdKey]
			if data then
				local title = data[2]
				local uniqueId = data[3]
				local groupKey = title .. "|" .. uniqueId

				if not grouped[groupKey] then
					grouped[groupKey] = { cmds = {}, title = title, uniqueId = uniqueId }
					table.insert(keyOrder, groupKey)
				end
				table.insert(grouped[groupKey].cmds, cmdKey)
			else
				warn("[" .. libName .. "]: Missing quickcmd data for key: " .. tostring(cmdKey))
			end
		end

		local output = {}
		for _, groupKey in ipairs(keyOrder) do
			local group = grouped[groupKey]
			local line = string.format("%s (%s): %s", group.title, group.uniqueId, table.concat(group.cmds, ", "))
			print("[" .. libName .. "]: Processing '" .. line .. "'...")
			table.insert(output, line)
		end

		if #output == 0 then
			print("[" .. libName .. "]: No quick commands found.")
		else
			writefile(saveFileLoc .. "_commandIds.txt", table.concat(output, "\n"))
			print("[" .. libName .. "]: File written to: " .. saveFileLoc .. "_commandIds.txt")
		end
		print("\n[" .. libName .. "]: ---------- COMMANDS LIST OUTPUT END ----------")
	end

	local settingsPage = lib:AddPage("Settings")
	settingsPage:AddSlider({
			Title = "Quick Command",
			Desc = "Check 'More Command Info' in the settings category.",
			Action = ""
		},
		quickcmd,
		{
			UniqueCommandId = "IMPORTANT_QUICKCMD",
			StartupAvailable = true,
			Bindable = true
		},
		{
			sliderType = "bool",
			defVal = 1,
			lowVal = 0,
			maxVal = 1,
			save = true
		}
	)

	task.spawn(function()
		while true do
			lastPageNum = pagesAmount
			if nextPrev then
				if pagesAmount <= 1 then
					nextPrev.Visible = false
				else
					nextPrev.Visible = true
				end
			end
			task.wait()
		end
	end)

	--print("["..libName.."]: Initialized successfully!")

	return lib
end

return module
