function invoker_replace_orb(keys, particle_filepath)
	--Initialization for storing the orb properties, if not already done.
	if keys.caster.invoked_orbs == nil then
		keys.caster.invoked_orbs = {}
	end
	if keys.caster.invoked_orbs_particle == nil then
		keys.caster.invoked_orbs_particle = {}
	end
	if keys.caster.invoked_orbs_particle_attach == nil then
		keys.caster.invoked_orbs_particle_attach = {}
		keys.caster.invoked_orbs_particle_attach[1] = "attach_orb1"
		keys.caster.invoked_orbs_particle_attach[2] = "attach_orb2"
        keys.caster.invoked_orbs_particle_attach[3] = "attach_orb3"
	end

	--Invoker can only have three orbs active at any time.  Each time an orb is activated, its hscript is
	--placed into keys.caster.invoked_orbs[3], the old [3] is moved into [2], and the old [2] is moved into [1].
	--Therefore, the oldest orb is located in [1], and the newest is located in [3].
	--Now, shift the ordered list of currently summoned orbs down, and add the newest orb to the queue.
	keys.caster.invoked_orbs[1] = keys.caster.invoked_orbs[2]
	keys.caster.invoked_orbs[2] = keys.caster.invoked_orbs[3]
	keys.caster.invoked_orbs[3] = keys.ability

	--Remove the removed orb's particle effect.
	if keys.caster.invoked_orbs_particle[1] ~= nil then
		ParticleManager:DestroyParticle(keys.caster.invoked_orbs_particle[1], false)
		keys.caster.invoked_orbs_particle[1] = nil
	end

	--Shift the ordered list of currently summoned orb particle effects down, and create the new particle.
	keys.caster.invoked_orbs_particle[1] = keys.caster.invoked_orbs_particle[2]
	keys.caster.invoked_orbs_particle[2] = keys.caster.invoked_orbs_particle[3]
	keys.caster.invoked_orbs_particle[3] = ParticleManager:CreateParticle(particle_filepath, PATTACH_OVERHEAD_FOLLOW, keys.caster)
	ParticleManager:SetParticleControlEnt(keys.caster.invoked_orbs_particle[3], 1, keys.caster, PATTACH_POINT_FOLLOW, keys.caster.invoked_orbs_particle_attach[1], keys.caster:GetAbsOrigin(), false)

	--Shift the ordered list of currently summoned orb particle effect attach locations down.
	local temp_attachment_point = keys.caster.invoked_orbs_particle_attach[1]
	keys.caster.invoked_orbs_particle_attach[1] = keys.caster.invoked_orbs_particle_attach[2]
	keys.caster.invoked_orbs_particle_attach[2] = keys.caster.invoked_orbs_particle_attach[3]
	keys.caster.invoked_orbs_particle_attach[3] = temp_attachment_point

	invoker_replace_orb_modifiers(keys)  --Remove and reapply the orb instance modifiers.
end



function invoker_replace_orb_modifiers(keys)
	--Initialization for storing the orb list, if not already done.
	if keys.caster.invoked_orbs == nil then
		keys.caster.invoked_orbs = {}
	end

	--Reapply all the orbs Invoker has out in order to benefit from the upgraded ability's level.  By reapplying all
	--three orb modifiers, they will maintain their order on the modifier bar (so long as all are removed before any
	--are reapplied, since ordering problems arise if there are two of the same type of orb otherwise).
	while keys.caster:HasModifier("modifier_invoker_quas_datadriven_instance") do
		keys.caster:RemoveModifierByName("modifier_invoker_quas_datadriven_instance")
	end
	while keys.caster:HasModifier("modifier_invoker_wex_datadriven_instance") do
		keys.caster:RemoveModifierByName("modifier_invoker_wex_datadriven_instance")
	end
	while keys.caster:HasModifier("modifier_invoker_exort_datadriven_instance") do
		keys.caster:RemoveModifierByName("modifier_invoker_exort_datadriven_instance")
    end
    while keys.caster:HasModifier("modifier_invoker_durc_datadriven_instance") do
		keys.caster:RemoveModifierByName("modifier_invoker_durc_datadriven_instance")
	end

	--Reapply the orb modifiers in the correct order.
	for i=1, 3, 1 do
		if keys.caster.invoked_orbs[i] ~= nil then
			local orb_name = keys.caster.invoked_orbs[i]:GetName()
			if orb_name == "quas_datadriven" then
				local quas_ability = keys.caster:FindAbilityByName("quas_datadriven")
				if quas_ability ~= nil then
					quas_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_quas_datadriven_instance", nil)
				end
			elseif orb_name == "wex_datadriven" then
				local wex_ability = keys.caster:FindAbilityByName("wex_datadriven")
				if wex_ability ~= nil then
					wex_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_wex_datadriven_instance", nil)
				end
			elseif orb_name == "exort_datadriven" then
				local exort_ability = keys.caster:FindAbilityByName("exort_datadriven")
				if exort_ability ~= nil then
					exort_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_exort_datadriven_instance", nil)
				end
			elseif orb_name == "durc_datadriven" then
				local durc_ability = keys.caster:FindAbilityByName("durc_datadriven")
				if durc_ability ~= nil then
					durc_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_durc_datadriven_instance", nil)
				end
			end
		end
    end

    invoke(keys)
end

