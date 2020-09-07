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

    for i = -3, 3, 1 do

        local rotation = i*80/radius

        local newXAxis = Vector(math.cos(rotation), math.sin(rotation), 0)
        local newYAxis = Vector(math.cos(rotation + (math.pi / 2)), math.sin(rotation + (math.pi / 2)), 0)

        local sproutPositionRelative = Vector(heroToCursorVector.x * newXAxis.x + heroToCursorVector.y * newYAxis.x, heroToCursorVector.x * newXAxis.y + heroToCursorVector.y * newYAxis.y, caster:GetCenter().z)
        local sproutPosition = sproutPositionRelative + heroPosition

        --CreateTempTree(sproutPosition, duration)
        CreateTempTreeWithModel(sproutPosition, duration,treeModel)

    end

    AddFOWViewer(caster:GetTeam(), cursor, vision_range, duration, false)
end
