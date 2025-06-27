local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local character, humanoid, hrp

local sidebouncePower = 50
local upwardForce = 20
local bounceDuration = 0.15
local cameraTiltAngle = 8
local cameraReturnSpeed = 10
local cameraTiltSpeed = 12

local climbing = false
local currentTilt = 0
local targetTilt = 0

local function setupCharacter(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    climbing = false

    humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Climbing then
            climbing = true
        else
            climbing = false
        end
    end)
end

local function getSideDirection()
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        return -1
    elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
        return 1
    end
    return 0
end

local function doSideBounce()
    if not climbing or not hrp or not hrp.Parent then return end

    local dir = getSideDirection()
    if dir == 0 then return end

    local bv = Instance.new("BodyVelocity")
    local rightVec = hrp.CFrame.RightVector * dir
    local upwardVec = Vector3.new(0, upwardForce, 0)
    
    bv.Velocity = rightVec * sidebouncePower + upwardVec
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.P = 12000
    bv.Parent = hrp

    Debris:AddItem(bv, bounceDuration)

    targetTilt = math.rad(cameraTiltAngle * -dir)
end

local function updateCameraTilt(dt)
    if not climbing then
        targetTilt = 0
    end
    
    local lerpSpeed = (targetTilt ~= 0) and cameraTiltSpeed or cameraReturnSpeed
    currentTilt = currentTilt + (targetTilt - currentTilt) * lerpSpeed * dt
    
    camera.CFrame = camera.CFrame * CFrame.Angles(0, 0, currentTilt)
    
    targetTilt = 0
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space then
        doSideBounce()
    end
end)

RunService.RenderStepped:Connect(function(dt)
    camera.CFrame = camera.CFrame * CFrame.Angles(0, 0, -currentTilt)
    updateCameraTilt(dt)
end)

player.CharacterAdded:Connect(setupCharacter)
if player.Character then
    setupCharacter(player.Character)
end

print("sidebounce loaded. While climbing a HORIZONTAL truss press Spacebar while holding A or D to bounce off the wall in that direction.")
