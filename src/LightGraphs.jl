module LightGraphs
    using Compat
    using GZip
    using DataStructures
    using Distributions
    using Base.Collections
    if VERSION < v"0.4.0-dev" # until < 0.4 deprecated
        using Docile
    end

    import Base:write, ==, isless, issubset, show, print, complement, union, intersect, reverse, reverse!, blkdiag

    # core
    export AbstractGeneralGraph, AbstractGraph, AbstractDiGraph,
    Edge, Graph, DiGraph, vertices, edges, src, dst,
    in_edges, out_edges, has_vertex, has_edge, is_directed,
    nv, ne, add_edge!, rem_edge!, add_vertex!, add_vertices!,
    indegree, outdegree, degree, degree_histogram, density, Δ, δ,
    Δout, Δin, δout, δin, neighbors, in_neighbors, out_neighbors,
    common_neighbors,

    # distance
    eccentricity, diameter, periphery, radius, center,

    # operators
    complement, reverse, reverse!, union, intersect,
    difference, symmetric_difference,
    inducedsubgraph,

    # graph visit
    AbstractGraphVisitor, TrivialGraphVisitor, LogGraphVisitor,
    discover_vertex!, open_vertex!, close_vertex!,
    examine_neighbor!, examine_edge!, visited_vertices,
    traverse_graph, traverse_graph_withlog,

    # bfs
    BreadthFirst, gdistances, gdistances!,

    # dfs
    DepthFirst, test_cyclic_by_dfs, topological_sort_by_dfs,

    # maximum_adjacency_visit
    MaximumAdjacency, AbstractMASVisitor, mincut, maximum_adjacency_visit,

    # dijkstra
    dijkstra_shortest_paths,

    # bellman-ford
    bellman_ford_shortest_paths, has_negative_edge_cycle, enumerate_paths,

    # floyd-warshall
    floyd_warshall_shortest_paths,

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
    TruncatedTetrahedronGraph, TruncatedTetrahedronDiGraph, TutteGraph,

    # centrality
    betweenness_centrality, closeness_centrality, degree_centrality,
    indegree_centrality, outdegree_centrality, katz_centrality, pagerank,

    # linalg
    adjacency_matrix, laplacian_matrix, adjacency_spectrum, laplacian_spectrum,

    # astar
    a_star,

    # persistence
    readgraph, read_graphml,

    # randgraphs
    erdos_renyi, watts_strogatz

    include("core.jl")
        include("digraph.jl")
        include("graph.jl")
            include("astar.jl")
            include("graphvisit.jl")
                include("bfs.jl")
                include("dfs.jl")
                include("maxadjvisit.jl")
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
            include("centrality/katz.jl")
            include("centrality/pagerank.jl")
end # module
