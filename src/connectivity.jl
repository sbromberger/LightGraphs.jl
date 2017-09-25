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
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function connected_components!{T, AG<:AbstractGraph{T}}(label::AbstractVector, g::AG::(!IsDirected))
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
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function connected_components{T, AG<:AbstractGraph{T}}(g::AG::(!IsDirected))
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


"""
    strongly_connected_components(g)

Compute the strongly connected components of a directed graph `g`.

Return an array of arrays, each of which is the entire connected component.

### Implementation Notes
The order of the components is not part of the API contract.
"""
function strongly_connected_components end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function strongly_connected_components{T, AG<:AbstractGraph{T}}(g::AG::IsDirected)
    zero_t = zero(T)
    one_t = one(T)
    nvg = nv(g)
    count = one_t
    index = zeros(T, nvg)         # first time in which vertex is discovered
    stack = Vector{T}()           # stores vertices which have been discovered and not yet assigned to any component
    onstack = zeros(Bool, nvg)    # false if a vertex is waiting in the stack to receive a component assignment
    lowlink = zeros(T, nvg)       # lowest index vertex that it can reach through back edge (index array not vertex id number)
    parents = zeros(T, nvg)       # parent of every vertex in dfs
    components = zeros(T, nvg)    # mapping of vertex to component
    compnumber = 1
    sizehint!(stack, nvg)

    for s in vertices(g)
        if index[s] == zero_t
            index[s] = count
            lowlink[s] = count
            onstack[s] = true
            parents[s] = s
            push!(stack, s)
            count = count + one_t

            # start dfs from 's'
            dfs_stack = Vector{T}([s])
            while !isempty(dfs_stack)
                v = dfs_stack[end] #end is the most recently added item
                u = zero_t
                for n in out_neighbors(g, v)
                    if index[n] == zero_t
                        # unvisited neighbor found
                        u = n
                        break
                        #GOTO A push u onto DFS stack and continue DFS
                    elseif onstack[n]
                        # we have already seen n, but can update the lowlink of v
                        # which has the effect of possibly keeping v on the stack until n is ready to pop.
                        # update lowest index 'v' can reach through out neighbors
                        lowlink[v] = min(lowlink[v], index[n])
                    end
                end
                if u == zero_t
                    # All out neighbors already visited or no out neighbors
                    # we have fully explored the DFS tree from v.
                    # time to start popping.
                    popped = pop!(dfs_stack)
                    lowlink[parents[popped]] = min(lowlink[parents[popped]], lowlink[popped])
                    if index[v] == lowlink[v]
                        # found a cycle in a completed dfs tree.
                        component = Vector{T}()
                        sizehint!(component, length(stack))
                        while !isempty(stack) #break when popped == v
                            # drain stack until we see v.
                            # everything on the stack until we see v is in the SCC rooted at v.
                            popped = pop!(stack)
                            push!(component, popped)
                            onstack[popped] = false
                            # popped has been assigned a component, so we will never see it again.
                            if popped == v
                                # we have drained the stack of an entire component.
                                break
                            end
                        end
                        components[component] = compnumber
                        compnumber += 1
                    end
                else #LABEL A
                    # add unvisited neighbor to dfs
                    index[u] = count
                    lowlink[u] = count
                    onstack[u] = true
                    parents[u] = v
                    count = count + one_t
                    push!(stack, u)
                    push!(dfs_stack, u)
                    # next iteration of while loop will expand the DFS tree from u.
                end
            end
        end
    end
    return [T.(findin(components,i)) for i in 1:compnumber]
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
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function period{T, AG<:AbstractGraph{T}}(g::AG::IsDirected)
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
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function attracting_components{T, AG<:AbstractGraph{T}}(g::AG::IsDirected)
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

function _neighborhood(g::AbstractGraph{T}, v::Integer, d::Integer, neighborfn::Function) where T
    @assert d >= 0 "Distance has to be greater then zero."
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
