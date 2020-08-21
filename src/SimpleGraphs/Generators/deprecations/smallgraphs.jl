#####################
# STATIC SMALL GRAPHS
#####################

deprecation_list = Dict(
    :bull            => Bull,
    :chvatal         => Chvatal,
    :cubical         => Cubical,
    :desargues       => Desargues,
    :diamond         => Diamond,
    :dodecahedral    => Dodecahedral,
    :frucht          => Frucht,
    :heawood         => Heawood,
    :house           => House,
    :housex          => HouseX,
    :icosahedral     => Icosahedral,
    :karate          => Karate,
    :krackhardtkite  => KrackhardtKite,
    :moebiuskantor   => MoebiusKantor,
    :octahedral      => Octahedral,
    :pappus          => Pappus,
    :petersen        => Petersen,
    :sedgewickmaze   => SedgewickMaze,
    :tetrahedral     => Tetrahedral,
    :truncatedcube   => TruncatedCube,
    :truncatedtetrahedron        => TruncatedTetrahedron,
    :truncatedtetrahedron_dir     => TruncatedTetrahedron,
    :tutte           => Tutte
    )

function smallgraph(s::Symbol)
    graphmap = Dict(
    :bull            => bull_graph,
    :chvatal         => chvatal_graph,
    :cubical         => cubical_graph,
    :desargues       => desargues_graph,
    :diamond         => diamond_graph,
    :dodecahedral    => dodecahedral_graph,
    :frucht          => frucht_graph,
    :heawood         => heawood_graph,
    :house           => house_graph,
    :housex          => house_x_graph,
    :icosahedral     => icosahedral_graph,
    :karate          => karate_graph,
    :krackhardtkite  => krackhardt_kite_graph,
    :moebiuskantor   => moebius_kantor_graph,
    :octahedral      => octahedral_graph,
    :pappus          => pappus_graph,
    :petersen        => petersen_graph,
    :sedgewickmaze   => sedgewick_maze_graph,
    :tetrahedral     => tetrahedral_graph,
    :truncatedcube   => truncated_cube_graph,
    :truncatedtetrahedron        => truncated_tetrahedron_graph,
    :truncatedtetrahedron_dir    => truncated_tetrahedron_digraph,
    :tutte           => tutte_graph
    )

    s in keys(graphmap) || throw(ArgumentError("$s is not a valid graph"))
    gentype = deprecation_list[s]
    
    Base.depwarn("`smallgraph($s)` is deprecated. Equivalent functionality has been moved to `$gentype`.", :smallgraph)

    gtype = s == :truncatedtetrahedron_dir ? SimpleDiGraph : SimpleGraph

    gen = gentype()
    return gtype(gen)
end

function smallgraph(s::AbstractString)
    ls = lowercase(s)
    if endswith(ls, "graph")
        ls = replace(ls, "graph" => "")
    end

    return smallgraph(Symbol(ls))
end
