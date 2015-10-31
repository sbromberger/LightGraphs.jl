"""
An optimal matching.

weight: total weight of the matching

inmatch: `inmatch[e]=true` if edge `e` belongs to the matching.

π:       `π[i]=j` if vertex `i` is matched to vertex `j`.
         `π[i]=-1` for unmatched vertices.
"""
type MatchingResult
    weight::Float64
    inmatch::Dict{Edge,Bool}
    π::Vector{Int}
end

"""
As `maximum_weigth_maximal_matching`, with the difference that the edges `e` with
`w[e] < cutoff` will not be considered for the matching.
"""
function maximum_weigth_maximal_matching{T<:Number}(g::Graph, w::Dict{Edge,T}, cutoff)
    wnew = Dict{Edge,T}()
    for (e,x) in w
        if x >= cutoff
            wnew[e] = x
        end
    end

    return maximum_weigth_maximal_matching(g, wnew)
end

"""
Given a bipartite graph `g` and an edgemap `w` containing weights associated to edges,
returns a matching with the maximum total weight among the ones containing the
greatest number of edges.
Edges in `g` not present in `w` will not be considered for the matching.
The algorithm relies on a linear relaxation on of the matching problem, which is
guaranteed to have integer solution on bipartite graps.
The pakage JuMP.jl and one of its supported solvers is required.
"""
function maximum_weigth_maximal_matching{T<:Number}(g::Graph, w::Dict{Edge,T})
# TODO support for graphs with zero degree nodes
# TODO apply separately on each connected component
    bpmap = bipartite_map(g)
    length(bpmap) != nv(g) && error("Graph is not bipartite")
    v1 = findin(bpmap, 1)
    v2 = findin(bpmap, 2)
    if length(v1) > length(v2)
        v1, v2 = v2, v1
    end
    nedg = 0
    edgemap = Dict{Edge,Int}([e => nedg+=1 for (e,w) in w])

    m = Model()
    @defVar(m, x[1:length(w)] >= 0)

    for i in v1
        idx = Int64[]
        for j in neighbors(g, i)
            if haskey(w, Edge(i,j))
                push!(idx, edgemap[Edge(i,j)])
            end
        end
        @addConstraint(m, sum{x[id], id=idx} == 1)
    end

    for j in v2
        idx = Int64[]
        for i in neighbors(g, j)
            if haskey(w, Edge(i,j))
                push!(idx, edgemap[Edge(i,j)])
            end
        end

        @addConstraint(m, sum{x[id], id=idx} <= 1)
    end

    @setObjective(m, Max, sum{c * x[edgemap[e]], (e,c)=w})

    status = solve(m)
    status != :Optimal && error("Failure")
    sol = getValue(x)

    #check solution
    all(Bool[s == 1 || s == 0 for s in sol])

    cost = getObjectiveValue(m)

    inmatch = Dict{Edge,Bool}()
    pi = fill(-1, nv(g))
    for e in edges(g)
        if haskey(w, e)
            inmatch[e] = convert(Bool, sol[edgemap[e]])
            if inmatch[e]
                pi[src(e)] = dst(e)
                pi[dst(e)] = src(e)
            end
        else
            inmatch[e] = false
        end
    end

    return MatchingResult(cost, inmatch, pi)
end
