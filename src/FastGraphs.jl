module FastGraphs

    using GZip
    using DataStructures
    using Compat

    import Base:write, ==, issubset, show, print, complement, union, intersect

    # core
    export AbstractFastGraph, Edge, FastGraph, FastDiGraph, vertices, edges, in_edges, out_edges,
    has_vertex, has_edge,
    nv, ne, add_edge!, add_vertex!,
    indegree, outdegree, degree, degree_histogram, density, Δ, δ,
    neighbors, all_neighbors, common_neighbors,

    # distance
    eccentricity, diameter, periphery, radius, center,

    # operators
    complement, reverse, reverse!, union, intersect,
    difference, symmetric_difference, compose,

    # dijkstra
    dijkstra_shortest_paths, dijkstra_predecessor_and_distance,

    # floyd-warshall
    floyd_warshall,

    # smallgraphs
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

    # centrality
    betweenness_centrality, closeness_centrality, degree_centrality,

    # linalg
    adjacency_matrix, laplacian_matrix,
    # astar
    a_star_sp

    include("core.jl")
        include("digraph.jl")
        include("graph.jl")
            include("astar.jl")
            include("distance.jl")
            include("dijkstra.jl")
            include("floyd-warshall.jl")
            include("linalg.jl")
            include("operators.jl")
            include("persistence.jl")
            include("randgraphs.jl")
            include("smallgraphs.jl")
            include("centrality/betweenness.jl")
            include("centrality/closeness.jl")
            include("centrality/degree.jl")
end # module
