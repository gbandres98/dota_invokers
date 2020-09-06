--[[Author: YOLOSPAGHETTI
	Date: March 22, 2016
	Creates the sprout]]
    function CreateSprout(keys)
        local caster = keys.caster
        local ability = keys.ability
        local point = ability:GetCursorPosition()
        local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
        local vision_range = ability:GetLevelSpecialValueFor("vision_range", (ability:GetLevel() -1))
        local trees = 7
        local heroPosition = caster.GetCenter()
        local radius = position.Length(heroPosition-point)
        local cosAngleToPoint = DotProduct(point,heroPosition)/ point.Length()/heroPosition.Length()
        local angle = math.acos(cosAngleToPoint)
        local angleOffset = 2*math.pi*radius/15

        -- Creates 8 temporary trees at each 45 degree interval around the clicked point
        for i=-3*angleOffset,3*angleOffset,angleOffset do
            local position = Vector(heroPosition.x+radius*math.sin(angle+i),heroPosition.y+radius*math.cos(angle+i), heroPosition.z)
            CreateTempTree(position, duration)
            --local position = Vector(point.x+radius*math.sin(angle), point.y+radius*math.cos(angle), point.z)
            --CreateTempTree(position, duration)
            --angle = angle + math.pi/4
            
            
        end
        -- Gives vision to the caster's team in a radius around the clicked point for the duration
        AddFOWViewer(caster:GetTeam(), point, vision_range, duration, false)
    end
    