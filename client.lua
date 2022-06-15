ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
  TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
  Citizen.Wait(0)
    end
end)

--- Señalar ---
local mp_pointing = false
local keyPressed = false

local function startPointing()
    local ped = PlayerPedId()
    RequestAnimDict("anim@mp_point")
    while not HasAnimDictLoaded("anim@mp_point") do
        Wait(0)
    end
    SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
    SetPedConfigFlag(ped, 36, 1)
    Citizen.InvokeNative(0x2D537BA194896636, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    RemoveAnimDict("anim@mp_point")
end

local function stopPointing()
    local ped = PlayerPedId()
    Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")
    if not IsPedInjured(ped) then
        ClearPedSecondaryTask(ped)
    end
    if not IsPedInAnyVehicle(ped, 1) then
        SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
    end
    SetPedConfigFlag(ped, 36, 0)
    ClearPedSecondaryTask(PlayerPedId())
end

local once = true
local oldval = false
local oldvalped = false

Citizen.CreateThread(function()
    while true do
        Wait(0)

        if once then
            once = false
        end

        if not keyPressed then
            if IsControlPressed(0, 29) and not mp_pointing and IsPedOnFoot(PlayerPedId()) then
                Wait(200)
                if not IsControlPressed(0, 29) then
                    keyPressed = true
                    startPointing()
                    mp_pointing = true
                else
                    keyPressed = true
                    while IsControlPressed(0, 29) do
                        Wait(50)
                    end
                end
            elseif (IsControlPressed(0, 29) and mp_pointing) or (not IsPedOnFoot(PlayerPedId()) and mp_pointing) then
                keyPressed = true
                mp_pointing = false
                stopPointing()
            end
        end

        if keyPressed then
            if not IsControlPressed(0, 29) then
                keyPressed = false
            end
        end
        if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) and not mp_pointing then
            stopPointing()
        end
        if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) then
            if not IsPedOnFoot(PlayerPedId()) then
                stopPointing()
            else
                local ped = PlayerPedId()
                local camPitch = GetGameplayCamRelativePitch()
                if camPitch < -70.0 then
                    camPitch = -70.0
                elseif camPitch > 42.0 then
                    camPitch = 42.0
                end
                camPitch = (camPitch + 70.0) / 112.0

                local camHeading = GetGameplayCamRelativeHeading()
                local cosCamHeading = Cos(camHeading)
                local sinCamHeading = Sin(camHeading)
                if camHeading < -180.0 then
                    camHeading = -180.0
                elseif camHeading > 180.0 then
                    camHeading = 180.0
                end
                camHeading = (camHeading + 180.0) / 360.0

                local blocked = 0
                local nn = 0

                local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
                local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7);
                nn,blocked,coords,coords = GetRaycastResult(ray)

                Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Pitch", camPitch)
                Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Heading", camHeading * -1.0 + 1.0)
                Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isBlocked", blocked)
                Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isFirstPerson", Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)

            end
        end
    end
end)


--- Levantar manos ---
local handsup = false
local cabeca = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		local ped = PlayerPedId()
		DisableControlAction(0, 36, true)
		if not IsPedInAnyVehicle(ped) then
			RequestAnimSet("move_ped_crouched")
			RequestAnimSet("move_ped_crouched_strafing")
			if IsControlJustPressed(1, 323) then
				local dict = "missminuteman_1ig_2"
				RequestAnimDict(dict)
				while not HasAnimDictLoaded(dict) do
					Citizen.Wait(100)
				end

				if handsup == false then
					ClearPedTasks(PlayerPedId())
					TaskPlayAnim(PlayerPedId(), dict, "handsup_enter", 8.0, 8.0, -1, 50, 0, false, false, false)
					handsup = true
					TriggerServerEvent("tac_thief:update", handsup)
				elseif cabeca == false then
					while not HasAnimDictLoaded("random@arrests@busted") do
						RequestAnimDict("random@arrests@busted")
						Citizen.Wait(5)
					end
				cabeca = true
				TaskPlayAnim(PlayerPedId(), "random@arrests@busted", "idle_c", 8.0, 8.0, -1, 50, 0, false, false, false)
				else
					cabeca = false
					handsup = false
					TriggerServerEvent("tac_thief:update", handsup)
					ClearPedTasks(PlayerPedId())
				end
			end
		end
	end
end)


--- Agacharse ---
local agacharse = false
Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1)
        local ped = PlayerPedId()
        if DoesEntityExist(ped) and not IsEntityDead(ped) and not IsPedInAnyVehicle(ped) then 
            DisableControlAction(0,36,true)
            if not IsPauseMenuActive() then 
                if IsDisabledControlJustPressed(0,36) then 
                    RequestAnimSet("move_ped_crouched")
                    RequestAnimSet("move_ped_crouched_strafing")
                    if agacharse == true then 
                        ResetPedMovementClipset(ped,0.55)
                        ResetPedStrafeClipset(ped)
                        agacharse = false 
                    elseif agacharse == false then
                        SetPedMovementClipset(ped,"move_ped_crouched",0.55)
                        SetPedStrafeClipset(ped,"move_ped_crouched_strafing")
                        agacharse = true 
                    end 
                end
            end 
        end 
    end
