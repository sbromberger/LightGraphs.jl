abstract type Visitor{T<:Integer} end

"""
    ncycles_n_i(n::Integer, i::Integer)

Compute the theoretical maximum number of cycles of size `i` in a directed graph of `n`
 vertices.
"""
ncycles_n_i(n::Integer, i::Integer) =
    binomial(big(n), big(n - i + 1)) * factorial(big(n - i))

"""
    maxsimplecycles(n::Integer)

Compute the theoretical maximum number of cycles in a directed graph of `n` vertices,
assuming there are no self-loops.
The formula is coming from [Johnson, 1973](Johnson).

### References
- [Johnson](http://epubs.siam.org/doi/abs/10.1137/0204007).
"""
maxsimplecycles(n::Integer) = sum(x -> ncycles_n_i(n, x), 1:(n - 1))


@doc_str """
    maxsimplecycles(dg::::IsDirected, byscc::Bool = true)

Compute the theoretical maximum number of cycles in the directed graph `dg`.

The computation can be performed assuming the graph is complete or taking into account the
decomposition in strongly connected components (`byscc` parameter). The formula is coming from
[Johnson, 1973](Johnson).


### Performance
A more efficient version is possible.

### References
- [Johnson](http://epubs.siam.org/doi/abs/10.1137/0204007)
"""
function maxsimplecycles end
@traitfn function maxsimplecycles(dg::::IsDirected, byscc::Bool = true)
    c = 0
    n = nv(dg)
    if !byscc
        c = maxsimplecycles(n)
    else
        for scc in strongly_connected_components(dg)
            if length(scc) > 1
                c += maxsimplecycles(length(scc))
            end
        end
    end
    return c
end

"""
```
type JohnsonVisitor{T<:Integer} <: Visitor{T}
    stack::Vector{T}
    blocked::BitArray
    blockedmap::Vector{Set{T}}
end
```

Composite type that regroups the information needed for Johnson's algorithm.

`stack` is the stack of visited vertices. `blocked` is a boolean for each 
vertex that tells whether it is blocked or not. `blockedmap` tells which 
vertices to unblock if the key vertex is unblocked.
"""
struct JohnsonVisitor{T<:Integer} <: Visitor{T}
    stack::Vector{T}
    blocked::BitArray
    blockedmap::Vector{Set{T}}
end

"""
    JohnsonVisitor(dg::::IsDirected)

Constructor of the visitor, using the directed graph information.
"""
JohnsonVisitor(dg::DiGraph{T}) where T<:Integer =
    JohnsonVisitor(Vector{T}(), falses(vertices(dg)), [Set{T}() for i in vertices(dg)])

"""
    unblock!{T<:Integer}(v::T, blocked::BitArray, B::Vector{Set{T}})

Unblock the vertices recursively. 

`v` is the vertex to unblock, `blocked` tells whether a vertex is blocked or 
not and `B` is the map that tells if the unblocking of one vertex should 
unblock other vertices.
"""
function unblock!(v::T, blocked::BitArray, B::Vector{Set{T}}) where T<:Integer
    blocked[v] = false
    for w in B[v]
        delete!(B[v], w)
        if blocked[w]
            unblock!(w, blocked, B)
        end
    end
end

@doc_str """
    circuit{T<:Integer}(v::T, dg::::IsDirected, vis::JohnsonVisitor{T}, 
    allcycles::Vector{Vector{T}}, vmap::Vector{T}, startnode::T = v)

One step of the recursive version of simple cycle detection, using a DFS algorithm.

The CIRCUIT function from [Johnson, 1973](Johnson),
recursive version. Modify the vector of cycles, when needed.


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

### References
- [Johnson](http://epubs.siam.org/doi/abs/10.1137/0204007)
"""
function circuit end
@traitfn function circuit{T<:Integer}(v::T, dg::::IsDirected, vis::JohnsonVisitor{T}, 
allcycles::Vector{Vector{T}}, vmap::Vector{T}, startnode::T = v)
    done = false
    push!(vis.stack, v)
    vis.blocked[v] = true
    for w in out_neighbors(dg, v)
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
        for w in out_neighbors(dg, v)
            if !in(vis.blockedmap[w], v)
                push!(vis.blockedmap[w], v)
            end
        end
    end
    pop!(vis.stack)
    return done
end


@doc_str """
    simplecycles(dg::::IsDirected)

Compute all cycles of the given directed graph, using
[Johnson, 1973](Johnson)'s algorithm and return them.

### Performance
The number of cycles grows more than exponentially with the number of vertices,
you might want to use the algorithm with a ceiling -- `getcycles` -- on large directed graphs
(slightly slower). If you want to have an idea of the possible number of cycles,
look at function `maxsimplecycles(dg::DiGraph, byscc::Bool = true)`.

### References
- [Johnson](http://epubs.siam.org/doi/abs/10.1137/0204007)
"""
function simplecycles end
@traitfn function simplecycles(dg::::IsDirected)
    sccs = strongly_connected_components(dg)
    cycles = Vector{Vector{Int}}() # Pas très cohérent : devrait être du type de dg.
    for scc in sccs
        for i in 1:length(scc)
            wdg, vmap = induced_subgraph(dg, scc[i:end])
            visitor = JohnsonVisitor(wdg)
            circuit(1, wdg, visitor, cycles, vmap) # 1 is the startnode.
        end
    end
    return cycles
