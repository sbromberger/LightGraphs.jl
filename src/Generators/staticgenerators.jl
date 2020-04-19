abstract type StaticGenerator <: GraphGenerator end

"""
    struct Complete <: StaticGenerator

A struct representing a generator for a [complete graph](https://en.wikipedia.org/wiki/Complete_graph)
with `n` vertices.

### Required Fields
- `n::Integer`: the number of vertices in the graph.
"""
struct Complete{T<:Integer} <: StaticGenerator
    n::T
end

"""
    struct CompleteBipartite <: StaticGenerator

A struct representing a generator for a complete bipartite graph with
`n1` + `n2` vertices.

### Required Fields
- `n1::Integer`: the number of vertices in partition 1.
- `n2::Integer`: the number of vertices in partition 2.
"""
struct CompleteBipartite{T<:Integer} <: StaticGenerator
    n1::T
    n2::T
end

"""
    struct CompleteMultipartite <: StaticGenerator

A struct representing a generator for a complete bipartite graph with
`sum(pvec)` vertices.

### Required Fields
- `pvec::AbstractVector{<:Integer}`: a vector with values representing the numbers of vertices in each partition represented by index.
"""
struct CompleteMultipartite{T<:Integer, U<:AbstractVector{T}} <: StaticGenerator
    pvec::U
    function CompleteMultipartite(pvec::U) where {T<:Integer, U<:AbstractVector{T}}
        sum(pvec) > typemax(T) && throw(OverflowError("The number of vertices in this graph will overflow its type."))
        new{T, U}(pvec)
    end
end

"""
    struct Turan <: StaticGenerator

A struct representing a generator for a [Turán Graph](https://en.wikipedia.org/wiki/Tur%C3%A1n_graph), a complete
multipartite graph with `n` vertices and `r` partitions.

### Required Fields
- `n::Integer`: The number of vertices in the graph
- `r::Integer`: The number of partitions in the graph
"""
struct Turan{T<:Integer, U<:Integer} <: StaticGenerator
    n::T
    r::U
    function Turan(n::T, r::U) where {T<:Integer, U<:Integer}
        (1 <= r <= n) || throw(DomainError((n, r), "n=$n and r=$r are invalid, must satisfy 1 <= r <= n"))
        new{T, U}(n, r)
    end
end

"""
    struct Star <: StaticGenerator

A struct representing a generator for a [star graph](https://en.wikipedia.org/wiki/Star_(graph_theory))
with `n` vertices.

### Required Fields
- `n::Integer`: The number of vertices in the graph
"""
struct Star{T<:Integer} <: StaticGenerator
    n::T
end

"""
    struct Path <: StaticGenerator

A struct representing a generator for a [path graph](https://en.wikipedia.org/wiki/Path_graph)
with `n` vertices.

### Required Fields
- `n::Integer`: The number of vertices in the graph
"""
struct Path{T<:Integer} <: StaticGenerator
    n::T
end

"""
    struct Cycle <: StaticGenerator

A struct representing a generator for a [cycle graph](https://en.wikipedia.org/wiki/Cycle_graph)
with `n` vertices.

### Required Fields
- `n::Integer`: The number of vertices in the graph
"""
struct Cycle{T<:Integer} <: StaticGenerator
    n::T
end

"""
    struct Wheel <: StaticGenerator

A struct representing a generator for a [wheel graph](https://en.wikipedia.org/wiki/Wheel_graph)
with `n` vertices.

### Required Fields
- `n::Integer`: The number of vertices in the graph
"""
struct Wheel{T<:Integer} <: StaticGenerator
    n::T
end

"""
    struct Grid <: StaticGenerator 

A struct representing a generator for a ``|dims|``-dimensional cubic lattice,
with length `dims[i]` in dimension `i`.

### Required Fields
- `dims::AbstractVector{<:Integer}`: The lengths of the dimensions in the lattice. Note: this can also be a `Tuple`.

### Optional Arguments
- `periodic=false`: If true, the resulting lattice will have periodic boundary
condition in each dimension.
"""
struct Grid{T<:Integer, U<:AbstractVector{T}} <: StaticGenerator
    dims::U
    periodic::Bool
