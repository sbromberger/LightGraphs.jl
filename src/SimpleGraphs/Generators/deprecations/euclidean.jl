function euclidean_graph(N::Int, d::Int;
    L=1., seed = -1, kws...)
    rng = LightGraphs.getRNG(seed)
    points = rmul!(rand(rng, d, N), L)
    return (euclidean_graph(points; L=L, kws...)..., points)
end

function euclidean_graph(points::Matrix;
    L=1., p=2., cutoff=-1., bc=:open)
    d, N = size(points)
    weights = Dict{SimpleEdge{Int},Float64}()
    cutoff < 0. && (cutoff = typemax(Float64))
    Base.depwarn("`euclidean_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Euclidean`.", :euclidean_graph)

    bc == :periodic || bc == :open || throw(ArgumentError("$bc is not a valid boundary condition"))

    periodic = bc == :periodic
    gen = Euclidean(points, L, p, cutoff, periodic, true, false, GLOBAL_RNG)
    SimpleGraph(gen)
end




