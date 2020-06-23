"""
    biconnected_components(g) -> Vector{Vector{Edge{eltype(g)}}}

Compute the [biconnected components](https://en.wikipedia.org/wiki/Biconnected_component)
of an undirected graph `g`and return a vector of vectors containing each
biconnected component.

Performance:
Time complexity is ``\\mathcal{O}(|V|+|E|)``.

# Examples
```jldoctest
julia> using LightGraphs

julia> biconnected_components(star_graph(5))
4-element Array{Array{LightGraphs.SimpleGraphs.SimpleEdge,1},1}:
 [Edge 1 => 3]
 [Edge 1 => 4]
 [Edge 1 => 5]
 [Edge 1 => 2]

julia> biconnected_components(cycle_graph(5))
1-element Array{Array{LightGraphs.SimpleGraphs.SimpleEdge,1},1}:
 [Edge 1 => 5, Edge 4 => 5, Edge 3 => 4, Edge 2 => 3, Edge 1 => 2]
```
"""
function biconnected_components end
@traitfn function biconnected_components(g::AG::(!IsDirected)) where {T, AG<:AbstractGraph{T}}
    nvg = nv(g)
    timer = one(T)
    disc = zeros(T, nvg)
    low = Vector{T}(undef, nvg)
    stk = Vector{Tuple{T, T, T}}()
    sizehint!(stk, nvg)
    track = Vector{SimpleEdge{T}}()
    bcc = Vector{Vector{SimpleEdge{T}}}()

    for w in vertices(g)
        disc[w] != 0 && continue
        children = 0
        push!(stk, (w, 0, 0))
        while !isempty(stk)
            u, i, prnt = pop!(stk)
            neighs = outneighbors(g, u)
            if disc[u] == 0
                disc[u] = timer
                low[u] = timer
                timer += 1
            else
                nbr = neighs[i]
                low[u] = min(low[u], low[nbr])
                if (prnt == 0 && children > 1) || (prnt != 0 && low[nbr] >= disc[u])
                    e = SimpleEdge(min(u, nbr), max(u, nbr))
                    x = Vector{SimpleEdge{T}}()
                    while track[end] != e
                        push!(x, pop!(track))
                    end
                    push!(x, pop!(track))
                    push!(bcc, x)
                end
            end
            i += 1
            while i <= length(neighs)
                v = neighs[i]
                if disc[v] == 0
                    if u == w
                        children += 1
                    end
                    push!(stk, (u, i, prnt))
                    push!(stk, (v, 0, u))
                    push!(track, SimpleEdge(min(u, v), max(u, v)))
                    break
                elseif v != prnt
                    low[u] = min(low[u], disc[v])
                    if disc[v] < disc[u]
                        push!(track, SimpleEdge(min(u, v), max(u, v)))
                    end
                end
                i += 1
            end
        end
        if !isempty(track)
            push!(bcc, reverse(track))
            empty!(track)
        end
    end
    return bcc
end
