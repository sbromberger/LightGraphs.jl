# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.
"""
    connected_components!(label, g)

Fill `label` with the `id` of the connected component in the undirected graph
`g` to which it belongs. Return a vector representing the component assigned
to each vertex. The component value is the smallest vertex ID in the component.

### Performance
This algorithm is linear in the number of edges of the graph.
"""
function connected_components! end
@traitfn function connected_components!(label::AbstractVector, g::::(!IsDirected))
    T = eltype(g)
    nvg = nv(g)

    for u in vertices(g)
        label[u] != zero(T) && continue
        label[u] = u
        Q = Vector{T}()
        push!(Q, u)
        while !isempty(Q)
            src = shift!(Q)
            for vertex in out_neighbors(g, src)
                if label[vertex] == zero(T)
                    push!(Q, vertex)
                    label[vertex] = u
                end
            end
        end
    end
    return label
end


"""
    components_dict(labels)

Convert an array of labels to a map of component id to vertices, and return
a map with each key corresponding to a given component id
and each value containing the vertices associated with that component.
"""
function components_dict(labels::Vector{T}) where T<:Integer
    d = Dict{T,Vector{T}}()
    for (v, l) in enumerate(labels)
        vec = get(d, l, Vector{T}())
        push!(vec, v)
        d[l] = vec
    end
    return d
end

"""
    components(labels)

Given a vector of component labels, return a vector of vectors representing the vertices associated
with a given component id.
"""
function components(labels::Vector{T}) where T<:Integer
    d = Dict{T,T}()
    c = Vector{Vector{T}}()
    i = one(T)
    for (v, l) in enumerate(labels)
        index = get!(d, l, i)
        if length(c) >= index
            push!(c[index], v)
        else
            push!(c, [v])
            i += 1
        end
    end
    return c, d
end

"""
    connected_components(g)

Return the [connected components](https://en.wikipedia.org/wiki/Connectivity_(graph_theory))
of an undirected graph `g` as a vector of components, with each element a vector of vertices
belonging to the component.

For directed graphs, see [`strongly_connected_components`](@ref) and
[`weakly_connected_components`](@ref).
"""
function connected_components end
@traitfn function connected_components(g::::(!IsDirected))
    T = eltype(g)
    label = zeros(T, nv(g))
    connected_components!(label, g)
    c, d = components(label)
    return c
end

"""
    is_connected(g)

Return `true` if graph `g` is connected. For directed graphs, use
[`is_weakly_connected`](@ref) or [`is_strongly_connected`](@ref).
"""
function is_connected end
@traitfn is_connected(g::::(!IsDirected)) = ne(g) + 1 >= nv(g) && length(connected_components(g)) == 1

"""
    weakly_connected_components(g)

Return the weakly connected components of the directed graph `g`. This
is equivalent to the connected components of the undirected equivalent of `g`.
"""
function weakly_connected_components end
@traitfn weakly_connected_components(g::::IsDirected) = connected_components(Graph(g))

"""
    is_weakly_connected(g)

Return `true` if the directed graph `g` is connected.
"""
function is_weakly_connected end
@traitfn is_weakly_connected(g::::IsDirected) = length(weakly_connected_components(g)) == 1


mutable struct TarjanState{T<:Integer}
    stack::Vector{T}
    onstack::Vector{Bool}
    lowlink::Vector{T}
    index::Vector{T}
    parents::Vector{T}
    components::Vector{Vector{T}}
end

TarjanState(n::T) where T<:Integer = TarjanState(
    Vector{T}(),
    zeros(Bool, n),
    zeros(T, n),
    zeros(T, n),
    zeros(T, n),
    Vector{Vector{T}}()
)

"""
    strongly_connected_components(g)

Compute the strongly connected components of a directed graph `g`.
"""

function strongly_connected_components end
@traitfn function strongly_connected_components(g::::IsDirected)
    T = eltype(g)
    zero_t = zero(T)
    one_t = one(T)
    nvg = nv(g)
    count = one_t
    scc = TarjanState(nvg)
    sizehint!(scc.stack, nvg)
    sizehint!(scc.components, nvg)

    for s in vertices(g)
        if scc.index[s] == zero_t
            scc.index[s] = count
            scc.lowlink[s] = count
            scc.onstack[s] = true
            scc.parents[s] = s
            push!(scc.stack, s)
            count = count + one_t
            strongconnect!(g, s, count, scc)
        end
    end

    return scc.components
end


