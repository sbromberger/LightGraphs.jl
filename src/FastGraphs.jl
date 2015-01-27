module FastGraphs

    using GZip
    using DataStructures
    using StatsBase
    using Compat

    import Base:write, ==, issubset, show, print, complement, union, intersect, reverse, reverse!

    # core
    export AbstractFastGraph, Edge, FastGraph, FastDiGraph, vertices, edges, src, dst,
    in_edges, out_edges, has_vertex, has_edge, is_directed, rev,
    nv, ne, add_edge!, add_vertex!, add_vertices!,
    indegree, outdegree, degree, degree_histogram, density, Δ, δ,
    neighbors, all_neighbors, common_neighbors,

    # distance
    eccentricity, diameter, periphery, radius, center,

    # operators
    complement, reverse, reverse!, union, intersect,
    difference, symmetric_difference, compose,

    # dijkstra
    dijkstra_shortest_paths, dijkstra_predecessor_and_distance,

    # bellman-ford
    bellman_ford_shortest_paths, has_negative_edge_cycle, enumerate_paths,

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
    indegree_centrality, outdegree_centrality,

    # linalg
    adjacency_matrix, laplacian_matrix, adjacency_spectrum, laplacian_spectrum,
    # astar
    a_star,

    # persistence
    readfastgraph

    include("core.jl")
        include("digraph.jl")
        include("graph.jl")
            include("astar.jl")
            include("distance.jl")
            include("bellman-ford.jl")
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
