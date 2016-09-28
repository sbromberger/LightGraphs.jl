"""
    euclidean_graph(points::Matrix, L=1., p=2., cutoff=-1., bc=:open)

Given the `d×N` matrix `points` builds an Euclidean graph of `N` vertices
according to the following procedure.

Defining the `d`-dimensional vectors `x[i] = points[:,i]`, an edge between
vertices `i` and `j` is inserted if `norm(x[i]-x[j], p) < cutoff`.
In case of negative `cutoff` instead every edge is inserted.
For `p=2` we have the standard Euclidean distance.
Set `bc=:periodic` to impose periodic boundary conditions in the box ``[0,L]^d``.

Returns a graph and Dict containing the distance on each edge.


    euclidean_graph(N, d; seed = -1, L=1., p=2., cutoff=-1., bc=:open)

Generates `N` uniformly distributed points in the box ``[0,L]^d``
and builds and Euclidean graph.

Returns a graph, a Dict containing the distance on each edge and a matrix with
the points' positions.
"""
function euclidean_graph end

function euclidean_graph(N::Int, d::Int;
            L=1., seed = -1, kws...)
    rng = LightGraphs.getRNG(seed)
    points = scale!(rand(rng, d, N), L)
    return (euclidean_graph(points; L=L, kws...)..., points)
end

function euclidean_graph(points::Matrix;
            L=1., p=2., cutoff=-1., bc=:open)
    d, N = size(points)
    g = Graph(N)
    weights = Dict{Edge,Float64}()
    cutoff < 0. && (cutoff=typemax(Float64))
    if bc == :periodic
        maximum(points) > L &&  error("Some points are outside the box of size $L.")
    end
    for i=1:N
        for j=i+1:N
            if bc == :open
                Δ = points[:,i]-points[:,j]
            elseif bc == :periodic
                Δ = abs.(points[:,i]-points[:,j])
                Δ = min.(L - Δ, Δ)
            else
                error("Not a valid boundary condition.")
            end
            dist = norm(Δ, p)
            if dist < cutoff
                e = Edge(i,j)
                add_edge!(g, e)
                weights[e] = dist
            end
        end
    end
    return g, weights
end
