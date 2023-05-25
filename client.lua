local isEventActive = false
local isTransporterSpawned = false
local transporterVehicle = nil

-- Function to start the money transport event
function StartMoneyTransportEvent()
    isEventActive = true

    -- Spawn the transporter vehicle
    local model = GetHashKey(Config.TransportVehicleModel)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end

    local coords = Config.TransportVehicleSpawnCoords
    transporterVehicle = CreateVehicle(model, coords.x, coords.y, coords.z, GetEntityHeading(PlayerPedId()), true, false)
    SetEntityAsMissionEntity(transporterVehicle, true, true)
    SetVehicleOnGroundProperly(transporterVehicle)
    SetVehicleDoorsLocked(transporterVehicle, 2)

    -- Add polyzone, qb-target, and other necessary logics here

    -- Display marker on the transporter vehicle
    local transporterMarker = exports["polyzone"]:AddBoxZone("transporter_marker", vector3(coords.x, coords.y, coords.z), 5.0, 5.0, {
        name = "transporter_marker",
        heading = GetEntityHeading(transporterVehicle),
        minZ = coords.z - 1.0,
        maxZ = coords.z + 1.0,
        debugPoly = false,
        useZ = true,
        data = { vehicle = transporterVehicle },
    })

    SetBlipSprite(transporterBlip, 1)
    SetBlipColour(transporterBlip, 3)
    SetBlipAsShortRange(transporterBlip, false)
    SetBlipRoute(transporterBlip, true)

    -- Handle other event-related logics here
end

-- Function to stop the money transport event
function StopMoneyTransportEvent()
    isEventActive = false

    -- Destroy transporter vehicle and marker
    if DoesEntityExist(transporterVehicle) then
        SetEntityAsMissionEntity(transporterVehicle, false, true)
        DeleteVehicle(transporterVehicle)
        transporterVehicle = nil
    end

    exports["polyzone"]:RemoveBoxZone("transporter_marker")

    -- Handle other event cleanup tasks here
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

        -- Check if it's time to start the event
        local hour = GetClockHours()
        if not isEventActive and hour == 20 then
            StartMoneyTransportEvent()
        end

        -- Check if it's time to stop the event
        if isEventActive and hour ~= 20 then
            StopMoneyTransportEvent()
        end
    end
end)
