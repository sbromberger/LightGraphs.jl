"""
    maximum_weight_maximal_matching{T<:Number}(g, w::Dict{Edge,T})
    maximum_weight_maximal_matching{T<:Number}(g, w::Dict{Edge,T}, cutoff)

Given a bipartite graph `g` and an edgemap `w` containing weights associated to edges,
returns a matching with the maximum total weight among the ones containing the
greatest number of edges.

Edges in `g` not present in `w` will not be considered for the matching.

The algorithm relies on a linear relaxation on of the matching problem, which is
guaranteed to have integer solution on bipartite graps.

Eventually a `cutoff` argument can be given, to reduce computational times
excluding edges with weights lower than the cutoff.

The package JuMP.jl and one of its supported solvers is required.

The returned object is of type

    type MatchingResult
        weight::Float64
        inmatch::Dict{Edge,Bool}
        m::Vector{Int}
    end

where

weight: total weight of the matching

inmatch: `inmatch[e]=true` if edge `e` belongs to the matching.

m:       `m[i]=j` if vertex `i` is matched to vertex `j`.
         `m[i]=-1` for unmatched vertices.
"""
maximum_weight_maximal_matching(args...; kws...) = isdefined(:JuMP) ?  error("wrong arguments") : error("JuMP is required")

@require JuMP begin

type MatchingResult
    weight::Float64
    inmatch::Dict{Edge,Bool}
    m::Vector{Int}
end



function maximum_weight_maximal_matching{T<:Number}(g::Graph, w::Dict{Edge,T}, cutoff)
    wnew = Dict{Edge,T}()
    for (e,x) in w
        if x >= cutoff
            wnew[e] = x
        end
    end

    return maximum_weight_maximal_matching(g, wnew)
end


function maximum_weight_maximal_matching{T<:Number}(g::Graph, w::Dict{Edge,T})
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
    edgemap = Dict{Edge,Int}()
    for (e,_) in w
        nedg += 1
        edgemap[e] = nedg
        edgemap[reverse(e)] = nedg
    end

    model = Model()
    @variable(model, x[1:length(w)] >= 0)

    for i in v1
        idx = Vector{Int}()
        for j in neighbors(g, i)
            if haskey(edgemap, Edge(i,j))
                push!(idx, edgemap[Edge(i,j)])
            end
        end
        if length(idx) > 0
            @constraint(model, sum{x[id], id=idx} == 1)
        end
    end

    for j in v2
        idx = Vector{Int}()
        for i in neighbors(g, j)
            if haskey(edgemap, Edge(i,j))
                push!(idx, edgemap[Edge(i,j)])
            end
        end

        if length(idx) > 0
            @constraint(model, sum{x[id], id=idx} <= 1)
        end
    end

    @objective(model, Max, sum{c * x[edgemap[e]], (e,c)=w})

    status = solve(model)
    status != :Optimal && error("JuMP solver failed to find optimal solution.")
    sol = getValue(x)

    all(Bool[s == 1 || s == 0 for s in sol]) || error("Found non-integer solution.")

    cost = getObjectiveValue(model)

    inmatch = Dict{Edge,Bool}()
    m = fill(-1, nv(g))
    for e in edges(g)
        if haskey(w, e)
            inmatch[e] = convert(Bool, sol[edgemap[e]])
            if inmatch[e]
                m[src(e)] = dst(e)
                m[dst(e)] = src(e)
            end
        else
            inmatch[e] = false
        end
    end

    return MatchingResult(cost, inmatch, m)
end
end # @require
