@doc_str """
    euclidean_graph(N, d; seed=-1, L=1., p=2., cutoff=-1., bc=:open)

Generate `N` uniformly distributed points in the box ``[0,L]^{d}``
and return a Euclidean graph, a map containing the distance on each edge and
a matrix with the points' positions.
"""
function euclidean_graph(N::Int, d::Int;
    L=1., seed = -1, kws...)
    rng = LightGraphs.getRNG(seed)
    points = rmul!(rand(rng, d, N), L)
    return (euclidean_graph(points; L=L, kws...)..., points)
end

"""
    euclidean_graph(points)

Given the `d×N` matrix `points` build an Euclidean graph of `N` vertices and
return a graph and Dict containing the distance on each edge.

### Optional Arguments
- `L=1`: used to bound the `d` dimensional box from which points are selected.
- `p=2`
- `bc=:open`

### Implementation Notes
Defining the `d`-dimensional vectors `x[i] = points[:,i]`, an edge between
vertices `i` and `j` is inserted if `norm(x[i]-x[j], p) < cutoff`.
In case of negative `cutoff` instead every edge is inserted.
For `p=2` we have the standard Euclidean distance.
Set `bc=:periodic` to impose periodic boundary conditions in the box ``[0,L]^d``.
"""
function euclidean_graph(points::Matrix;
    L=1., p=2., cutoff=-1., bc=:open)
    d, N = size(points)
    g = SimpleGraph(N)
    weights = Dict{Edge,Float64}()
    cutoff < 0. && (cutoff = typemax(Float64))
    if bc == :periodic
        maximum(points) > L && throw(ArgumentError("Some points are outside the box of size $L")) # TODO 0.7: change to DomainError with text.
    end
    for i = 1:N
        for j = (i + 1):N
            if bc == :open
                Δ = points[:, i] - points[:, j]
            elseif bc == :periodic
                Δ = abs.(points[:, i] - points[:, j])
                Δ = min.(L .- Δ, Δ)
            else
                throw(ArgumentError("$bc is not a valid boundary condition"))
            end
            dist = norm(Δ, p)
            if dist < cutoff
                e = Edge(i, j)
                add_edge!(g, e)
                weights[e] = dist
            end
        end
    end
    return g, weights
end
