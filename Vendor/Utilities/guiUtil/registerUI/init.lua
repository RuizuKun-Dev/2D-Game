local SoundService = game:GetService("SoundService")
local SoundSystem = require(SoundService.SoundSystem)

local TweenService = game:GetService("TweenService")

local CustomUIHandler = require(script.CustomUIHandler)

local registerUI = {}

local function setPositionAttribute(ui: GuiObject)
	if not ui:GetAttribute("Position") then
		ui.Visible = true
		ui:SetAttribute("Position", ui.Position)
		ui.Position = UDim2.fromScale(0.5, -1)
	end
end

local currentMenuFrame

function registerUI.showUI(ui: GuiObject)
	setPositionAttribute(ui)
	ui.Visible = true
	ui:TweenPosition(ui:GetAttribute("Position"), "Out", "Back", 0.5, true)
	currentMenuFrame = ui
end

function registerUI.hideUI(ui: GuiObject)
	setPositionAttribute(ui)
	ui:TweenPosition(UDim2.fromScale(0.5, -1), "In", "Quad", 0.25, true)
	currentMenuFrame = nil
end

function registerUI.WithMenuButton(menu: GuiObject, button: GuiButton)
	setPositionAttribute(menu)

	local Events = CustomUIHandler.create(button)

	Events.UIPress:Connect(function()
		if currentMenuFrame ~= menu then
			SoundSystem.PlaySFX("Bubble Click", button)

			registerUI.hideUI(currentMenuFrame or menu)
			registerUI.showUI(menu)
		elseif currentMenuFrame == menu then
			SoundSystem.PlaySFX("Click Swoosh", button)

			registerUI.hideUI(menu)
		end
	end)
end

function registerUI.WithMenuCloseButton(menu: GuiObject, closeButton: GuiButton)
	setPositionAttribute(menu)

	local Events = CustomUIHandler.create(closeButton)

	Events.UIPress:Connect(function()
		SoundSystem.PlaySFX("Button Click", closeButton)
		menu.Visible = false
		registerUI.hideUI(menu)
	end)

	if closeButton:IsA("ImageButton") then
		Events.UIHoverEnter:Connect(function()
			closeButton.ImageTransparency = 0
		end)

		Events.UIHoverLeave:Connect(function()
			closeButton.ImageTransparency = 0.5
		end)
	end
end

local Sine = Enum.EasingStyle.Sine

local In = Enum.EasingDirection.In
local Out = Enum.EasingDirection.Out

local hoverIn = TweenInfo.new(0.1, Sine, Out)
local hoverOut = TweenInfo.new(0.05, Sine, In)

function registerUI.WithUIScale(ui: GuiObject, uiScale: UIScale, Scales: { [string]: number })
	local tweenHoverEnter = TweenService:Create(uiScale, hoverIn, { Scale = Scales.HoverEnter })
	local tweenHoverLeave = TweenService:Create(uiScale, hoverOut, { Scale = Scales.HoverLeave })
	local tweenPress = TweenService:Create(uiScale, hoverOut, { Scale = Scales.HoverLeave * 0.85 })
	local tweenRelease = TweenService:Create(uiScale, hoverIn, { Scale = Scales.HoverEnter * 0.95 })

	local Events = CustomUIHandler.create(ui)

	Events.UIHoverEnter:Connect(function()
		SoundSystem.PlaySFX("Info Click", ui)
		tweenHoverEnter:Play()
	end)

	Events.UIHoverLeave:Connect(function()
		tweenHoverLeave:Play()
	end)

	Events.UIPress:Connect(function()
		tweenPress:Play()
	end)

	Events.UIRelease:Connect(function()
		tweenRelease:Play()
	end)

	uiScale.Scale = Scales.HoverLeave
end

function registerUI.WithHoverEnterUIEvent(ui: GuiObject, callback): Connection
	local Events = CustomUIHandler.create(ui)

	return Events.UIHoverEnter:Connect(callback)
end

function registerUI.WithHoverLeaveUIEvent(ui: GuiObject, callback): Connection
	local Events = CustomUIHandler.create(ui)

	return Events.UIHoverLeave:Connect(callback)
end

function registerUI.WithPressUIEvent(ui: GuiObject, callback): Connection
	local Events = CustomUIHandler.create(ui)

	return Events.UIPress:Connect(callback)
end

function registerUI.WithReleaseUIEvent(ui: GuiObject, callback): Connection
	local Events = CustomUIHandler.create(ui)

	return Events.UIRelease:Connect(callback)
end

return registerUI
