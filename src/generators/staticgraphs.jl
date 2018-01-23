# Parts of this code were taken / derived from NetworkX. See LICENSE for
# licensing details.

"""
    CompleteGraph(n)

Create an undirected [complete graph](https://en.wikipedia.org/wiki/Complete_graph)
with `n` vertices.
"""
function CompleteGraph(n::Integer)
    g = SimpleGraph(n)
    for i = 1:n, j = 1:n
        if i < j
            add_edge!(g, Edge(i, j))
        end
    end
    return g
end


@doc_str """
    CompleteBipartiteGraph(n1, n2)

Create an undirected [complete bipartite graph](https://en.wikipedia.org/wiki/Complete_bipartite_graph)
with `n1 + n2` vertices.
"""
function CompleteBipartiteGraph(n1::Integer, n2::Integer)
    g = SimpleGraph(n1 + n2)
    for i = 1:n1, j = (n1 + 1):(n1 + n2)
        add_edge!(g, Edge(i, j))
    end
    return g
end

"""
    CompleteDiGraph(n)

Create a directed [complete graph](https://en.wikipedia.org/wiki/Complete_graph)
with `n` vertices.
"""
function CompleteDiGraph(n::Integer)
    g = SimpleDiGraph(n)
    for i = 1:n, j = 1:n
        if i != j
            add_edge!(g, Edge(i, j))
        end
    end
    return g
end

"""
    StarGraph(n)

Create an undirected [star graph](https://en.wikipedia.org/wiki/Star_(graph_theory))
with `n` vertices.
"""
function StarGraph(n::Integer)
    g = SimpleGraph(n)
    for i = 2:n
        add_edge!(g, Edge(1, i))
    end
    return g
end

"""
    StarDiGraph(n)

Create a directed [star graph](https://en.wikipedia.org/wiki/Star_(graph_theory))
with `n` vertices.
"""
function StarDiGraph(n::Integer)
    g = SimpleDiGraph(n)
    for i = 2:n
        add_edge!(g, Edge(1, i))
    end
    return g
end

"""
    PathGraph(n)

Create an undirected [path graph](https://en.wikipedia.org/wiki/Path_graph)
with `n` vertices.
"""
function PathGraph(n::Integer)
    g = SimpleGraph(n)
    for i = 2:n
        add_edge!(g, Edge(i - 1, i))
    end
    return g
end

"""
    PathDiGraph(n)

Creates a directed [path graph](https://en.wikipedia.org/wiki/Path_graph)
with `n` vertices.
"""
function PathDiGraph(n::Integer)
    g = SimpleDiGraph(n)
    for i = 2:n
        add_edge!(g, Edge(i - 1, i))
    end
    return g
end

"""
    CycleGraph(n)

Create an undirected [cycle graph](https://en.wikipedia.org/wiki/Cycle_graph)
with `n` vertices.
"""
function CycleGraph(n::Integer)
    g = SimpleGraph(n)
    for i = 1:(n - 1)
        add_edge!(g, Edge(i, i + 1))
    end
    add_edge!(g, Edge(n, 1))
    return g
end

"""
    CycleDiGraph(n)

Create a directed [cycle graph](https://en.wikipedia.org/wiki/Cycle_graph)
with `n` vertices.
"""
function CycleDiGraph(n::Integer)
    g = SimpleDiGraph(n)
    for i = 1:(n - 1)
        add_edge!(g, Edge(i, i + 1))
    end
    add_edge!(g, Edge(n, 1))
    return g
end


"""
    WheelGraph(n)

Create an undirected [wheel graph](https://en.wikipedia.org/wiki/Wheel_graph)
with `n` vertices.
"""
function WheelGraph(n::Integer)
    g = StarGraph(n)
    for i = 3:n
        add_edge!(g, Edge(i - 1, i))
    end
    if n != 2
        add_edge!(g, Edge(n, 2))
    end
    return g
end

"""
    WheelDiGraph(n)

Create a directed [wheel graph](https://en.wikipedia.org/wiki/Wheel_graph)
with `n` vertices.
"""
function WheelDiGraph(n::Integer)
    g = StarDiGraph(n)
    for i = 3:n
        add_edge!(g, Edge(i - 1, i))
    end
    if n != 2
        add_edge!(g, Edge(n, 2))
    end
    return g
end

@doc_str """
    Grid(dims; periodic=false)

Create a ``|dims|``-dimensional cubic lattice, with length `dims[i]`
in dimension `i`.

### Optional Arguments
- `periodic=false`: If true, the resulting lattice will have periodic boundary
condition in each dimension.
"""
function Grid(dims::AbstractVector; periodic=false)
    if periodic
        g = CycleGraph(dims[1])
        for d in dims[2:end]
            g = cartesian_product(CycleGraph(d), g)
        end
    else
        g = PathGraph(dims[1])
        for d in dims[2:end]
            g = cartesian_product(PathGraph(d), g)
        end
    end
    return g
end

"""
    BinaryTree(k::Integer)

Create a [binary tree](https://en.wikipedia.org/wiki/Binary_tree)
of depth `k`.
"""

function BinaryTree(k::Integer)
    g = SimpleGraph(Int(2^k - 1))
    for i in 0:(k - 2)
        for j in (2^i):(2^(i + 1) - 1)
            add_edge!(g, j, 2j)
            add_edge!(g, j, 2j + 1)
        end
    end
    return g
end

"""
    BinaryTree(k::Integer)

Create a double complete binary tree with `k` levels.

### References
- Used as an example for spectral clustering by Guattery and Miller 1998.
"""
function DoubleBinaryTree(k::Integer)
    gl = BinaryTree(k)
    gr = BinaryTree(k)
    g = blkdiag(gl, gr)
    add_edge!(g, 1, nv(gl) + 1)
    return g
end


"""
    RoachGraph(k)

Create a Roach Graph of size `k`.

### References
- Guattery and Miller 1998
"""
function RoachGraph(k::Integer)
    dipole = CompleteGraph(2)
    nopole = SimpleGraph(2)
    antannae = crosspath(k, nopole)
    body = crosspath(k, dipole)
    roach = blkdiag(antannae, body)
    add_edge!(roach, nv(antannae) - 1, nv(antannae) + 1)
    add_edge!(roach, nv(antannae), nv(antannae) + 2)
    return roach
end


"""
    CliqueGraph(k, n)

Create a graph consisting of `n` connected `k`-cliques.
"""
function CliqueGraph(k::Integer, n::Integer)
    g = SimpleGraph(k * n)
    for c = 1:n
        for i = ((c - 1) * k + 1):(c * k - 1), j = (i + 1):(c * k)
            add_edge!(g, i, j)
        end
    end
    for i = 1:(n - 1)
        add_edge!(g, (i - 1) * k + 1, i * k + 1)
    end
    add_edge!(g, 1, (n - 1) * k + 1)
    return g
end
