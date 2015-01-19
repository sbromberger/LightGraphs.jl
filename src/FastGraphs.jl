module FastGraphs

    using GZip
    using DataStructures
    using FastAnonymous


    import Base:write, ==, issubset, show, print

# package code goes here
    export AbstractFastGraph, Edge, FastGraph, FastDiGraph, vertices, edges, in_edges, out_edges,
    has_vertex, has_edge,
    nv, ne, add_edge!, add_vertex!,
    indegree, outdegree, degree, degree_histogram, density, Δ, δ,

    neighbors, all_neighbors, common_neighbors,
    dijkstra_predecessor_and_distance,

    # Static Graph Generation
    CompleteGraph, StarGraph, PathGraph, WheelGraph,
    CompleteDiGraph, StarDiGraph, PathDiGraph, WheelDiGraph,
    DiamondGraph, BullGraph,
    ChvatalGraph, CubicalGraph, DesarguesGraph,
    DodecahedralGraph, FruchtGraph, HeawoodGraph,
    HouseGraph, HouseXGraph, IcosahedralGraph,
    KrackhardtKiteGraph, MoebiusKantorGraph, OctahedralGraph,
    PappusGraph, PetersenGraph, SedgewickMazeGraph,
    TetrahedralGraph, TruncatedCubeGraph,
    TruncatedTetrahedronGraph, TutteGraph,

    # Paths
    a_star_sp
    include("core.jl")
    include("graph.jl")
    include("digraph.jl")
    include("astar.jl")
    include("dijkstra.jl")
    include("persistence.jl")
    include("randgraphs.jl")
    include("smallgraphs.jl")
end # module
