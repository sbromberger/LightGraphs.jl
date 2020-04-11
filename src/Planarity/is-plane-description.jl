"""
    is_plane_description(g, g.fadjlist)

Returns `true` if the given combinatorial description of graph `g` is plane.

The algorithm requires the graph `g` to be simple and undirected.
### Optional Arguments
- `description = g.fadjlist`: if the description is specified, it uses the new description instead of using `g.fadjlist`.

A drawing of a planar graph induces a cyclic clockwise order in the neighbors of each vertex.
A list of these cyclic orders is called a combinatorial description of the drawing.
A facial cycle of a combinatorial description D is a cycle (v_0,v_1,...,v_k,v_0) where v_i+1 succeeds v_i-1 in the list D(v_i).
A combinatorial description of a plane graph is also called plane.
Clearly, every planar graph has a combinatorial description which is plane.
This algorithm is correct because of the following theorem:
    A combinatorial description D of a drawing of a graph G is plane
        if and only if
    nv(G) - ne(G) + fD = 2, where fD is the number of facial cycles of description D.

This algorithm is presented in the dissertation available at https://www.ime.usp.br/~coelho/sh/index.html.
"""

function is_plane_description end

@traitfn function is_plane_description(g::AG::(!IsDirected),
                    description::Vector{Vector{T}} 
                    = g.fadjlist) where {T <: Integer, U, AG <: AbstractGraph{U}}

    if nv(g) >= 3 && ne(g) > 3*nv(g) - 6 return false 
        
    # in cycle_succ(e) we find the successor of src(e) in the list of dst(e)
    function cycle_succ(e)
        u, v = src(e), dst(e)
        v_list = description[v]
        u_index = findfirst(x -> x == u, v_list)
        
        if u_index == length(v_list) return Edge(v, first(v_list)) end
        
        return Edge(v, v_list[u_index + 1])
    end

    # duplicating edges because each edge `e` participates of at most two facial cycles
    # the direction is important due to the clockwise description, so the second copy is reversed
    reversed_edges = [reverse(e) for e in edges(g)]
    duplicated_edges = vcat(collect(edges(g)), reversed_edges)

    # used[e] indicates if edge e has been used in a facial cycle
    used = Dict(e => false for e in duplicated_edges)

    faces = zero(T)
    # counting facial cycles
    for e in duplicated_edges
        if !used[e]
            e1 = e
            while true
                used[e1] = true
                e1 = cycle_succ(e1)
                e1 == e && break
            end
            faces += 1
        end
    end

    # using Euler's formula
    if faces != ne(g) - nv(g) + 2 return false end

    return true
end