function invoke( keys )
	-- Print a message
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	caster.invoked_orbs = caster.invoked_orbs or {}
	local max_invoked_spells = ability:GetLevelSpecialValueFor("max_invoked_spells", ability_level)
	local invoker_empty3 = "invoker_empty3_datadriven"
	local invoker_slot1 = caster:GetAbilityByIndex(5):GetAbilityName() -- Invoked spell
	local spell_to_be_invoked

	--Play the particle effect with the general color.
	local invoke_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_invoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)

	-- If we have 3 invoked orbs then do the Invoke logic
	if caster.invoked_orbs[1] and caster.invoked_orbs[2] and caster.invoked_orbs[3] then
		--The Invoke particle effect changes color depending on which orbs are out.
		local quas_particle_effect_color = Vector(0, 153, 204)
		local wex_particle_effect_color = Vector(204, 0, 153)
		local exort_particle_effect_color = Vector(255, 102, 0)

		local num_quas_orbs = 0
		local num_wex_orbs = 0
		local num_exort_orbs = 0
		local num_durc_orbs = 0
		for i=1, 3, 1 do
			if keys.caster.invoked_orbs[i]:GetName() == "quas_datadriven" then
				num_quas_orbs = num_quas_orbs + 1
			elseif keys.caster.invoked_orbs[i]:GetName() == "wex_datadriven" then
				num_wex_orbs = num_wex_orbs + 1
			elseif keys.caster.invoked_orbs[i]:GetName() == "exort_datadriven" then
				num_exort_orbs = num_exort_orbs + 1
			elseif keys.caster.invoked_orbs[i]:GetName() == "durc_datadriven" then
				num_durc_orbs = num_durc_orbs + 1
			end
		end

		--Set the Invoke particle effect's color depending on which orbs are invoked.
		ParticleManager:SetParticleControl(invoke_particle_effect, 2, ((quas_particle_effect_color * num_quas_orbs) + (wex_particle_effect_color * num_wex_orbs) + (exort_particle_effect_color * num_exort_orbs)) / 3)

		-- Determine the invoked spell depending on which orbs are in use.
		if num_quas_orbs == 3 then
			spell_to_be_invoked = "cold_snap_datadriven"   								--QQQ
		elseif num_quas_orbs == 2 and num_wex_orbs == 1 then
			spell_to_be_invoked = "vengefulspirit_magic_missile"						--QQW
		elseif num_quas_orbs == 2 and num_exort_orbs == 1 then
			spell_to_be_invoked = "invoker_sprout_datadriven"							--QQE
		elseif num_wex_orbs == 3 then
			spell_to_be_invoked = "skywrath_mage_concussive_shot"						--WWW
		elseif num_wex_orbs == 2 and num_quas_orbs == 1 then
			spell_to_be_invoked = "tornado_datadriven"									--QWW
		elseif num_wex_orbs == 2 and num_exort_orbs == 1 then
			spell_to_be_invoked = "alacrity_datadriven"									--WWE
		elseif num_exort_orbs == 3 then
			spell_to_be_invoked = "sun_strike_datadriven"								--EEE
		elseif num_exort_orbs == 2 and num_quas_orbs == 1 then
			spell_to_be_invoked = "forge_spirit_datadriven"								--QEE
		elseif num_exort_orbs == 2 and num_wex_orbs == 1 then
			spell_to_be_invoked = "chaos_meteor_datadriven"								--WEE
		elseif num_quas_orbs == 1 and num_wex_orbs == 1 and num_exort_orbs == 1 then
			spell_to_be_invoked = "deafening_blast_datadriven"							--QWE
		elseif num_durc_orbs == 1 and num_quas_orbs == 1 and num_wex_orbs == 1 then
			spell_to_be_invoked = "mars_spear"									        --QWD
		elseif num_durc_orbs == 3 then
			spell_to_be_invoked = "tinker_rearm"										--DDD
		elseif num_durc_orbs == 2 and num_quas_orbs==1 then
			spell_to_be_invoked = "combo_breaker"	    							    --QDD
		elseif num_durc_orbs == 2 and num_wex_orbs==1 then
			spell_to_be_invoked = "pugna_decrepify"										--WDD
		elseif num_durc_orbs == 2 and num_exort_orbs==1 then
			spell_to_be_invoked = "bloodseeker_rupture"									--EDD
		elseif num_exort_orbs == 2 and num_durc_orbs==1 then
			spell_to_be_invoked = "pangolier_lucky_shot"								--EED
		elseif num_wex_orbs == 2 and num_durc_orbs==1 then
			spell_to_be_invoked = "windrunner_powershot_datadriven"						--WWD
		elseif num_quas_orbs == 2 and num_durc_orbs==1 then
			spell_to_be_invoked = "spellshield"         								--QQD
		elseif num_durc_orbs == 1 and num_exort_orbs == 1 and num_quas_orbs == 1 then
			spell_to_be_invoked = "antimage_blink"										--QED
		elseif num_durc_orbs == 1 and num_wex_orbs==1 and num_exort_orbs==1 then
			spell_to_be_invoked = "puck_phase_shift"									--WED
		end

		-- If its only 1 max invoke spell then just swap abilities in the same slot
        if spell_to_be_invoked and invoker_slot1 ~= spell_to_be_invoked then
            print(spell_to_be_invoked)
            caster:SwapAbilities(invoker_slot1, spell_to_be_invoked, false, true)
			if invoker_slot1 == "pangolier_lucky_shot" then
				caster:FindAbilityByName(invoker_slot1):SetLevel(0)
			end

			caster:FindAbilityByName(spell_to_be_invoked):SetLevel(1)
        end

	end
end
