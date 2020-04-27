function euclidean_graph(points::AbstractMatrix, L, p, cutoff, periodic, return_weights, return_points, rng)
    d, N = size(points)
    weights = Dict{SimpleEdge{Int}, Float64}()
    for i = 1:N
        for j = (i + 1):N
            if !periodic
                Δ = points[:, i] - points[:, j]
            else
                Δ = abs.(points[:, i] - points[:, j])
                Δ = min.(L .- Δ, Δ)
            end
            dist = norm(Δ, p)
            if dist < cutoff
                e = SimpleEdge(i, j)
                weights[e] = dist
            end
        end
    end
    g = LightGraphs.SimpleGraphs._SimpleGraphFromIterator(keys(weights), Int)
    if nv(g) < N
        add_vertices!(g, N - nv(g))
    end
    return_weights && return_points && return (g, weights, points)
    return_weights && return (g, weights)
    return_points && return (g, points)
    return g
end

SimpleGraph(alg::Euclidean) =
    euclidean_graph(alg.points, alg.L, alg.p, alg.cutoff, alg.periodic, alg.return_weights, alg.return_points, alg.rng)
