spellshield = class({})
LinkLuaModifier( "modifier_spellshield", "abilities/invoked/modifier_spellshield", LUA_MODIFIER_MOTION_NONE )

function spellshield:OnSpellStart()
	EmitSoundOn( "Hero_Antimage.Counterspell.Target", self:GetCaster() )
end

function spellshield:OnChannelFinish( bInterrupted )
    if bInterrupted then return end

    local duration = self:GetSpecialValueFor("duration")

    EmitSoundOn( "Hero_Antimage.Counterspell.Cast", self:GetCaster() )
	self:GetCaster():AddNewModifier( self:GetCaster(), self:GetCaster(), "modifier_spellshield", { duration = duration } )
end
