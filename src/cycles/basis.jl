# Code in this file inspired by NetworkX.

"""
    cycle_basis(g, root=nothing)

Return a list of cycles which form a basis for cycles of graph `g`, optionally starting at node `root`.

A basis for cycles of a network is a minimal collection of
cycles such that any cycle in the network can be written
as a sum of cycles in the basis.  Here summation of cycles
is defined as "exclusive or" of the edges. Cycle bases are
useful, e.g. when deriving equations for electric circuits
using Kirchhoff's Laws.

Example:
```jldoctest
julia> elist = [(1,2),(2,3),(2,4),(3,4),(4,1),(1,5)]
julia> g = SimpleGraph(SimpleEdge.(elist))
julia> cycle_basis(g)
2-element Array{Array{Int64,1},1}:
 [2, 3, 4]
 [2, 1, 3]
```

### References
* Paton, K. An algorithm for finding a fundamental set of cycles of a graph. Comm. ACM 12, 9 (Sept 1969), 514-518. [https://dl.acm.org/citation.cfm?id=363232]
"""
function cycle_basis(g::AbstractSimpleGraph, root=nothing)
    gnodes = Set(vertices(g))
    cycles = Vector{Vector{eltype(g)}}()
    while !isempty(gnodes)
        if root == nothing
            root = pop!(gnodes)
        end
        stack = [root]
        pred = Dict(root => root)
        keys_pred = Set(root)
        used = Dict(root => [])
        keys_used = Set(root)
        while !isempty(stack)
            z = pop!(stack)
            zused = used[z]
            for nbr in neighbors(g,z)
                if !in(nbr, keys_used)
                    pred[nbr] = z
                    push!(keys_pred, nbr)
                    push!(stack,nbr)
                    used[nbr] = [z]
                    push!(keys_used, nbr)
                elseif nbr == z
                    push!(cycles, [z])
                elseif !in(nbr, zused)
                    pn = used[nbr]
                    cycle = [nbr,z]
                    p = pred[z]
                    while !in(p, pn)
                        push!(cycle, p)
                        p = pred[p]
                    end
                    push!(cycle,p)
                    push!(cycles,cycle)
                    push!(used[nbr], z)
                end
            end
        end  
        setdiff!(gnodes,keys_pred)
        root = nothing
    end
    return cycles
end
