#=
boruvka_multithread_lightgraph:
- Julia version: 1.3.1
- Author: hanstananda
- Date: 2020-03-15
=#
@everywhere using LightGraphs, SimpleWeightedGraphs
using CPUTime
using DelimitedFiles
@everywhere using Base
@everywhere using DataStructures
using SharedArrays

"""
    boruvka_mst_distributed(g)

Return a tuple `(mst, weights)` where `mst` is a vector of edges representing the
optimum (minimum, by default) spanning tree of a connected, undirected graph
`g` , and `weights` is the sum of all the edges in the solution by using
[Boruvka's algorithm](https://en.wikipedia.org/wiki/Bor%C5%AFvka%27s_algorithm).
The algorithm requires that all edges have different weights to correctly generate a minimun/maximum spanning tree
### Optional parameter(s):
`maxItr`: Used to limit maximum number of iterations the algorithm will be performed. The default is log2(numVertex).
"""
function boruvka_mst_distributed(g::SimpleWeightedGraph, maxItr = convert(Int64, round(log2(nv(g))+1, digits=0)))
    connected_vs = IntDisjointSets(nv(g))
    joined_nodes = Dict{Int, Vector{Int}}(i=>[i] for i in 1:nv(g))
    MAX_WEIGHT=2000000000.0
    minCost = SharedArray{Float64}(nv(g)+1)
    minNodeTgt = SharedArray{Int}(nv(g)+1)
    minNodeSrc = SharedArray{Int}(nv(g)+1)
    mst = Vector{edgetype(g)}()
    sizehint!(mst, nv(g) - 1)
    res =0
    i=1
    println("Max iteration: ", maxItr)
    while(i<maxItr && length(mst)< nv(g)-1)
        i+=1
        initMinCostArray(g, minNodeSrc, minNodeTgt, minCost, MAX_WEIGHT)
        findMinCostVertex(g, minNodeSrc, minNodeTgt, minCost, joined_nodes, connected_vs)
        res+= contractVertex(g, minNodeSrc, minNodeTgt, minCost, joined_nodes, connected_vs,
                mst, MAX_WEIGHT)
    end

    return (mst=mst, weight=res)
end

function initMinCostArray(
        g::SimpleWeightedGraph,
        minNodeSrc::SharedArray{Int,1},
        minNodeTgt::SharedArray{Int,1},
        minCost::SharedArray{Float64,1},
        MAX_WEIGHT::Float64
    )
    for i = 1:nv(g)
        minCost[i] = MAX_WEIGHT
        minNodeTgt[i] = i
        minNodeSrc[i] = i
    end
end

function findMinCostVertex(
        g::SimpleWeightedGraph,
        minNodeSrc::SharedArray{Int},
        minNodeTgt::SharedArray{Int},
        minCost::SharedArray{Float64},
        joined_nodes::Dict{Int, Vector{Int}},
        connected_vs::IntDisjointSets,
    )
    sets = Vector{Int}(first.(keys(joined_nodes)))
    @sync @distributed for i in sets
        # println("Accessing set ",i, " with sources ", joined_nodes[i])
        for src in joined_nodes[i]
            for dst in neighbors(g, src)
                weight = get_weight(g,src,dst)
                # println(src," -> ", dst, "=", weight, " ",  !in_same_set(connected_vs, src, dst) )
                root_src = find_root(connected_vs, src)
                root_dst = find_root(connected_vs, dst)
                if root_src != root_dst
                    if(minCost[root_src] > weight )
                        minCost[root_src] = weight
                        minNodeTgt[root_src] = dst
                        minNodeSrc[root_src] = src
                    end
                end
            end

        end
    end
end

function contractVertex(
        g::SimpleWeightedGraph,
        minNodeSrc::SharedArray{Int},
        minNodeTgt::SharedArray{Int},
        minCost::SharedArray{Float64},
        joined_nodes::Dict{Int, Vector{Int}},
        connected_vs::IntDisjointSets,
        mst::Vector,
        MAX_WEIGHT::Float64
    )::Int
    res = 0
    for i in 1:nv(g)
        if(minCost[i]!= MAX_WEIGHT && !in_same_set(connected_vs, minNodeSrc[i], minNodeTgt[i]))
            # Connect the vertices, add mst to answer
            set1 = find_root(connected_vs, minNodeSrc[i])
            set2 = find_root(connected_vs, minNodeTgt[i])
            union!(connected_vs, minNodeSrc[i], minNodeTgt[i])
            res+=minCost[i]
            push!(mst, SimpleWeightedEdge(minNodeSrc[i], minNodeTgt[i], minCost[i]))
            # Merge Vertices that has been connected together
            merge_target = find_root(connected_vs, minNodeSrc[i])
            if merge_target!=set1
                for j in joined_nodes[set1]
                    push!(joined_nodes[merge_target],j)
                end
                delete!(joined_nodes,set1)
            end
            if merge_target!=set2
                for j in joined_nodes[set2]
                    push!(joined_nodes[merge_target],j)
                end
                delete!(joined_nodes,set2)
            end
        end
    end
    return res
end