end)



--- Suelo ---
local ragdoll = false
function setRagdoll(flag)
  ragdoll = flag
end
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if ragdoll then
      SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
    end
  end
end)

ragdol = true
RegisterNetEvent("Ragdoll")
AddEventHandler("Ragdoll", function()
	if ( ragdol ) then
		setRagdoll(true)
		ragdol = false
	else
		setRagdoll(false)
		ragdol = true
	end
end)

Citizen.CreateThread(function()
 	while true do
 		Citizen.Wait(100)
 		if ( IsControlPressed(2, 303) ) then  --U
 			TriggerEvent("Ragdoll", source)
 		end
 	end
end)



--- Caminar herido ---
local hurt = false
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if GetEntityHealth(PlayerPedId()) <= 159 then
            setHurt()
        elseif hurt and GetEntityHealth(PlayerPedId()) > 160 then
            setNotHurt()
        end
    end
end)

function setHurt()
    hurt = true
    RequestAnimSet("move_m@injured")
    SetPedMovementClipset(PlayerPedId(), "move_m@injured", true)
end

function setNotHurt()
    hurt = false
    ResetPedMovementClipset(PlayerPedId())
    ResetPedWeaponMovementClipset(PlayerPedId())
    ResetPedStrafeClipset(PlayerPedId())
end


--- NPCs no tiran armas ---
function SetWeaponDrops()
  local handle, ped = FindFirstPed()
  local finished = false 

  repeat 
      if not IsEntityDead(ped) then
          SetPedDropsWeaponsWhenDead(ped, false) 
      end
      finished, ped = FindNextPed(handle)
  until not finished

  EndFindPed(handle)
end

Citizen.CreateThread(function()
  while true do
      SetWeaponDrops()
      Citizen.Wait(500)
  end
end)



--- K.O ---
local knockedOut = false
local wait = 15
local count = 60

Citizen.CreateThread(function()
	while true do
		Wait(1)
		local myPed = PlayerPedId()
		if IsPedInMeleeCombat(myPed) then
			if GetEntityHealth(myPed) < 115 then
				SetPlayerInvincible(PlayerId(), true)
				SetPedToRagdoll(myPed, 1000, 1000, 0, 0, 0, 0)
				wait = 15
				knockedOut = true
				SetEntityHealth(myPed, 116)
			end
		end
		if knockedOut == true then
			SetPlayerInvincible(PlayerId(), true)
			DisablePlayerFiring(PlayerId(), true)
			SetPedToRagdoll(myPed, 1000, 1000, 0, 0, 0, 0)
			ResetPedRagdollTimer(myPed)
			
			if wait >= 0 then
				count = count - 1
				if count == 0 then
					count = 60
					wait = wait - 1
					SetEntityHealth(myPed, GetEntityHealth(myPed)+4)
				end
			else
				SetPlayerInvincible(PlayerId(), false)
				knockedOut = false
			end
		end
	end
end)



--- /rvoz ---
RegisterCommand('rvoz', function()
	NetworkClearVoiceChannel()
	NetworkSessionVoiceLeave()
	Wait(50)
	NetworkSetVoiceActive(false)
	MumbleClearVoiceTarget(2)
	Wait(1000)
	MumbleSetVoiceTarget(2)
	NetworkSetVoiceActive(true)
	ESX.ShowNotification('Chat de voz reiniciado.')
end)


--- ID ---
local keko = {}

function iskeko(name)
	for i = 1, #keko, 1 do
		if string.lower(name) == string.lower(keko[i]) then
			return true
		end
	end
	return false
end

Citizen.CreateThread(function()
	Citizen.Wait(2000)
	while true do
		Citizen.Wait( 1 )
		local headIds = { }
		if IsControlPressed(0, 19) then
			for id = 0, 256, 1 do
				if NetworkIsPlayerActive( id ) then 
					local ped = GetPlayerPed( id )
					if ped ~= nil and (GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(ped)) < 21.010) and HasEntityClearLosToEntity(PlayerPedId(),  ped,  17) then
						if GetPlayerServerId(id) ~= nil and not iskeko(GetPlayerName(id)) then
						 headIds[id] = Citizen.InvokeNative(0xBFEFE3321A3F5015, ped, tostring(GetPlayerServerId(id)), false, false, "", false )
						 N_0x63bb75abedc1f6a0(headIds[id], false, true)
						end
					end
				end
			end
			while IsControlPressed(0, 19) do
				Citizen.Wait(20)
			end
			
			for id = 0, 256, 1 do
				if NetworkIsPlayerActive( id ) then
					N_0x63bb75abedc1f6a0(headIds[id], false, false)
				end
			end
		end
	end
end)
