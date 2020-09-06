function combo_breaker_start( keys )
    local caster = keys.caster
    local ability = keys.ability

    caster:RemoveModifierByName("modifier_invoker_tornado_datadriven_cyclone")
    caster.tornado_broken = true
    caster:Purge(false, true, false, true, true)
end