end
Grid(dims; periodic=false) = Grid(dims, periodic)
Grid(dims::Tuple; periodic=false) = Grid(collect(dims), periodic)

"""
    struct BinaryTree <: StaticGenerator

A struct representing a generator for a complete [binary tree](https://en.wikipedia.org/wiki/Binary_tree)
of depth `k`.

### Required Fields
- `k::Integer`: The depth of the binary tree
"""
struct BinaryTree{T<:Integer} <: StaticGenerator
    k::T
    function BinaryTree(k::T) where {T<:Integer}
        if LightGraphs.isbounded(k) && BigInt(2) ^ k > typemax(k)
            throw(OverflowError("k=$k will result in a graph too big for graph type $T"))
        end
        new{T}(k)
    end
end

"""
    struct DoubleBinaryTree <: StaticGenerator

A struct representing a generator for a complete double binary tree of depth `k`.

### Required Fields
- `k::Integer`: The depth of the double binary tree
"""
struct DoubleBinaryTree{T<:Integer} <: StaticGenerator
    k::T
    function DoubleBinaryTree(k::T) where {T<:Integer}
        if LightGraphs.isbounded(k) && (BigInt(2) ^ k) * 2 - 1 > typemax(k)
            throw(OverflowError("k=$k will result in a graph too big for graph type $T"))
        end
        new{T}(k)
    end
end

"""
    struct Roach <: StaticGenerator

A struct representing a roach graph of size `k`.

### Required Fields
- `k::Integer`: The size of the roach graph
#
### References
- Guattery and Miller 1998
"""
struct Roach{T<:Integer} <: StaticGenerator
    k::T
    function Roach(k::T) where {T<:Integer}
        k > typemax(T) ÷ 4 && throw(OverflowError("k=$k will result in a graph too big for graph type $T"))
        new{T}(k)
    end

end

"""
    struct Clique <: StaticGenerator

A struct representing a generator for a graph consisting of `n` connected `k`-cliques.


### Required Fields
- `k::Integer`: The size of each clique
- `n::Integer`: The number of cliques
"""
struct Clique{T<:Integer} <: StaticGenerator
    k::T
    n::Integer
end

"""
    struct Ladder <: StaticGenerator

A struct representing a generator for a [ladder graph](https://en.wikipedia.org/wiki/Ladder_graph) consisting of
`2n` nodes and `3n-2` edges.

### Required Fields
- `n::Integer`: The number of rungs on the ladder

### Implementation Notes
Preserves the eltype of `n`. Will error if the required number of vertices
exceeds the eltype.
"""
struct Ladder{T<:Integer} <: StaticGenerator
    n::T
    function Ladder(n::T) where {T<:Integer}
        n <= typemax(T) ÷ 2 || throw(OverflowError("n=$n will result in a graph too big for graph type $T"))
        new{T}(n)
    end
end

"""
    struct CircularLadder <: StaticGenerator

A struct representing a generator for a [circular ladder graph](https://en.wikipedia.org/wiki/Ladder_graph#Circular_ladder_graph) consisting
of `2n` nodes and `3n` edges. This is also known as the [prism graph](https://en.wikipedia.org/wiki/Prism_graph).

### Required Fields
- `n::Integer`: The number of rungs on the ladder

### Implementation Notes
- Preserves the eltype of the partitions vector. Will error if the required number of vertices
exceeds the eltype.
- `n` must be at least 3 to avoid self-loops and multi-edges.
"""
struct CircularLadder{T<:Integer} <: StaticGenerator
    n::T
    function CircularLadder(n::T) where {T<:Integer}
        n < 3 && throw(DomainError(n, "n=$n must be at least 3"))
        n <= typemax(T) ÷ 2 || throw(OverflowError("n=$n will result in a graph too big for graph type $T"))
        new{T}(n)
    end
