using SimpleTraits

using LightGraphs.Experimental.Traversals

mutable struct JohnsonCycleState{T<:Integer} <: Traversals.AbstractTraversalState
    dg::DiGraph
    done::BitVector
    stack::Vector{T}
    blockedmap::Vector{Set{T}}
    cycles::Vector{Vector{T}}
    vmap::Vector{T}
    startnode::T
end

@inline function previsitfn!(s::Traversals.JohnsonCycleState{T}, u) where T
    if isempty(s.stack) || s.stack[end] != u
        push!(s.stack, u)
        s.done[u] = false
    end
    return true
end 

@inline function visitfn!(s::Traversals.JohnsonCycleState{T}, u, v) where T
    println(s.stack, " ", u, " ", v)
    if s.startnode == v 
        push!(s.cycles, s.vmap[s.stack])
        s.done[u] = true
    end 
    return true
end

@inline function postlevelfn!(s::Traversals.JohnsonCycleState{T}, blocked::BitVector, u) where T
    if s.done[u]
        stack_unblock = [u] 
        println(blocked)
        blocked[u] = false
        while !isempty(stack_unblock)
            v = pop!(stack_unblock)
            for w in s.blockedmap[v]
                delete!(s.blockedmap[v], w)
                if blocked[w]
                    blocked[w] = false 
                    push!(stack_unblock, w)
                end
            end 
        end
    else 
        for w in outneighbors(s.dg, u)
            if !in(s.blockedmap[w], u)
                push!(s.blockedmap[w], u)
            end 
        end 
    end 
    pop!(s.stack)
    if !isempty(s.stack)
        s.done[s.stack[end]] |= s.done[u]
    end
    return true
end

@traitfn function circuit2(dg::::IsDirected, cycles::Vector{Vector{T}}, vmap::Vector{T}, 
    startnode::T=1) where T <: Integer
    println(dg, startnode)
    done = falses(nv(dg))
    stack = Vector{T}()
    blockedmap = [Set{T}() for i in 1:nv(dg)]
    state = Traversals.JohnsonCycleState(dg, done, stack, blockedmap, cycles, vmap, startnode)
    Traversals.traverse_graph!(dg, startnode, Traversals.DFS(), state)
    return 
end

@traitfn function simplecycles2(dg::::IsDirected)
    T = eltype(dg)
    sccs = strongly_connected_components(dg)
    cycles = Vector{Vector{T}}()
    for scc in sccs
        for i in 1:length(scc)
            wdg, vmap = induced_subgraph(dg, scc[i:end])
            circuit2(wdg, cycles, vmap)
        end
    end
    return cycles
end
