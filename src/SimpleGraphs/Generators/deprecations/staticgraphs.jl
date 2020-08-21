function complete_graph(n::T) where {T <: Integer}
    Base.depwarn("`complete_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Complete`.", :complete_graph)
    gen = Complete(n)
    return SimpleGraph(gen)
end

function complete_bipartite_graph(n1::T, n2::T) where {T <: Integer}
    Base.depwarn("`complete_bipartite_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.CompleteBipartite`.", :complete_bipartite_graph)
    gen = CompleteBipartite(n1, n2)
    return SimpleGraph(gen)
end

function complete_multipartite_graph(partitions::AbstractVector{T}) where {T <: Integer}
    Base.depwarn("`complete_multipartite_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.CompleteMultipartite`.", :complete_multipartite_graph)
    gen = CompleteMultipartite(partitions)
    return SimpleGraph(gen)
end
function turan_graph(n::Integer, r::Integer)
    Base.depwarn("`turan_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Turan`.", :turan_graph)
    gen = Turan(n)
    return SimpleGraph(gen)
end

function complete_digraph(n::T) where {T <: Integer}
    Base.depwarn("`complete_digraph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Complete`.", :complete_digraph)
    gen = Complete(n)
    return SimpleDiGraph(gen)
end

function star_graph(n::T) where {T <: Integer}
    Base.depwarn("`star_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Star`.", :star_graph)
    gen = Star(n)
    return SimpleGraph(gen)
end

function star_digraph(n::T) where {T <: Integer}
    Base.depwarn("`star_digraph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Star`.", :star_digraph)
    gen = Star(n)
    return SimpleDiGraph(gen)
end

function path_graph(n::T) where {T <: Integer}
    Base.depwarn("`path_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Path`.", :path_graph)
    gen = Path(n)
    return SimpleGraph(gen)
end

function path_digraph(n::T) where {T <: Integer}
    Base.depwarn("`path_digraph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Path`.", :path_digraph)
    gen = Path(n)
    return SimpleDiGraph(gen)
end

function cycle_graph(n::T) where {T <: Integer}
    Base.depwarn("`cycle_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Cycle`.", :cycle_graph)
    gen = Cycle(n)
    return SimpleGraph(gen)
end

function cycle_digraph(n::T) where {T <: Integer}
    Base.depwarn("`cycle_digraph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Cycle`.", :cycle_digraph)
    gen = Cycle(n)
    return SimpleDiGraph(gen)
end

function wheel_graph(n::T) where {T <: Integer}
    Base.depwarn("`wheel_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Wheel`.", :wheel_graph)
    gen = Wheel(n)
    return SimpleGraph(gen)
end

function wheel_digraph(n::T) where {T <: Integer}
    Base.depwarn("`wheel_digraph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Wheel`.", :wheel_digraph)
    gen = Wheel(n)
    return SimpleDiGraph(gen)
end

function grid(dims::AbstractVector{T}; periodic=false) where {T <: Integer}
    Base.depwarn("`grid` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Grid`.", :grid)
    gen = Grid(dims, periodic)
    return SimpleGraph(gen)
end
grid(dims::Tuple; periodic=false) = grid(collect(dims); periodic=periodic)

function binary_tree(k::T) where {T <: Integer}
    Base.depwarn("`binary_tree` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.BinaryTree`.", :binary_tree)
    gen = BinaryTree(k)
    return SimpleGraph(gen)
end

function double_binary_tree(k::Integer)
    Base.depwarn("`double_binary_tree` is deprecated. Equivalent functionality has double_been moved to `LightGraphs.Generators.DoubleBinaryTree`.", :double_binary_tree)
    gen = DoubleBinaryTree(k)
    return SimpleGraph(gen)
end

function roach_graph(k::Integer)
    Base.depwarn("`roach_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Roach`.", :roach_graph)
    gen = Roach(k)
    return SimpleGraph(gen)
end

function clique_graph(k::T, n::T) where {T <: Integer}
    Base.depwarn("`clique_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Clique`.", :clique_graph)
    gen = Clique(k, n)
    return SimpleGraph(gen)
end

function ladder_graph(n::T) where {T <: Integer}
    Base.depwarn("`ladder_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Ladder`.", :ladder_graph)
    gen = Ladder(n)
    return SimpleGraph(gen)
end

function circular_ladder_graph(n::Integer)
    Base.depwarn("`circular_ladder_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.CircularLadder`.", :circular_ladder_graph)
    gen = CircularLadder(n)
    return SimpleGraph(gen)
end

function barbell_graph(n1::T, n2::T) where {T <: Integer}
    Base.depwarn("`barbell_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Barbell`.", :barbell_graph)
    gen = Barbell(n1, n2)
    return SimpleGraph(gen)
end

function lollipop_graph(n1::T, n2::T) where {T <: Integer}
    Base.depwarn("`lollipop_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Lollipop`.", :lollipop_graph)
    gen = Lollipop(n1, n2)
    return SimpleGraph(gen)
end

function circulant_graph(n::T, connection_set::Vector{T}) where {T <: Integer}
    Base.depwarn("`circulant_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Circulant`.", :circulant_graph)
    gen = Circulant(n, connection_set)
    return SimpleGraph(gen)
end

function circulant_digraph(n::T, connection_set::Vector{T}) where {T <: Integer}
    Base.depwarn("`circulant_digraph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Circulant`.", :circulant_digraph)
    gen = Circulant(n, connection_set)
    return SimpleDiGraph(gen)
end

function friendship_graph(n::T) where {T <: Integer}
    Base.depwarn("`friendship_graph` is deprecated. Equivalent functionality has been moved to `LightGraphs.Generators.Friendship`.", :friendship_graph)
    gen = Friendship(n)
    return SimpleGraph(gen)
end
