module FastGraphs

    using GZip

    import Base:write, ==, issubset, show, print

# package code goes here
    export AbstractFastGraph, Edge, FastGraph, FastDiGraph, vertices, edges, in_edges, out_edges,
    has_vertex, has_edge,
    nv, ne, add_edge!, add_vertex!,
    indegree, outdegree, degree, degree_histogram, density, Δ, δ,

    neighbors, all_neighbors, common_neighbors,

    a_star_sp
    include("core.jl")
    include("astar.jl")
    include("persistence.jl")
    include("randgraphs.jl")
end # module
