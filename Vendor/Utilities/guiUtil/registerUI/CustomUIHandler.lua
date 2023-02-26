local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local mouse = localPlayer:GetMouse()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utilities = ReplicatedStorage.Utilities
local array = require(Utilities.array)
local Janitor = require(Utilities.Janitor)
local connections = Janitor.new()
local Signals = require(Utilities.Signals)

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local CustomUIHandler = {
	Enabled = not RunService:IsStudio(),
	_GUIsAtMouse = {},
	IS_CYCLICAL = true,
}
CustomUIHandler.__index = CustomUIHandler

local UIList = {}
local UIMap = {}

export type CustomUIObject = {
	IsPress: boolean,

	IsHovering: boolean,
	WasHovering: boolean,

	Disable: () -> void,
	Enable: () -> void,

	UIHoverEnter: Signal,
	UIHoverLeave: Signal,
	UIPress: Signal,
	UIRelease: Signal,
}

function CustomUIHandler.create(ui: GuiObject): CustomUIObject
	if not UIMap[ui] then
		local customUIObject = setmetatable({
			Instance = ui,

			UIPress = Signals.create(),
			UIRelease = Signals.create(),

			UIHoverEnter = Signals.create(),
			UIHoverLeave = Signals.create(),

			USING_METATABLE = true,
			--Metatable = UIHover,
		}, CustomUIHandler)

		ui.Destroying:Connect(function()
			if UIMap[ui] then
				UIMap[ui] = nil
				array.remove(UIList, customUIObject)
			end
		end)

		UIMap[ui] = customUIObject

		table.insert(UIList, customUIObject)
	end

	return UIMap[ui]
end

function CustomUIHandler.get(ui: GuiObject): CustomUIObject
	return UIMap[ui]
end

function CustomUIHandler:Enable()
	self.Instance.Active = true
end

function CustomUIHandler:Disable()
	self.Instance.Active = false
end

function CustomUIHandler:_IsOnUI(): boolean
	local ui = self.Instance
	if table.find(CustomUIHandler._GUIsAtMouse, ui) then
		return true
	end
	return false
end

function CustomUIHandler:_UpdateUIHoverEnter()
	local customUIObject = self
	if customUIObject.IsHovering and not customUIObject.WasHovering then
		customUIObject.WasHovering = true
		customUIObject.UIHoverEnter:Fire(customUIObject.Instance :: GuiObject)

		-- print("UIHoverEnter", customUIObject.Instance)
	end
end

function CustomUIHandler:_UpdateUIHoverLeave()
	local customUIObject = self
	if not customUIObject.IsHovering and customUIObject.WasHovering then
		customUIObject.WasHovering = false

		customUIObject:_UpdateUIRelease()

		customUIObject.UIHoverLeave:Fire(customUIObject.Instance :: GuiObject)

		-- print("UIHoverLeave", customUIObject.Instance)
	end
end

function CustomUIHandler:_UpdateUIHover()
	local customUIObject = self
	customUIObject.IsHovering = customUIObject:_IsOnUI()

	customUIObject:_UpdateUIHoverLeave()

	-- print("UpdateUIHover", customUIObject.Instance)
end

function CustomUIHandler:_UpdateUIPress()
	local customUIObject = self
	if customUIObject.IsHovering and not customUIObject.IsPress then
		customUIObject.IsPress = true
		customUIObject.UIPress:Fire(customUIObject.Instance :: GuiObject)

		-- print("UIPress", customUIObject.Instance)
	end
end

function CustomUIHandler:_UpdateUIRelease()
	local customUIObject = self
	if customUIObject.IsPress then
		customUIObject.IsPress = false
		customUIObject.UIRelease:Fire(customUIObject.Instance :: GuiObject)

		-- print("UIRelease", customUIObject.Instance)
	end
end

local MOUSEBUTTON1 = Enum.UserInputType.MouseButton1

