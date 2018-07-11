# Code in this file inspired by NetworkX.

"""
    cycle_basis(g, root=nothing)

Returns a list of cycles which form a basis for cycles of `g`.

A basis for cycles of a network is a minimal collection of
cycles such that any cycle in the network can be written
as a sum of cycles in the basis.  Here summation of cycles
is defined as "exclusive or" of the edges. Cycle bases are
useful, e.g. when deriving equations for electric circuits
using Kirchhoff's Laws.

# Arguments
- `g::AbstractGraph`: Graph
- `root=nothing`: Specify a starting node for basis

# Example
```jldoctest
julia> nodes = [1,2,3,4,5]
julia> edgs = [(1,2),(2,3),(2,4),(3,4),(4,1),(1,5)]
julia> g = Graph(length(nodes))
julia> for e in edgs add_edge!(g, e) end
julia> cycle_basis(g)
2-element Array{Array{Int64,1},1}:
 [2, 3, 4]
 [2, 1, 3]
```

# References
* Paton, K. An algorithm for finding a fundamental set of cycles of a graph. Comm. ACM 12, 9 (Sept 1969), 514-518. [https://dl.acm.org/citation.cfm?id=363232]
"""
function cycle_basis(g::AbstractGraph, root=nothing)
    gnodes = Set(vertices(g))
    cycles = Array{eltype(g),1}[]
    while !isempty(gnodes)
        if root == nothing
            root = pop!(gnodes)
        end
        stack = [root]
        pred = Dict(root => root)
        used = Dict(root => [])
        while !isempty(stack)
            z = pop!(stack)
            zused = used[z]
            for nbr in neighbors(g,z)
                if !in(nbr, keys(used))
                    pred[nbr] = z
                    push!(stack,nbr)
                    used[nbr] = [z]
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
        setdiff!(gnodes,keys(pred))
        root = nothing
    end
    return cycles
end
