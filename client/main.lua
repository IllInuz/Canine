local policeDog = false
local following = false
local attacking = false
local attacked_player = 0
local searching = false
local playing_animation = false
local relationshipSet = false

RegisterCommand("spawnk9", function(source,args)
  local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
  local h = GetEntityHeading(GetPlayerPed(-1))
  local hash = GetHashKey( "a_c_shepherd" )

  while not HasModelLoaded( hash ) do
    RequestModel( hash )
    Wait(20)
  end

  policeDog = CreatePed(28, hash, x,y,z -1, h, 1, 0)
  SetBlockingOfNonTemporaryEvents(policeDog, true)
  SetPedFleeAttributes(policeDog, 0, 0)
  SetEntityHealth(policeDog, 300)
  SetPedRelationshipGroupHash(policeDog, GetHashKey("k9"))
  local blip = AddBlipForEntity(policeDog)
  SetBlipAsFriendly(blip, true)
  SetBlipSprite(blip, 442)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(tostring("K9 - Sparky"))
  EndTextCommandSetBlipName(blip)
  NetworkRegisterEntityAsNetworked(policeDog)
  SetPedKeepTask(policeDog, true)
  Notification("K9 Sparky was spawned.")
  while not NetworkGetEntityIsNetworked(policeDog) do
    NetworkRegisterEntityAsNetworked(policeDog)
    Citizen.Wait(1)
  end
end)

RegisterCommand("despawnk9", function(source,args)
  if(policeDog~=nil)then
    SetEntityAsMissionEntity(policeDog, true, true)
    DeleteEntity(policeDog)
    Notification("K9 Sparky was despawned.")
    policeDog = nil
  end
end)

RegisterCommand("searchk9", function(source,args)
  if(policeDog~=nil)then
    TriggerEvent("K9:SearchVehicle")
  end
end)

RegisterCommand("vehk9", function(source,args)
  if(policeDog~=nil)then
    TriggerEvent("K9:vehicle")
  end
end)


Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)

    if IsControlJustPressed(1, 47) and IsPlayerFreeAiming(PlayerId()) then
      local bool, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
      if bool then
        if IsEntityAPed(target) then
          TriggerEvent("K9:ToggleAttack", target)
        end
      end
    end

    if IsControlJustPressed(1, 47) and not IsPlayerFreeAiming(PlayerId()) then
      TriggerEvent("K9:ToggleFollow")
    end

    if not relationshipSet then
        AddRelationshipGroup("k9")
        SetRelationshipBetweenGroups(5, GetHashKey("k9"), GetHashKey("PLAYER"))
        SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("k9"))
        relationshipSet = true
    end
  end
end)

RegisterNetEvent("K9:vehicle")
AddEventHandler("K9:vehicle", function()
  if not searching then
    if IsPedInAnyVehicle(policeDog, false) then
      TaskLeaveVehicle(policeDog, GetVehiclePedIsIn(policeDog, false), 256)
      Notification("K9 Sparky is now out of the vehicle.")
    else
      local plyCoords = GetEntityCoords(GetLocalPed(), false)
      local vehicle = GetVehicleAheadOfPlayer()
      if door ~= false then
        TaskEnterVehicle(policeDog, vehicle, -1, 0, 2.0, 1, 0)
        Notification("K9 Sparky is now in the vehicle.")
      end
    end
  end
end)

RegisterNetEvent("K9:ToggleAttack")
AddEventHandler("K9:ToggleAttack", function(target)
  if not attacking then
    if IsPedAPlayer(target) then
      local player = GetPlayerFromServerId(GetPlayerId(target))
      SetCanAttackFriendly(policeDog, true, true)
      TaskPutPedDirectlyIntoMelee(policeDog, GetPlayerPed(player), 0.0, -1.0, 0.0, 0)
      SetPedCombatMovement(policeDog, 2)
      SetPedCombatAttributes(policeDog, 46, 1)
      SetPedCombatAbility(policeDog, 100)
      attacked_player = player
    else
      SetCanAttackFriendly(policeDog, true, true)
      TaskPutPedDirectlyIntoMelee(policeDog, target, 0.0, -1.0, 0.0, 0)
      attacked_player = 0
    end
    attacking = true
    following = false
    Notification("K9 Sparky has attacked.")
  end
end)

RegisterNetEvent("K9:ToggleFollow")
AddEventHandler("K9:ToggleFollow", function()
  if policeDog ~= nil then
    if not following then
      TaskFollowToOffsetOfEntity(policeDog, GetLocalPed(), 0.5, 0.0, 0.0, 5.0, -1, 0.0, 1)
      SetPedKeepTask(policeDog, true)
      following = true
      attacking = false
      Notification("K9 Sparky is now following.")
    else
      SetPedKeepTask(policeDog, false)
      ClearPedTasks(policeDog)
      following = false
      attacking = false
      Notification("K9 Sparky is now idle.")
    end
  end
end)