local function listenForMouse1Down()
	connections:Add(
		UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
			if gameProcessed then
				if input.UserInputType == MOUSEBUTTON1 then
					for _, ui: GuiObject in ipairs(CustomUIHandler._GUIsAtMouse) do
						local customUIObject: CustomUIObject = CustomUIHandler.get(ui)
						if customUIObject then
							customUIObject:_UpdateUIPress()
							break
						end
					end
				end
			end
		end),
		"Disconnect"
	)
end

local function listenForMouse1Up()
	connections:Add(
		UserInputService.InputEnded:Connect(function(input: InputObject)
			if input.UserInputType == MOUSEBUTTON1 then
				for _, customUIObject: CustomUIObject in ipairs(UIList) do
					customUIObject:_UpdateUIRelease()
				end
			end
		end),
		"Disconnect"
	)
end

local function bindUpdateMouseStateToRenderStep()
	RunService:BindToRenderStep("Update MouseState", Enum.RenderPriority.First.Value, function()
		if CustomUIHandler.Enabled then
			CustomUIHandler._GUIsAtMouse = playerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
			for _, customUIObject: CustomUIObject in ipairs(UIList) do
				customUIObject:_UpdateUIHover()
			end

			for _, ui: GuiObject in ipairs(CustomUIHandler._GUIsAtMouse) do
				local customUIObject: CustomUIObject = CustomUIHandler.get(ui)
				if customUIObject then
					customUIObject:_UpdateUIHoverEnter()
					break
				end
			end
		end
	end)
end

local function listenForMouseInputs()
	if UserInputService.MouseEnabled then
		listenForMouse1Down()

		listenForMouse1Up()

		bindUpdateMouseStateToRenderStep()
	end
end

local TOUCH = Enum.UserInputType.Touch

local function listenForTouchStarted()
	connections:Add(
		UserInputService.TouchStarted:Connect(function(input: InputObject, gameProcessed: boolean)
			if gameProcessed then
				if input.UserInputType == TOUCH then
					CustomUIHandler._GUIsAtMouse = playerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
					for _, customUIObject: CustomUIObject in ipairs(UIList) do
						customUIObject:_UpdateUIHover()
					end

					for _, ui: GuiObject in ipairs(CustomUIHandler._GUIsAtMouse) do
						local customUIObject: CustomUIObject = CustomUIHandler.get(ui)
						if customUIObject then
							customUIObject:_UpdateUIHoverEnter()
							customUIObject:_UpdateUIPress()
							break
						end
					end
				end
			end
		end),
		"Disconnect"
	)
end

local function listenForTouchMoved()
	connections:Add(
		UserInputService.TouchMoved:Connect(function(input: InputObject)
			if input.UserInputType == TOUCH then
				CustomUIHandler._GUIsAtMouse = playerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
				for _, customUIObject: CustomUIObject in ipairs(UIList) do
					customUIObject:_UpdateUIHover()
				end

				for _, ui: GuiObject in ipairs(CustomUIHandler._GUIsAtMouse) do
					local customUIObject: CustomUIObject = CustomUIHandler.get(ui)
					if customUIObject then
						customUIObject:_UpdateUIHoverEnter()
						break
					end
				end
			end
		end),
		"Disconnect"
	)
end

local function listenForTouchEnded()
	connections:Add(
		UserInputService.TouchEnded:Connect(function(input: InputObject)
			if input.UserInputType == TOUCH then
				CustomUIHandler._GUIsAtMouse = {}
				for _, customUIObject: CustomUIObject in ipairs(UIList) do
					customUIObject:_UpdateUIHover()
				end
			end
		end),
		"Disconnect"
	)
end

local function listenForTouchInputs()
	if UserInputService.TouchEnabled then
		listenForTouchStarted()

		listenForTouchMoved()

		listenForTouchEnded()
	end
end

local function listenforInputs()
	listenForTouchInputs()
	listenForMouseInputs()
end

function CustomUIHandler.DisableInputs()
	CustomUIHandler.Enabled = false
	connections:Destroy()
	connections = Janitor.new()
	RunService:UnbindFromRenderStep("UpdateMouseState")
end

function CustomUIHandler.EnableInputs()
	CustomUIHandler.Enabled = true
	listenforInputs()
end
CustomUIHandler.EnableInputs()

return CustomUIHandler
