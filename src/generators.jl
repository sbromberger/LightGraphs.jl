# Parts of this code were taken / derived from NetworkX. See LICENSE for
# licensing details.

"""Creates a complete graph with `n` vertices. A complete graph has edges
connecting each pair of vertices.
"""
function CompleteGraph(n::Integer)
    g = Graph(n)
    for i = 1:n, j=1:n
        if i < j
            add_edge!(g, Edge(i,j))
        end
    end
    return g
end


"""Creates a complete bipartite graph with `n1+n2` vertices. It has edges
connecting each pair of vertices in the two sets.
"""
function CompleteBipartiteGraph(n1::Integer, n2::Integer)
    g = Graph(n1+n2)
    for i = 1:n1, j=n1+1:n1+n2
        add_edge!(g, Edge(i,j))
    end
    return g
end

"""Creates a complete digraph with `n` vertices. A complete digraph has edges
connecting each pair of vertices (both an ingoing and outgoing edge).
"""
function CompleteDiGraph(n::Integer)
    g = DiGraph(n)
    for i = 1:n, j=1:n
        if i != j
            add_edge!(g, Edge(i,j))
        end
    end
    return g
end

"""Creates a star graph with `n` vertices. A star graph has a central vertex
with edges to each other vertex.
"""
function StarGraph(n::Integer)
    g = Graph(n)
    for i = 2:n
        add_edge!(g, Edge(1,i))
    end
    return g
end

"""Creates a star digraph with `n` vertices. A star digraph has a central
vertex with directed edges to every other vertex.
"""
function StarDiGraph(n::Integer)
    g = DiGraph(n)
    for i = 2:n
        add_edge!(g, Edge(1,i))
    end
    return g
end

"""Creates a path graph with `n` vertices. A path graph connects each
successive vertex by a single edge."""
function PathGraph(n::Integer)
    g = Graph(n)
    for i = 2:n
        add_edge!(g, Edge(i-1, i))
    end
    return g
end

"""Creates a path digraph with `n` vertices. A path graph connects each
successive vertex by a single directed edge."""
function PathDiGraph(n::Integer)
    g = DiGraph(n)
    for i = 2:n
        add_edge!(g, Edge(i-1, i))
    end
    return g
end

"""Creates a cycle graph with `n` vertices. A cycle graph is a closed path graph.
"""
function CycleGraph(n::Integer)
    g = Graph(n)
    for i = 1:n-1
        add_edge!(g, Edge(i, i+1))
    end
    add_edge!(g, Edge(n, 1))
    return g
end

"""Creates a cycle digraph with `n` vertices. A cycle digraph is a closed path digraph.
"""
function CycleDiGraph(n::Integer)
    g = DiGraph(n)
    for i = 1:n-1
        add_edge!(g, Edge(i, i+1))
    end
    add_edge!(g, Edge(n, 1))
    return g
end


"""Creates a wheel graph with `n` vertices. A wheel graph is a star graph with
the outer vertices connected via a closed path graph.
"""
function WheelGraph(n::Integer)
    g = StarGraph(n)
    for i = 3:n
        add_edge!(g, Edge(i-1, i))
    end
    if n != 2
        add_edge!(g, Edge(n, 2))
    end
    return g
end

"""Creates a wheel digraph with `n` vertices. A wheel graph is a star digraph
with the outer vertices connected via a closed path graph.
"""
function WheelDiGraph(n::Integer)
    g = StarDiGraph(n)
    for i = 3:n
        add_edge!(g, Edge(i-1, i))
    end
    if n != 2
        add_edge!(g, Edge(n, 2))
    end
    return g
end

"""create a binary tree with k-levels vertices are numbered 1:2^levels-1"""
function BinaryTree(levels::Int)
    g = Graph(2^levels-1)
    for i in 0:levels-2
        for j in 2^i:2^(i+1)-1
            add_edge!(g, j, 2j)
            add_edge!(g, j, 2j+1)
        end
    end
    return g
end

"""create a double complete binary tree with k-levels
used as an example for spectral clustering by Guattery and Miller 1998."""
function DoubleBinaryTree(levels::Int)
    gl = BinaryTree(levels)
    gr = BinaryTree(levels)
    g = blkdiag(gl, gr)
    add_edge!(g,1, nv(gl)+1)
    return g
end


"""The Roach Graph from Guattery and Miller 1998"""
function RoachGraph(k::Int)
    dipole = CompleteGraph(2)
    nopole = Graph(2)
    antannae = crosspath(k, nopole)
    body = crosspath(k,dipole)
    roach = blkdiag(antannae, body)
    add_edge!(roach, nv(antannae)-1, nv(antannae)+1)
    add_edge!(roach, nv(antannae), nv(antannae)+2)
    return roach
end
