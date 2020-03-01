abstract type Visitor{T <: Integer} end

"""
    struct Johnson <: SimpleCycleAlgorithm
        iterative::Bool
        ceiling::Int

A `SimpleCycleAlgorithm` that specifies the use of Johnson.
If `iterative` is `true` (default: `false`), use an iterative
version of the algorithm and stop after `ceiling` iterations;
otherwise use the recursive version.

### Performance
Because the number of cycles grows more than exponentially with the number of vertices,
you might want to use the algorithm in iterative mode on large directed graphs.
If you want to have an idea of the possible number of cycles, look at function
[`max_simple_cycles()`](@ref). If you only need short cycles of a limited length, the
[`LimitedLength`](@ref) algorithm can be more efficient.

If the graph is small, the ceiling will not be reached and the recursive function
will be more efficient, as it avoids the overhead of the counting and testing if
the ceiling is reached. The iterative version returns all the cycles of the directed
graph if the `ceiling` is not reached; a subset of them otherwise.

### References
- [Johnson](http://epubs.siam.org/doi/abs/10.1137/0204007)
"""
struct Johnson <: SimpleCycleAlgorithm
    iterative::Bool
    ceiling::Int
end

Johnson() = Johnson(false, 10e6)

"""
    max_simple_cycles(dg::::IsDirected, byscc::Bool = true)

Compute the theoretical maximum number of cycles in the directed graph `dg`.

The computation can be performed assuming the graph is complete or taking into account the
decomposition in strongly connected components (`byscc` parameter).

### Performance
A more efficient version is possible.

### References
- [Johnson](http://epubs.siam.org/doi/abs/10.1137/0204007)
"""
function max_simple_cycles end
@traitfn function max_simple_cycles(dg::::IsDirected, byscc::Bool=true)
    c::BigInt = zero(BigInt)
    n = nv(dg)
    if !byscc
        c = max_simple_cycles(n)
    else
        for scc in strongly_connected_components(dg)
            if length(scc) > 1
                c += max_simple_cycles(length(scc))
            end
        end
    end
    return c
end

"""
```
type JohnsonVisitor{T<:Integer} <: Visitor{T}
    stack::Vector{T}
    blocked::BitVector
    blockedmap::Vector{Set{T}}
end

JohnsonVisitor(dg::::IsDirected)

```

Composite type that regroups the information needed for Johnson's algorithm.

`stack` is the stack of visited vertices. `blocked` is a boolean for each
vertex that tells whether it is blocked or not. `blockedmap` tells which
vertices to unblock if the key vertex is unblocked.

`JohnsonVisitor` may also be constructed directly from the directed graph.
"""
struct JohnsonVisitor{T <: Integer} <: Visitor{T}
    stack::Vector{T}
    blocked::BitVector
    blockedmap::Vector{Set{T}}
    allcycles::Vector{Vector{T}}
end

function JohnsonVisitor(dg)
    # dg should be a directed graph, we had some problems with type instability and @traitfn
    # so we removed the type check for this (Julia v1.1.0), this might change in the future.
    T = eltype(dg)
    return JohnsonVisitor(Vector{T}(), falses(nv(dg)), [Set{T}() for i in vertices(dg)])
end

"""
    unblock!{T<:Integer}(v::T, blocked::BitVector, B::Vector{Set{T}})

Unblock the vertices recursively.

`v` is the vertex to unblock, `blocked` tells whether a vertex is blocked or
not and `B` is the map that tells if the unblocking of one vertex should
unblock other vertices.
"""
function unblock!(v::T, blocked::BitVector, B::Vector{Set{T}}) where T <: Integer
    blocked[v] = false
    for w in B[v]
        delete!(B[v], w)
        if blocked[w]
            unblock!(w, blocked, B)
        end
    end
end