function strongconnect! end
@traitfn function strongconnect!{T<:Integer}(
    g::::IsDirected,
    s::T,
    count::T,
    scc::TarjanState{T}
    )

    zero_t = zero(T)
    one_t = one(T)
    Dfs_Stack = Vector{T}([s])

    while !isempty(Dfs_Stack)
        v = Dfs_Stack[end]
        u = zero_t
        for n in out_neighbors(g, v)
            if scc.index[n] == zero_t
                u = n
                break
            elseif scc.onstack[n]
                scc.lowlink[v] = min(scc.lowlink[v], scc.index[n])
            end
        end
        if u == zero_t
            popped = pop!(Dfs_Stack)
            scc.lowlink[scc.parents[popped]] = min(scc.lowlink[scc.parents[popped]], scc.lowlink[popped])
            if (scc.index[v] == scc.lowlink[v])
                component = Vector{T}()
                sizehint!(component, length(scc.stack))
                while (popped = pop!(scc.stack)) != v
                    push!(component, popped)
                    scc.onstack[popped] = false
                end
                push!(component, popped)
                scc.onstack[popped] = false
                push!(scc.components, reverse(component))
            end
        else
            scc.index[u] = count
            scc.lowlink[u] = count
            scc.onstack[u] = true
            scc.parents[u] = v
            count = count + one_t
            push!(scc.stack, u)
            push!(Dfs_Stack, u)
        end
    end
end

"""
    is_strongly_connected(g)

Return `true` if directed graph `g` is strongly connected.
"""
function is_strongly_connected end
@traitfn is_strongly_connected(g::::IsDirected) = length(strongly_connected_components(g)) == 1

"""
    period(g)

Return the (common) period for all vertices in a strongly connected directed graph.
Will throw an error if the graph is not strongly connected.
"""
function period end
@traitfn function period(g::::IsDirected)
    T = eltype(g)
    !is_strongly_connected(g) && error("Graph must be strongly connected")

    # First check if there's a self loop
    has_self_loops(g) && return 1

    g_bfs_tree  = bfs_tree(g, 1)
    levels      = gdistances(g_bfs_tree, 1)
    tree_diff   = difference(g, g_bfs_tree)
    edge_values = Vector{T}()

    divisor = 0
    for e in edges(tree_diff)
        @inbounds value = levels[src(e)] - levels[dst(e)] + 1
        divisor = gcd(divisor, value)
        isequal(divisor, 1) && return 1
    end

    return divisor
end

"""
    condensation(g[, scc])

Return the condensation graph of the strongly connected components `scc`
in the directed graph `g`. If `scc` is missing, generate the strongly
connected components first.
"""
function condensation end
@traitfn function condensation{T<:Integer}(g::::IsDirected, scc::Vector{Vector{T}})
    h = DiGraph{T}(length(scc))

    component = Vector{T}(nv(g))

    for (i, s) in enumerate(scc)
        @inbounds component[s] = i
    end

    @inbounds for e in edges(g)
        s, d = component[src(e)], component[dst(e)]
        if (s != d)
            add_edge!(h, s, d)
        end
    end
    return h
end
@traitfn condensation(g::::IsDirected) = condensation(g, strongly_connected_components(g))

"""
    attracting_components(g)

Return a vector of vectors of integers representing lists of attracting
components in the directed graph `g`.

The attracting components are a subset of the strongly
connected components in which the components do not have any leaving edges.
"""
function attracting_components end
@traitfn function attracting_components(g::::IsDirected)
    T = eltype(g)
    scc  = strongly_connected_components(g)
    cond = condensation(g, scc)

    attracting = Vector{T}()

    for v in vertices(cond)
        if outdegree(cond, v) == 0
            push!(attracting, v)
        end
    end
    return scc[attracting]
end

"""
    neighborhood(g, v, d)

Return a vector of the vertices in `g` at a geodesic distance less or equal to `d`
from `v`.

### Optional Arguments
- `dir=:out`: If `g` is directed, this argument specifies the edge direction
with respect to `v` of the edges to be considered. Possible values: `:in` or `:out`.
"""
neighborhood(g::AbstractGraph, v::Integer, d::Integer; dir=:out) = (dir == :out) ?
    _neighborhood(g, v, d, out_neighbors) : _neighborhood(g, v, d, in_neighbors)

function _neighborhood(g::AbstractGraph, v::Integer, d::Integer, neighborfn::Function)
    @assert d >= 0 "Distance has to be greater then zero."
    T = eltype(g)
    neighs = Vector{T}()
    push!(neighs, v)

    Q = Vector{T}()
    seen = falses(nv(g))
    dists = zeros(T, nv(g))
    push!(Q, v)
    dists[v] = d
    while !isempty(Q)
        src = shift!(Q)
        seen[src] && continue
        seen[src] = true
        currdist = dists[src]
        vertexneighbors = neighborfn(g, src)
        for vertex in vertexneighbors
            if !seen[vertex] && currdist > 0
                push!(Q, vertex)
                push!(neighs, vertex)
                dists[vertex] = currdist - 1
            end
        end
    end
    return neighs
end

"""
    isgraphical(degs)

Return true if the degree sequence `degs` is graphical, according to
[Erdös-Gallai condition](http://mathworld.wolfram.com/GraphicSequence.html).

### Performance
    Time complexity: ``\\mathcal{O}(|degs|^2)``
"""
function isgraphical(degs::Vector{Int})
    iseven(sum(degs)) || return false
    n = length(degs)
    for r = 1:(n - 1)
        cond = sum(i -> degs[i], 1:r) <= r * (r - 1) + sum(i -> min(r, degs[i]), (r + 1):n)
        cond || return false
    end
    return true
end
