--[[Author: YOLOSPAGHETTI
	Date: March 22, 2016
	Creates the sprout]]
    -- function CreateSprout(keys)
    --     local caster = keys.caster
    --     local ability = keys.ability

    --     local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
    --     local vision_range = ability:GetLevelSpecialValueFor("vision_range", (ability:GetLevel() -1))
    --     local trees = 7

    --     local cursor = ability:GetCursorPosition()
    --     local heroPosition = caster:GetCenter()

    --     local heroToCursorVector = heroPosition - cursor
    --     local radius = heroToCursorVector:Length()
    --     print("radius: " .. radius)

    --     local cosAngleToPoint = DotProduct(Vector(heroToCursorVector.x, heroToCursorVector.y, 0), Vector(1, 0, heroPosition.z)) / heroToCursorVector:Length()
    --     print("cosAngleToPoint: " .. cosAngleToPoint)
    --     local angle = math.acos(cosAngleToPoint)
    --     print("angle: " .. angle)

    --     local angleOffset = 15/radius

    --     local position = Vector(heroPosition.x + radius * math.sin(angle), heroPosition.y + radius * math.cos(angle), cursor.z)
    --     CreateTempTree(position, duration)

    --     -- Creates 8 temporary trees at each 45 degree interval around the clicked point
    --     -- for i=-3*angleOffset,3*angleOffset,angleOffset do

    --     --     local position = Vector(heroPosition.x + radius * math.sin(angle+i), heroPosition.y + radius * math.cos(angle+i), heroPosition.z)


    --     --     CreateTempTree(position, duration)

    --     --     --local position = Vector(point.x+radius*math.sin(angle), point.y+radius*math.cos(angle), point.z)
    --     --     --CreateTempTree(position, duration)
    --     --     --angle = angle + math.pi/4


    --     -- end
    --     -- Gives vision to the caster's team in a radius around the clicked point for the duration
    --     AddFOWViewer(caster:GetTeam(), cursor, vision_range, duration, false)
    -- end

function CreateSprout(keys)
    local caster = keys.caster
    local ability = keys.ability

    treeModel = "models/props_magic/bad_crystals003.vmdl"

    local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
    local vision_range = ability:GetLevelSpecialValueFor("vision_range", (ability:GetLevel() -1))
    local trees = 7

    local cursor = ability:GetCursorPosition()
    cursor.z = 0
    local heroPosition = caster:GetCenter()
    heroPosition.z = 0

    local heroToCursorVector = cursor - heroPosition
    local radius = heroToCursorVector:Length()

    if radius == 0 then
        local casterForwardVector = keys.target:GetForwardVector()
        heroToCursorVector = casterForwardVector * 190
        radius = heroToCursorVector:Length()
    end

    if radius > 0 and radius < 190 then
        heroToCursorVector = heroToCursorVector * 190 / heroToCursorVector:Length()
        radius = heroToCursorVector:Length()
    end

    for i = -2, 2, 1 do

        local rotation = i*100/radius

        local newXAxis = Vector(math.cos(rotation), math.sin(rotation), 0)
        local newYAxis = Vector(math.cos(rotation + (math.pi / 2)), math.sin(rotation + (math.pi / 2)), 0)

        local sproutPositionRelative = Vector(heroToCursorVector.x * newXAxis.x + heroToCursorVector.y * newYAxis.x, heroToCursorVector.x * newXAxis.y + heroToCursorVector.y * newYAxis.y, caster:GetCenter().z)
        local sproutPosition = sproutPositionRelative + heroPosition

        --CreateTempTree(sproutPosition, duration)
        CreateTempTreeWithModel(sproutPosition, duration,treeModel)
        
    end

    AddFOWViewer(caster:GetTeam(), cursor, vision_range, duration, false)
end