end

"""
    struct Barbell <: StaticGenerator

A struct representing a generator for a [barbell graph](https://en.wikipedia.org/wiki/Barbell_graph) consisting of
a clique of size `n1` connected by an edge to a clique of size `n2`.

### Required Fields
- `n1::Integer`: The number of vertices in the first clique
- `n2::Integer`: The number of vertices in the second clique

### Implementation Notes
- Preserves the eltype of `n1` and `n2`. Will error if the required number of vertices
exceeds the eltype.
- `n1` and `n2` must be at least 1 so that both cliques are non-empty.
- The cliques are organized with nodes `1:n1` being the left clique and `n1+1:n1+n2` being the right clique. The cliques are connected by and edge `(n1, n1+1)`.
"""
struct Barbell{T<:Integer} <: StaticGenerator
    n1::T
    n2::T
    function Barbell(n1::T, n2::T) where {T<:Integer}
        (n1 < 1 || n2 < 1) && throw(DomainError((n1, n2), "Borh n1=$n1 and n2=$n2 must be at least 1"))
        n1 >= typemax(T) - n2 && throw(OverflowError("n1=$n1 and n2=$n2 will result in a graph too big for graph type $T"))
        new{T}(n1, n2)
    end
end

"""
    struct Lollipop <: StaticGenerator

A struct representing a generator for a [lollipop graph](https://en.wikipedia.org/wiki/Lollipop_graph) consisting of
a clique of size `n1` connected by an edge to a path of size `n2`.

### Required Fields
- `n1::Integer`: The number of vertices in the clique
- `n2::Integer`: The number of vertices in the path (stem)

### Implementation Notes
- Preserves the eltype of `n1` and `n2`. Will error if the required number of vertices
exceeds the eltype.
- `n1` and `n2` must be at least 1 so that both the clique and the path have at least one vertex.
- The graph is organized with nodes `1:n1` being the clique and `n1+1:n1+n2` being the path. The clique is connected to the path by an edge `(n1, n1+1)`.
"""
struct Lollipop{T<:Integer} <: StaticGenerator
    n1::T
    n2::T
    function Lollipop(n1::T, n2::T) where {T<:Integer}
        (n1 < 1 || n2 < 1) && throw(DomainError((n1, n2), "Both n1=$n1 and n2=$n2 must be at least 1"))
        n1 >= typemax(T) - n2 && throw(OverflowError("n1=$n1 and n2=$n2 will result in a graph too big for graph type $T"))
        new{T}(n1, n2)
    end
end

"""
    struct Circulant <: StaticGenerator

A generator for a [circulant graph](https://en.wikipedia.org/wiki/Circulant_graph) with `n` vertices with connection
set represented by `cset`.

### Required Fields
- `n::Integer`: The number of vertices in the clique
- `cset::AbstractVector{<:Integer}`: The connection set for the graph

### Implementation Notes
- `n` must be at least 1 so that the graph has at least one vertex.
- The modulo and addition operations are carried assuming vertex lables from 0:n-1 and 1 is added to them.
"""
struct Circulant{T<:Integer, U<:AbstractVector{T}} <: StaticGenerator
    n::T
    cset::U
    function Circulant(n::T, cset::U) where {T<:Integer, U<:AbstractVector{T}}
        (n < 1) && throw(DomainError(n, "n must be at least 1"))
        new{T,U}(n, cset)
    end
end

"""
    struct Friendship <: StaticGenerator

A struct representing a generator for a [friendship graph](https://en.wikipedia.org/wiki/Friendship_graph) consisting
of `n` copies of the cycle graph `C3` with a common vertex. If `n ≤ 0`, return a single node.

### Required Fields
- `n::Integer`: The number of copies of the cycle graph `C3`

### Implementation Notes
In this implementation, the common vertex is index 1.
"""
struct Friendship{T<:Integer} <: StaticGenerator
    n::T
end