"""
    circuit{T<:Integer}(v::T, dg::::IsDirected, vis::JohnsonVisitor{T},
    allcycles::Vector{Vector{T}}, vmap::Vector{T}, startnode::T = v)

Return one step of the recursive version of simple cycle detection,
using a DFS algorithm.


* `v`: the vertex considered in this iteration of the DFS
* `dg`: the digraph from which cycles are computed
* `visitor`: Informations needed for the cycle computation, contains:
    * `stack`: the stack of parent vertices
    * `blocked`: tells whether a vertex has already been explored or not
    * `blockedmap`: mapping of the blocking / unblocking consequences
* `allcycles`: output containing the cycles already detected
* `vmap`: vector map containing the link from the old to the new nodes of the directed graph
* `startnode = v`: optional argument giving the starting node. In the first iteration,
 the same as v, otherwise it should be passed.

### Implementation Notes
Implements Johnson's CIRCUIT function. This is a recursive version.
Modifies the vector of cycles, when needed.
 
### References
- [Johnson](http://epubs.siam.org/doi/abs/10.1137/0204007)
"""
function circuit end
@traitfn function circuit(v::T, dg::::IsDirected, vis::JohnsonVisitor{T},
allcycles::Vector{Vector{T}}, vmap::Vector{T}, startnode::T=v) where T <: Integer
    done = false
    push!(vis.stack, v)
    vis.blocked[v] = true
    for w in outneighbors(dg, v)
        if w == startnode
            push!(allcycles, vmap[vis.stack])
            done = true
        elseif !vis.blocked[w]
            circuit(w, dg, vis, allcycles, vmap, startnode) && (done = true) #This is different from done = circuit(...). It keeps the previous value of done in the for loop
        end
    end
    if done
        unblock!(v, vis.blocked, vis.blockedmap)
    else
        for w in outneighbors(dg, v)
            if !in(vis.blockedmap[w], v)
                push!(vis.blockedmap[w], v)
            end
        end
    end
    pop!(vis.stack)
    return done
end


@traitfn simple_cycles(dg::::IsDirected, j::Johnson) =
    j.iterative ? _johnson_simple_cycles_iter(dg) : _johnson_simple_cycles_recursive(dg)

@traitfn function _johnson_simple_cycles_recursive(dg::::IsDirected)
    T = eltype(dg)
    sccs = strongly_connected_components(dg)
    cycles = Vector{Vector{T}}()
    for scc in sccs
        for i in 1:length(scc)
            wdg, vmap = induced_subgraph(dg, scc[i:end])
            visitor = JohnsonVisitor(wdg)
            circuit(T(1), wdg, visitor, cycles, vmap) # 1 is the startnode.
        end
    end
    return cycles
end


##########################################################
#### Iterative version, using Tasks, of the previous algorithms.
"""
    circuit_iter{T<:Integer}(v::T, dg::::IsDirected, vis::JohnsonVisitor{T},
    vmap::Vector{T}, cycle::Channel, startnode::T = v)

Execute one step of the recursive version of simple cycle detection, using a DFS algorithm.
Return `true` if a circuit has been found in the current exploration.

# Arguments
* v: the vertex considered in this iteration of the DFS
* dg: the digraph from which cycles are computed
* visitor: Informations needed for the cycle computation, contains:
    * stack: the stack of parent vertices
    * blocked: tells whether a vertex has already been explored or not
    * blockedmap: mapping of the blocking / unblocking consequences
* `vmap`: vector map containing the link from the old to the new nodes of the directed graph
* `cycle`: storage of the channel
* startnode = v: optional argument giving the starting node. In the first iteration,
the same as v, otherwise it should be passed.

### Implementation Notes
Implements the CIRCUIT function from Johnson's algorithm, recursive and iterative version.
Produces a cycle when needed. Can be used only inside a `Channel`.

### References
- [Johnson](http://epubs.siam.org/doi/abs/10.1137/0204007)
"""
function circuit_iter end
@traitfn function circuit_iter(v::T, dg::::IsDirected, vis::JohnsonVisitor{T}, vmap::Vector{T},
            cycle::Channel{Vector{T}}, startnode::T=v) where T <: Integer

    done = false
    push!(vis.stack, v)
    vis.blocked[v] = true
    for w in outneighbors(dg, v)
        if w == startnode
            put!(cycle, vmap[vis.stack])
            done = true
        elseif !vis.blocked[w]
            circuit_iter(w, dg, vis, vmap, cycle, startnode) && (done = true) #This is different from done = circuit(...). It keeps the previous value of done in the for loop
        end
    end
    if done
        unblock!(v, vis.blocked, vis.blockedmap)
    else
        for w in outneighbors(dg, v)
            if !in(vis.blockedmap[w], v)
                push!(vis.blockedmap[w], v)
            end
        end
    end
    pop!(vis.stack)
    return done
