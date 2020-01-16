"""
    boruvka_mst(g, distmx = weights(g); minimize = true)

Return a tuple `(mst, weights)` where `mst` is a vector of edges representing the
optimum (minimum, by default) spanning tree of a connected, undirected graph
`g` with optional matrix `distmx` that provides distinct edge weights, and
`weights` is the sum of all the edges in the solution by using
[Boruvka's algorithm](https://en.wikipedia.org/wiki/Bor%C5%AFvka%27s_algorithm).
The algorithm requires that all edges have different weights to correctly generate a minimun/maximum spanning tree
### Optional Arguments
- `minimize=true`: if set to `false`, calculate the maximum spanning tree.
"""

function boruvka_mst end 

@traitfn function boruvka_mst(graph::AG::(!IsDirected), 
        distmx::AbstractMatrix{T} = weights(graph); 
        minimize = true) where {T<:Real,U,AG<:AbstractGraph{U}}

    djset = IntDisjointSets(nv(graph))
    # maximizing Z is the same as minimizing -Z
    # mode will indicate the need for the -1 multiplication
    mode = (-1)^(minimize ? 0 : 1)

    mst = Vector{edgetype(graph)}()
    sizehint!(mst, nv(graph) - 1)
    weight = zero(T)

    while true
    
        cheapest = Vector{Union{edgetype(graph), Nothing}}(nothing, nv(graph))
    
        # find cheapest edge that connects two components 
        found_edge = false
        for edge in edges(graph)
            set1 = find_root(djset, src(edge))
            set2 = find_root(djset, dst(edge))
    
            if set1 != set2
                found_edge = true
    
                e1 = cheapest[set1]
                if e1===nothing || distmx[src(e1), dst(e1)]*mode > distmx[src(edge), dst(edge)]*mode
                    cheapest[set1] = edge
                end
    
                e2 = cheapest[set2]
                if e2===nothing || distmx[src(e2), dst(e2)]*mode > distmx[src(edge), dst(edge)]*mode
                    cheapest[set2] = edge
                end
            end
        end

        #no more edges between two components    
        !found_edge && break
    
        # add cheapest edges to the tree
        for v in vertices(graph)
    
            if cheapest[v] !== nothing
    
                edge = cheapest[v]        
                if !in_same_set(djset, src(edge), dst(edge))
                    weight += distmx[src(edge), dst(edge)]
                    union!(djset, src(edge), dst(edge))
                    push!(mst, edge)
                end
            end
        end
    end
    
    return (mst=mst,weight=weight)
end
