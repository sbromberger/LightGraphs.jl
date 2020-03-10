using LightGraphs.SimpleGraphs

import LightGraphs.SimpleGraphs: fadj, badj, adj
import LightGraphs.edgetype, LightGraphs.has_edge
using Statistics: mean

struct DummySimpleGraph <: AbstractSimpleGraph{Int} end
struct DummySimpleEdge <: AbstractSimpleEdge{Int} end
DummySimpleEdge(x...) = DummySimpleEdge()
LightGraphs.edgetype(g::DummySimpleGraph) = DummySimpleEdge
has_edge(::DummySimpleGraph, ::DummySimpleEdge) = true

# function to check if the invariants for SimpleGraph and SimpleDiGraph holds
function isvalid_simplegraph(g::SimpleGraph{T}) where {T <: Integer}
    nf = length(g.fadjlist)
    n = T(nf)
    # checks it the adjacency lists are sorted, free of duplicates and in the correct range
    for u in one(T):n
        listu = g.fadjlist[u]
        isempty(listu) && continue
        issorted(listu) || return false
        allunique(listu) || return false
        issubset(extrema(listu), one(T):n) || return false
    end
    # checks if the edge count is correct
    edge_count = 0
    for u in one(T):n
        listu = g.fadjlist[u]
        for v in listu
            v > u && break
            edge_count += 1
        end
    end
    g.ne == edge_count || return false
    #  checks for backwards edge
    for u in one(T):n
        listu = g.fadjlist[u]
        for v in listu
            LightGraphs.insorted(u, g.fadjlist[v]) || return false
        end
    end
    return true
end

function isvalid_simplegraph(g::SimpleDiGraph{T}) where {T <: Integer}
    nf = length(g.fadjlist)
    nb = length(g.badjlist)
    nf == nb || return false
    n = T(nf)

    for u in one(T):n
        for listu in (g.fadjlist[u], g.badjlist[u])
            listu = g.fadjlist[u]
            isempty(listu) && continue
            issorted(listu) || return false
            allunique(listu) || return false
            issubset(extrema(listu), one(T):n) || return false
        end
    end
    # checks if the edge count is correct
    edge_count = 0
    for u in one(T):n
        edge_count += length(g.fadjlist[u])
    end
    g.ne == edge_count || return false
    edge_count = 0
    for u in one(T):n
        edge_count += length(g.badjlist[u])
    end
    g.ne == edge_count || return false
    #  checks for backwards edge
    for u in one(T):n
        listu = g.fadjlist[u]
        for v in listu
            LightGraphs.insorted(u, g.badjlist[v]) || return false
        end
    end
    return true
end

const simplegraphtestdir = dirname(@__FILE__)

const simple_tests = [
    "simplegraphs",
    "simpleedge",
    "simpleedgeiter",
    "generators/randgraphs",
    "generators/staticgraphs",
    "generators/smallgraphs",
    "generators/euclideangraphs",
]

@testset "LightGraphs.SimpleGraphs" begin
    for t in simple_tests
        tp = joinpath(simplegraphtestdir, "$(t).jl")
        println("Testing $(tp)")
        include(tp)
    end
end
