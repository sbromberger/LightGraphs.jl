abstract type Visitor{T <: Integer} end

function maxsimplecycles(n::Integer)
    Base.depwarn("`maxsimplecycles` is deprecated. Equivalent functionality has been moved to `LightGraphs.Cycles.max_simple_cycles`.", :maxsimplecycles)
    LightGraphs.Cycles.max_simple_cycles(n)
end

@traitfn function maxsimplecycles(dg::::IsDirected, byscc::Bool=true)
    Base.depwarn("`maxsimplecycles` is deprecated. Equivalent functionality has been moved to `LightGraphs.Cycles.max_simple_cycles`.", :maxsimplecycles)
    LightGraphs.Cycles.max_simple_cycles(dg, byscc)
end

@traitfn function simplecycles(dg::::IsDirected)
    Base.depwarn("`simplecycles` is deprecated. Equivalent functionality has been moved to `LightGraphs.Cycles.simple_cycles`.", :simplecycles)
    LightGraphs.Cycles.simple_cycles(dg, LightGraphs.Cycles.Johnson())
end

@traitfn function simplecyclescount(dg::AG::IsDirected, ceiling=10^6) where {T, AG <: AbstractGraph{T}}
    Base.depwarn("`simplecyclescount` is deprecated. Equivalent functionality has been moved to `LightGraphs.Cycles.count_simple_cycles`.", :simplecyclescount)
    LightGraphs.Cycles.count_simple_cycles(dg, LightGraphs.Cycles.Johnson(ceiling=ceiling))
end

@traitfn function simplecycles_iter(dg::AG::IsDirected, ceiling=10^6) where {T, AG <: AbstractGraph{T}}
    Base.depwarn("`simplecycles_iter` is deprecated. Equivalent functionality has been moved to `LightGraphs.Cycles.simple_cycles`.", :simplecycles_iter)
    LightGraphs.Cycles.simple_cycles(dg, LightGraphs.Cycles.Johnson(iterative=true, ceiling=ceiling))
end

@traitfn function simplecycleslength(dg::AG::IsDirected, ceiling=10^6) where {T, AG <: AbstractGraph{T}}
    Base.depwarn("`simplecycleslength` is deprecated. Equivalent functionality has been moved to `LightGraphs.Cycles.simple_cycles_length`.", :simplecycleslength)
    LightGraphs.Cycles.simple_cycles_length(dg, LightGraphs.Cycles.Johnson(iterative=true, ceiling=ceiling))
end
