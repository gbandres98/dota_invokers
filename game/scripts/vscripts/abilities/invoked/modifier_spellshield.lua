modifier_spellshield = class({})

function modifier_spellshield:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_REFLECT_SPELL,
		MODIFIER_PROPERTY_ABSORB_SPELL,
	}

	return funcs
end

function modifier_spellshield:GetAbsorbSpell( params )
	if IsServer() then
        self:PlayEffects( true )
        self:GetParent():RemoveModifierByName( "modifier_spellshield" )
        return 1
	end
end

function modifier_spellshield:GetReflectSpell( params )
	if IsServer() then
        self.reflect = true

        local sourceAbility = params.ability

        print(sourceAbility:GetAbilityName())

        local selfAbility = self:GetParent():FindAbilityByName( sourceAbility:GetAbilityName() )
        selfAbility:SetLevel( sourceAbility:GetLevel() )
        selfAbility:SetHidden( true )

        self:GetParent():SetCursorCastTarget( sourceAbility:GetCaster() )
        selfAbility:CastAbility()

        self:PlayEffects( false )
        return 1
	end
end
--------------------------------------------------------------------------------
function modifier_spellshield:PlayEffects( bBlock )
	-- Get Resources
	local particle_cast = ""
	local sound_cast = ""

	if bBlock then
		particle_cast = "particles/units/heroes/hero_antimage/antimage_spellshield.vpcf"
		sound_cast = "Hero_Antimage.SpellShield.Block"
	else
		particle_cast = "particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf"
		sound_cast = "Hero_Antimage.SpellShield.Reflect"
	end

	-- Play particles
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		self:GetParent():GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Play sounds
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_spellshield:OnCreated( kv )
    local caster = self:GetCaster()

    print("a")

    local particle_cast = "particles/units/heroes/hero_antimage/antimage_counter.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_ROOTBONE_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( 90, 80, 0 ) )

	-- buff particle
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end
