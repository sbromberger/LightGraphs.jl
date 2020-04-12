function core_number(g::AbstractGraph{T}) where T
    Base.depwarn("`core_number` is deprecated. Equivalent functionality has been moved to `LightGraphs.Degeneracy.core_number`.", :core_number)
    return LightGraphs.Degeneracy.core_number(g)
end

function k_core(g::AbstractGraph, k=-1; corenum=core_number(g))
    Base.depwarn("`k_core` is deprecated. Equivalent functionality has been moved to `LightGraphs.Degeneracy.decompose`.", :k_core)
    return LightGraphs.Degeneracy.decompose(g, LightGraphs.Degeneracy.KCore(k), corenum)
end

function k_shell(g::AbstractGraph, k=-1; corenum=core_number(g))
    Base.depwarn("`k_shell` is deprecated. Equivalent functionality has been moved to `LightGraphs.Degeneracy.decompose`.", :k_shell)
    return LightGraphs.Degeneracy.decompose(g, LightGraphs.Degeneracy.KShell(k), corenum)
end

function k_crust(g::AbstractGraph, k=-1; corenum=core_number(g))
    Base.depwarn("`k_crust` is deprecated. Equivalent functionality has been moved to `LightGraphs.Degeneracy.decompose`.", :k_crust)
    return LightGraphs.Degeneracy.decompose(g, LightGraphs.Degeneracy.KCrust(k), corenum)
end

function k_corona(g::AbstractGraph, k=-1; corenum=core_number(g))
    Base.depwarn("`k_corona` is deprecated. Equivalent functionality has been moved to `LightGraphs.Degeneracy.decompose`.", :k_corona)
    return LightGraphs.Degeneracy.decompose(g, LightGraphs.Degeneracy.KCorona(k), corenum)
end
