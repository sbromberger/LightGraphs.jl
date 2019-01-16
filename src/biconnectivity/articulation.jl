"""
    Articulations{T}

A state type for the depth-first search that finds the articulation points in a graph.
"""
mutable struct Articulations{T<:Integer}
    low::Vector{T}
    depth::Vector{T}
    articulation_points::BitVector
    id::T
end

function Articulations(g::AbstractGraph)
    n = nv(g)
    T = typeof(n)
    return Articulations(zeros(T, n), zeros(T, n), falses(n), zero(T))
end

"""
    visit!(state, g, u, v)

Perform a depth first search storing the depth (in `depth`) and low-points
(in `low`) of each vertex.
Call this function repeatedly to complete the DFS (see [`articulation`](@ref) for usage).
"""
function visit!(state::Articulations, g::AbstractGraph, u::Integer, v::Integer)
    children = 0
    state.id += 1
    state.depth[v] = state.id
    state.low[v] = state.depth[v]

    for w in outneighbors(g, v)
        if state.depth[w] == 0
            children += 1
            visit!(state, g, v, w)

            state.low[v] = min(state.low[v], state.low[w])
            if state.low[w] >= state.depth[v] && u != v
                state.articulation_points[v] = true
            end

        elseif w != u
            state.low[v] = min(state.low[v], state.depth[w])
        end
    end
    if u == v && children > 1
        state.articulation_points[v] = true
    end
end

"""
    articulation(g)

Compute the [articulation points](https://en.wikipedia.org/wiki/Biconnected_component)
of a connected graph `g` and return an array containing all cut vertices.

# Examples
```jldoctest
julia> using LightGraphs

julia> articulation(StarGraph(5))
1-element Array{Int64,1}:
 1

julia> articulation(PathGraph(5))
3-element Array{Int64,1}:
 2
 3
 4
```
"""
function articulation(g::AbstractGraph)
    state = Articulations(g)
    for u in vertices(g)
        if state.depth[u] == 0
            visit!(state, g, u, u)
        end
    end
    return findall(state.articulation_points)
end

function iterative_articulation(g::AbstractGraph)
    s = Array{NTuple{4,Int}}(undef,0)
    articulation_points = falses(nv(g))
    low = zeros(nv(g))
    pre = zeros(nv(g))
    children = 0
    wi = 0
    w = 0
    cnt = 1
    b = true
    for u in vertices(g)
        if pre[u] != 0
            continue
        end
        v = u
        while !isempty(s) || b
            if  wi < 1
                children = 0
                pre[v] = cnt
                cnt += 1
                low[v] = pre[v]
                x = outneighbors(g,v)
                wi = 1
            else
                children,wi,u,v = pop!(s)
                x = outneighbors(g,v)
                w = x[wi]
                low[v] = min(low[v],low[w])
                if low[w] >= pre[v] && u != v
                    articulation_points[v] = true
                end
                wi += 1
            end
            while wi <= length(x)
                w = x[wi]
                if pre[w] == 0
                    children += 1
                    push!(s,(children,wi,u,v))
                    wi = 0
                    u = v
                    v = w
                    break
                elseif w != u
                    low[v] = min(low[v],pre[w])
                end
                wi += 1
            end
            if wi < 1
                continue
            end
            if u == v && children > 1
                articulation_points[v] = true
            end
            b = false
        end
    end
    return findall(articulation_points)
end
