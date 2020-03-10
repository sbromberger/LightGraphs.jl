# TODO 2.0.0: Remove this file
function randomwalk(
    g::AG,
    s::Integer,
    niter::Integer;
    seed::Int = -1,
) where {T, AG <: AbstractGraph{T}}
    Base.depwarn(
        "`randomwalk` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.walk`.",
        :randomwalk,
    )
    rng = LightGraphs.getRNG(seed)
    LightGraphs.Traversals.walk(g, s, LightGraphs.Traversals.RandomWalk(false, niter, rng))
end

function non_backtracking_randomwalk(g::AbstractGraph, s::Integer, niter::Integer; seed::Int = -1)
    Base.depwarn(
        "`non_backtracking_randomwalk` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.walk`.",
        :non_backtracking_randomwalk,
    )
    rng = LightGraphs.getRNG(seed)
    LightGraphs.Traversals.walk(g, s, LightGraphs.Traversals.RandomWalk(true, niter, rng))
end

function self_avoiding_walk(
    g::AG,
    s::Integer,
    niter::Integer;
    seed::Int = -1,
) where {AG <: AbstractGraph{T}} where {T}
    Base.depwarn(
        "`self_avoiding_walk` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.walk`.",
        :self_avoiding_walk,
    )
    rng = getRNG(seed)
    LightGraphs.Traversals.walk(g, s, LightGraphs.Traversals.SelfAvoidingWalk(niter, rng))
end