end


@traitfn function _johnson_simple_cycles_iterative(dg::AG::IsDirected, cycle::Channel{Vector{T}}) where {T, AG <: AbstractGraph{T}}
    sccs = strongly_connected_components(dg)
    for scc in sccs
        while length(scc) >= 1
            wdg, vmap = induced_subgraph(dg, scc)
            popfirst!(scc)
            visitor = JohnsonVisitor(wdg)
            circuit_iter(T(1), wdg, visitor, vmap, cycle)
        end
    end
end

"""
    count_simple_cycles(dg::DiGraph, ::SimpleCyclesAlgorithm)

Count the number of cycles in a directed graph, using a specific algorithm (default:
`Johnson`). Return the minimum of the ceiling and the number of cycles.

### Implementation Notes
If the algorithm supports it, the `ceiling` parameter of the `SimpleCycleAlgorithm` structure may be
used to avoid memory overload if there are a lot of cycles in the graph. You can use the function
[`max_simple_cycles()`](@ref) to get an idea of the theoretical maximum number or cycles.

# Examples
```jldoctest
julia> simple_cycles_count(complete_digraph(6))
409
```
"""
function count_simple_cycles end
@traitfn function count_simple_cycles(dg::AG::IsDirected, j::Johnson) where {T, AG <: AbstractGraph{T}}
    len = 0
    ceiling = j.ceiling
    for cycle in Iterators.take(Channel(c -> itercycles(dg, c), ctype=Vector{T})::Channel{Vector{T}}, ceiling)
        len += 1
    end
    return len
end

@traitfn _johnson_simple_cycles_iter(dg::AG::IsDirected, j::Johnson) where {T, AG <: AbstractGraph{T}} =
    return collect(Iterators.take(Channel(c -> _johnson_simple_cycles_iterative(dg, c), ctype=Vector{T}), j.ceiling))::Vector{Vector{T}}

"""
    simple_cycles_length(dg::DiGraph, ::SimpleCycleAlgorithm)

Search all cycles of the given directed graph, using an appropriate `SimpleCycleAlgorithm`
(default: `Johnson`). Return a tuple representing the cycle length and the number of cycles.

### Implementation Notes
If the algorithm supports it, the `ceiling` parameter of the `SimpleCycleAlgorithm` structure may be
used to avoid memory overload if there are a lot of cycles in the graph. You can use the function
[`max_simple_cycles()`](@ref) to get an idea of the theoretical maximum number or cycles.
If the `ceiling` is reached (`ncycles = ceiling`), the output is only a subset of the cycles lengths.

### References
- [Johnson](http://epubs.siam.org/doi/abs/10.1137/0204007)

# Examples
```jldoctest
julia> simple_cycles_length(complete_digraph(16), Johnson())
([0, 1, 1, 1, 1, 1, 2, 10, 73, 511, 3066, 15329, 61313, 183939, 367876, 367876], 1000000)

julia> simplecycleslength(wheel_digraph(16))
([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0], 1)
```
"""
@traitfn function simple_cycles_length(dg::AG::IsDirected, j::Johnson) where {T, AG <: AbstractGraph{T}}
    ncycles = 0
    cyclelength = zeros(Int, nv(dg))
    for cycle in Iterators.take(Channel(c -> itercycles(dg, c), ctype=Vector{T})::Channel{Vector{T}}, j.ceiling)
        cyclelength[length(cycle)] += 1
        ncycles += 1
    end
    return cyclelength, ncycles
end