end


##########################################################
#### Iterative version, using Tasks, of the previous algorithms.
@doc_str """
    circuit_iter{T<:Integer}(v::T, dg::::IsDirected, vis::JohnsonVisitor{T}, 
    vmap::Vector{T}, cycle::Channel, startnode::T = v)

One step of the recursive version of simple cycle detection, using a DFS algorithm.

The CIRCUIT function from [Johnson, 1973](Johnson)'s algorithm,
 recursive and iterative version. Produce a cycle when needed, can be used only inside a
 Channel.

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

# Returns
* done: tells whether a circuit has been found in the current exploration.

### References
- [Johnson](http://epubs.siam.org/doi/abs/10.1137/0204007)
"""
function circuit_iter end
@traitfn function circuit_iter{T<:Integer}(v::T, dg::::IsDirected, vis::JohnsonVisitor{T}, 
vmap::Vector{T}, cycle::Channel, startnode::T = v)
    done = false
    push!(vis.stack, v)
    vis.blocked[v] = true
    for w in out_neighbors(dg, v)
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
        for w in out_neighbors(dg, v)
            if !in(vis.blockedmap[w], v)
                push!(vis.blockedmap[w], v)
            end
        end
    end
    pop!(vis.stack)
    return done
end


"""
    itercycles(dg::::IsDirected, cycle::Channel)

Compute all cycles of the given directed graph, using
[Johnson, 1973](Johnson)'s algorithm.

Iterative version of the algorithm, using Channels to stop the exploration
after a given number of cycles.

### References
- [Johnson](http://epubs.siam.org/doi/abs/10.1137/0204007)
"""
function itercycles end
@traitfn function itercycles(dg::::IsDirected, cycle::Channel)
    sccs = strongly_connected_components(dg)
    for scc in sccs
        while length(scc) >= 1
            wdg, vmap = induced_subgraph(dg, scc)
            shift!(scc)
            visitor = JohnsonVisitor(wdg)
            circuit_iter(1, wdg, visitor, vmap, cycle)
        end
    end
end

@doc_str """
    simplecyclescount(dg::DiGraph, ceiling = 10^6)

Count the number of cycles in a directed graph, using
[Johnson, 1973](Johnson)'s algorithm.

The `ceiling` is here to avoid memory overload if there are a lot of cycles in the graph.
Default value is 10^6, but it can be higher or lower. You can use the function
```maxsimplecycles(dg::DiGraph, byscc::Bool = true)``` to get an idea of the
theoretical maximum number or cycles.

Returns the minimum of the ceiling and the number of cycles.

### References
- [Johnson](http://epubs.siam.org/doi/abs/10.1137/0204007)
"""
function simplecyclescount end
@traitfn function simplecyclescount(dg::::IsDirected, ceiling = 10^6)
    len = 0
    for cycle in Iterators.take(Channel(c -> itercycles(dg, c)), ceiling)
        len += 1
    end
    return len
end

@doc_str """
    simplecycles_iter(dg::DiGraph, ceiling = 10^6)

Search all cycles of the given directed graph, using
[Johnson, 1973](Johnson)'s algorithm,
up to the ceiling (avoid memory overload).

If the graph is small, the ceiling will not be reached and
``simplecycles(dg::DiGraph)`` is more efficient. It avoids the overhead of the
counting and testing if the ceiling is reached. It returns all the cycles of the
directed graph if the `ceiling` is not reached, a subset of them otherwise.

To get an idea of the possible number of cycles, using function
```maxsimplecycles(dg::DiGraph, byscc::Bool = true)``` on the directed graph.

### References
- [Johnson](http://epubs.siam.org/doi/abs/10.1137/0204007)
""" 
function simplecycles_iter end
@traitfn simplecycles_iter(dg::::IsDirected, ceiling = 10^6) =
    collect(Iterators.take(Channel(c -> itercycles(dg, c)), ceiling))

@doc_str """
    simplecycleslength(dg::DiGraph, ceiling = 10^6)

Search all cycles of the given directed graph, using
[Johnson, 1973](Johnson)'s algorithm, and return their length.

To get an idea of the possible number of cycles, using function
```maxsimplecycles(dg::DiGraph, byscc::Bool = true)``` on the directed graph.


It returns `cyclelengths` and `ncycles`, the lengths of all cycles and the 
number of cycles. The index in the array is the length of the cycle. 
If the `ceiling` is reached (`ncycles = ceiling`), the output is only
a subset of the cycles lengths.

### References
- [Johnson](http://epubs.siam.org/doi/abs/10.1137/0204007)
"""
function simplecycleslength end
@traitfn function simplecycleslength(dg::::IsDirected, ceiling = 10^6)
    ncycles = 0
    cyclelength = zeros(Int, nv(dg))
    for cycle in Iterators.take(Channel(c -> itercycles(dg, c)), ceiling)
          cyclelength[length(cycle)] += 1
          ncycles += 1
    end
    return cyclelength, ncycles
end
