function simplecycles_limited_length(g::AbstractGraph{T}, n::Int, ceiling = 10^6) where {T}
    Base.depwarn("`simplecycles_limited_length` is deprecated. Equivalent functionality has been moved to `LightGraphs.Cycles.simple_cycles`.", :simplecycles_limited_length)
    LightGraphs.Cycles.simple_cycles(g, LightGraphs.Cycles.LimitedLength(n, ceiling=ceiling))
end