RegisterNetEvent("K9:SearchVehicle")
AddEventHandler("K9:SearchVehicle", function()
  local vehicle = GetVehicleAheadOfPlayer()
  Citizen.Trace(tostring(vehicle))
  if vehicle ~= 0 and not searching then
    searching = true
    Notification("K9 Sparky is now searching the vehicle.")

    SetVehicleDoorOpen(vehicle, 0, 0, 0)
    SetVehicleDoorOpen(vehicle, 1, 0, 0)
    SetVehicleDoorOpen(vehicle, 2, 0, 0)
    SetVehicleDoorOpen(vehicle, 3, 0, 0)
    SetVehicleDoorOpen(vehicle, 4, 0, 0)
    SetVehicleDoorOpen(vehicle, 5, 0, 0)
    SetVehicleDoorOpen(vehicle, 6, 0, 0)
    SetVehicleDoorOpen(vehicle, 7, 0, 0)

    -- Back Right
    local offsetOne = GetOffsetFromEntityInWorldCoords(vehicle, 2.0, -2.0, 0.0)
    TaskGoToCoordAnyMeans(policeDog, offsetOne.x, offsetOne.y, offsetOne.z, 5.0, 0, 0, 1, 10.0)
    local random = math.random(1, 10)
    if random == 1 or random == 3 or random == 5 then
      loadDict('missfra0_chop_find')
      TaskPlayAnim(policeDog, 'missfra0_chop_find', 'chop_bark_at_ballas', 8.0, -8, -1, 0, 0, false, false, false)
    end
    Citizen.Wait(7000)

    -- Front Right
    local offsetTwo = GetOffsetFromEntityInWorldCoords(vehicle, 2.0, 2.0, 0.0)
    TaskGoToCoordAnyMeans(policeDog, offsetTwo.x, offsetTwo.y, offsetTwo.z, 5.0, 0, 0, 1, 10.0)
    local random = math.random(1, 10)
    if random == 1 or random == 3 or random == 5 then
      loadDict('missfra0_chop_find')
      TaskPlayAnim(policeDog, 'missfra0_chop_find', 'chop_bark_at_ballas', 8.0, -8, -1, 0, 0, false, false, false)
    end
    Citizen.Wait(7000)

    -- Front Left
    local offsetThree = GetOffsetFromEntityInWorldCoords(vehicle, -2.0, 2.0, 0.0)
    TaskGoToCoordAnyMeans(policeDog, offsetThree.x, offsetThree.y, offsetThree.z, 5.0, 0, 0, 1, 10.0)
    local random = math.random(1, 10)
    if random == 1 or random == 3 or random == 5 then
      loadDict('missfra0_chop_find')
      TaskPlayAnim(policeDog, 'missfra0_chop_find', 'chop_bark_at_ballas', 8.0, -8, -1, 0, 0, false, false, false)
    end
    Citizen.Wait(7000)

    -- Front Right
    local offsetFour = GetOffsetFromEntityInWorldCoords(vehicle, -2.0, -2.0, 0.0)
    TaskGoToCoordAnyMeans(policeDog, offsetFour.x, offsetFour.y, offsetFour.z, 5.0, 0, 0, 1, 10.0)
    local random = math.random(1, 10)
    if random == 1 or random == 3 or random == 5 then
      loadDict('missfra0_chop_find')
      TaskPlayAnim(policeDog, 'missfra0_chop_find', 'chop_bark_at_ballas', 8.0, -8, -1, 0, 0, false, false, false)
    end
    Citizen.Wait(7000)


    Notification("K9 Sparky is done searching the vehicle.")
    searching = false
  end
end)

function PlayAnimation(dict, anim)
  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do
    Citizen.Wait(0)
  end

  TaskPlayAnim(PoliceDog, dict, anim, 8.0, -8.0, -1, 2, 0.0, 0, 0, 0)
end

function GetVehicleAheadOfPlayer()
  local lPed = GetLocalPed()
  local lPedCoords = GetEntityCoords(lPed, alive)
  local lPedOffset = GetOffsetFromEntityInWorldCoords(lPed, 0.0, 3.0, 0.0)
  local rayHandle = StartShapeTestCapsule(lPedCoords.x, lPedCoords.y, lPedCoords.z, lPedOffset.x, lPedOffset.y, lPedOffset.z, 1.2, 10, lPed, 7)
  local returnValue, hit, endcoords, surface, vehicle = GetShapeTestResult(rayHandle)

  if hit then
    return vehicle
  else
    return false
  end
end

function GetClosestVehicleDoor(vehicle)
  local plyCoords = GetEntityCoords(GetLocalPed(), false)
  local backleft = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "door_dside_r"))
  local backright = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "door_pside_r"))
  local bldistance = GetDistanceBetweenCoords(backleft['x'], backleft['y'], backleft['z'], plyCoords.x, plyCoords.y, plyCoords.z, 1)
  local brdistance = GetDistanceBetweenCoords(backright['x'], backright['y'], backright['z'], plyCoords.x, plyCoords.y, plyCoords.z, 1)

  local found_door = false

  if (bldistance < brdistance) then
    found_door = 1
  elseif(brdistance < bldistance) then
    found_door = 2
  end

  return found_door
end

function GetLocalPed()
  return GetPlayerPed(PlayerId())
end

function GetPlayers()
  local players = {}
  for i = 0, 32 do
    if NetworkIsPlayerActive(i) then
      table.insert(players, i)
    end
  end
  return players
end

function GetPlayerId(target_ped)
  local players = GetPlayers()
  for a = 1, #players do
    local ped = GetPlayerPed(players[a])
    local server_id = GetPlayerServerId(players[a])
    if target_ped == ped then
      return server_id
    end
  end
  return 0
end

function Notification(message)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(message)
  DrawNotification(0, 1)
end

loadDict = function(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) RequestAnimDict(dict) end
end
