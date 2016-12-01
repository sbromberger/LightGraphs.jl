import Base: start, next, done

using LightGraphs
include("digraph-cyclicity.jl")
#=
## New implementation.
immutable CircuitState
    s::Int
    t::Int
end

function CircuitState(st::Tuple{Int,Int})
    return CircuitState(st[1], st[2])
end

type Circuits
    dg::DiGraph
    v::Int
    vis::JohnsonVisitor
    vmap::Vector{Int}
    startnode::Int
    done::Bool
end

function Circuits(dg::DiGraph)
    return Circuits(dg, 1, JohnsonVisitor(dg), zeros(Int, nv(dg)), 1, false)
end


function start(cr::Circuits)
    cr.done = false
    push!(cr.vis.stack, cr.v)
    cr.vis.blocked[cr.v] = true
    return 1
end

function next(cr::Circuits, state::Int)
    v = state
    for w in fadj(cr.dg,v)
        if w == cr.startnode
            cr.done = true
            return cr.vmap[cr.vis.stack], v
        elseif !cr.vis.blocked[w]
            cir, newstate = next(cr, w)
            cr.done = true
            return cir, newstate
        end
    end
    if cr.done
        unblock!(v, cr.vis.blocked, cr.vis.blockedmap)
    else
        for w in fadj(cr.dg, v)
            if !in(cr.vis.blockedmap[w], v)
                push!(cr.vis.blockedmap[w], v)
            end
        end
    end
    pop!(cr.vis.stack)
    return Int[], fadj(cr.dg, v)[1]
end

function done(cr::Circuits, state::Int)
    return cr.done && state == nv(cr.dg)
end

"""
```itercycles(dg::DiGraph)```

Compute all cycles of the given directed graph, using
[Johnson's algorithm](http://epubs.siam.org/doi/abs/10.1137/0204007).

Iterative version of the algorithm, using Tasks to stop the exploration
after a given number of cycles.

# Arguments:
* `dg`: the directed graph we want to explore
"""
function itcycles(dg::DiGraph)
    sccs = strongly_connected_components(dg)
    for scc in sccs
        while length(scc) > 1
            wdg, vmap = induced_subgraph(dg, scc)
            #startnode = 1
            shift!(scc)
            visitor = JohnsonVisitor(wdg)
            circuit(1, wdg, visitor, vmap)
        end
    end
end

function testcycles(dg::DiGraph, ceiling = 10^6)
    t = itcycles(dg)
    return collect(take(t, ceiling))
end

type Circuits
    dg::DiGraph
end



type CircuitsIterState
    wdg::DiGraph
    v::Int
    vis::JohnsonVisitor
    vmap::Vector{Int}
    startnode::Int
    done::Bool
    sccs::Vector{Vector{Int}}
    scc::Vector{Int} 
    w::Int
    neighbors::Vector{Int}
end



function start(cr::Circuits) ## Problem if acyclic digraph
    sccs = strongly_connected_components(cr.dg)
    scc = pop!(sccs)
    while length(scc) == 1
        scc = pop!(sccs)
    end
    wdg, vmap = induced_subgraph(cr.dg, scc)
    neighbors = fadj(wdg, 1)
    w = pop!(neighbors)
    state = CircuitsIterState(wdg, 1, JohnsonVisitor(wdg), vmap, 1, false, sccs, scc, w, neighbors)    
    state.vis.blocked[1] = true
    return state
end
    
    
    
function next(cr::Circuits, state::CircuitsIterState)    
    if state.w == state.startnode
        state.done = true
        cycle = state.vmap[state.vis.stack]
        return state.vmap[state.vis.stack], state
        elseif !state.vis.blocked[state.w]
        state.v = state.w
        cir, newstate = next(cr, state)
        state.done = newstate.done
    end
    if state.done
        unblock!(state.v, state.vis.blocked, state.vis.blockedmap)
    else
        for w in fadj(state.wdg, state.v)
            if !in(state.vis.blockedmap[w], state.v)
                push!(state.vis.blockedmap[w], state.v)
            end
        end
    end
    if(length(state.scc) == 1)
        state.scc = pop!(state.sccs)
        state.wdg, state.vmap = induced_subgraph(cr.dg, scc)
        state.v = 1
        state.neighbors = fadj(state.wdg, state.v)
        state.w = pop!(state.neighbors)
    else
        state.v = pop!(scc)
        state.neighbors = 
    end
    if state.done
        
        pop!(state.vis.stack)
        return cycle, state
    else
        return Int[], state
    end
end

function done(cr::Circuits, state::CircuitsIterState)
    isempty(state.sccs)
end

type Circuits
    dg::DiGraph
end

function Circuits(dg::DiGraph)
    return dg
end

type CircuitsIterState
    dg::DiGraph
    sccs::Vector{Vector{Int}}
    scc::Vector{Int}
    subdg::DiGraph
    vmap::Vector{Int}
    startnode::Int
    currentnode::Int
    stack::Vector{Int}
    #neighbors::Vector{Int}
    #neighbor::Int
    blocked::Vector{Bool}
    blockedmap::Vector{Set{Int}}
    done::Bool
end

function CircuitsIterState(cr::Circuits)
    return (cr.dg, Vector(Int[]), Int[], cr.dg, Int[], 1, 1, Int[], Int[], [Set{Int}()], false)
end


function done(cr::Circuits, state::CircuitsIterState)
    return isempty(state.sccs) & (length(state.scc) == 1)
end

function start(cr::Circuits)
    sccs = strongly_connected_components(cr.dg)
    scc = pop!(sccs)
    while !isempty(sccs) & (length(scc) == 1)
        scc = pop!(sccs)        
    end
    if isempty(sccs) & length(scc) == 1
        state = CircuitsIterState(cr.dg, sccs, scc, cr.dg, Int[], 1, 1, Int[], falses(1), [Set{Int}(0)], false)
        return state
    end
    subdg, vmap = induced_subgraph(cr.dg, scc)
    startnode = 1
    currentnode = startnode
    #neighbors = fadj(subdg, currentnode)
    #neighbor = 1
    blocked = falses(vertices(subdg))
    blockedmap = [Set{Int}() for v in vertices(subdg)]
    stack = [currentnode]
    blocked[currentnode] = true
    state = CircuitsIterState(cr.dg, sccs, scc, subdg, vmap, startnode, currentnode, stack, blocked, blockedmap, false)
    return state
end

function next(cr::Circuits, state::CircuitsIterState)
    cycle = Vector{Int}()
    state.done = false
    push!(state.stack, state.currentnode)
    state.blocked[state.currentnode] = true
    for w in fadj(state.subdg, state.currentnode)
        if w == state.startnode
            state.done = true
            cycle = state.vmap[state.stack]
            unblock!(state.currentnode, state.blocked, state.blockedmap)
            pop!(state.stack)
        elseif !state.blocked[w]
            if !in(state.blockedmap[w], state.currentnode)
                push!(state.blockedmap[w], state.currentnode)
            end
            state.currentnode = w
            #next(cr, state)
        else
            if !in(state.blockedmap[w], state.currentnode)
                push!(state.blockedmap[w], state.currentnode)
            end
            pop!(state.stack)
            #next(cr, state)
        end
    end
    if state.done
        return cycle, state
        elseif (length(state.scc) > 1)
        state.currentnode = pop!(state.scc)
        #next(cr, state)
        elseif  !isempty(sccs)      
        state.scc = pop!(state.sccs)
        while length(state.scc) == 1
            state.scc = pop!(state.sccs)
        end
        state.subdg, state.vmap = induced_subgraph(state.dg, scc)
        #next(cr, state)
    end
    return cycle, state
end

type Circuits
    dg::DiGraph
end

type CircuitState
    dg::DiGraph
    sccs::Vector{Vector{Int}}
    scc::Vector{Int}
    subdg::DiGraph
    vmap::Vector{Int}
    startnode::Int
    blocked::Vector{Bool}
    neighbors::Vector{Int}
    currentnode::Int
    stack::Vector{Int}
end

function start(cr::Circuits)
    sccs = strongly_connected_components(cr.dg)
    scc = pop!(sccs)
    while length(scc) < 2
        scc = pop!(sccs)
    end
    wdg, vmap = induced_subgraph(cr.dg, scc)
    startnode = pop!(scc)
    blocked = falses(vertices(subdg))
    neighbors = fadj(subdg, startnode)
    currentnode = startnode
    blocked[currentnode] = true
    stack = [currentnode]
    state = CircuitState(cr.dg, sccs, scc, wdg, vmap, startnode, blocked, neighbors, currentnode, stack)
    return state
end

function next(cr::Circuits, state::CircuitState)
    if !isempty(state.neighbors)
        state.currentnode = pop!(state.neighbors)
        push!(state.stack, state.currentnode)
        state.blocked[state.currentnode] = true
        else
    end
        
    return state.neighbor, state
end

function done(cr::Circuits, state::CircuitState)
    isempty(state.sccs)
end


"""
```unblock!(v::T, blocked::Vector{Bool}, B::Vector{Set{Int}})```

Unblock the vertices recursively.

# Arguments
* `v`: the vertex to unblock
* `blocked`: tell whether a vertex is blocked or not
* `B`: the map that tells if the unblocking of one vertex should unblock other vertices
"""
function unblock!(v::Int, blocked::Vector{Bool}, B::Vector{Set{Int}})
    blocked[v] = false
    for w in B[v]
        delete!(B[v], w)
        if blocked[w]
            unblock!(w, blocked, B)
        end
    end
end

"""
```circuit(v::Int, dg::DiGraph, vis::JohnsonVisitor,
allcycles::Vector{Vector{Int}}, vmap:: Vector{Int}, startnode = v)```

One step of the recursive version of simple cycle detection, using a DFS algorithm.

The CIRCUIT function from [Johnson's algorithm](http://epubs.siam.org/doi/abs/10.1137/0204007),
recursive version. Modify the vector of cycles, when needed.

# Arguments
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

# Returns
* `done`: tells whether a circuit has been found in the current exploration.
"""
function circuit(v::Int, dg::DiGraph, vis::JohnsonVisitor, allcycles::Vector{Vector{Int}}, vmap::Vector{Int}, startnode = v)
    done = false
    push!(vis.stack, v)
    vis.blocked[v] = true
    for w in fadj(dg,v)
        if w == startnode
            push!(allcycles, vmap[vis.stack])
            done = true
        elseif !vis.blocked[w]
            circuit(w, dg, vis, allcycles, vmap, startnode) && (done = true)
        end
    end
    if done
        unblock!(v, vis.blocked, vis.blockedmap)
    else
        for w in fadj(dg, v)
            if !in(vis.blockedmap[w], v)
                push!(vis.blockedmap[w], v)
            end
        end
    end
    pop!(vis.stack)
    return done
end


"""
```simplecycles(dg::DiGraph)```

Compute all cycles of the given directed graph, using
[Johnson's algorithm](http://epubs.siam.org/doi/abs/10.1137/0204007).

/!\ The number of cycles grow more than exponentially with the number of vertices,
you might want to use the algorithm with a ceiling -- `getcycles` -- on large directed graphs
(slightly slower). If you want to have an idea of the possible number of cycles,
look at function ```maxcycles(dg::DiGraph, byscc::Bool = true)```.

# Arguments
* `dg`: the directed graph

# Returns
* `cycles`: all the cycles of the directed graph
"""
function simplecycles(dg::DiGraph)
    sccs = strongly_connected_components(dg)
    cycles = Vector{Vector{Int}}()
    for scc in sccs
        for i in 1:(length(scc)-1)
            wdg, vmap = induced_subgraph(dg, scc[i:end])
            #startnode = 1
            #shift!(scc)
            visitor = JohnsonVisitor(wdg)
            circuit(1, wdg, visitor, cycles, vmap)
        end
    end
    return cycles
end
=#

type Circuits
    dg::Digraph
end

type CircuitsState
    currentvertex::Int
    stack::Vector{Int}
    blocked::Vector{Bool}
    blockedmap::Vector{Set{Int}}
    vmap::Vector{Int}
    startvertex::Int
    done::Bool
end

function Circuits(dg::DiGraph)
    return Circuits(dg, 1, [1], falses(vertices(dg)), [], zeros(Int, nv(dg)), 1, false)
end


function start(cr::Circuits)
    
    return 1
end

function next(cr::Circuits, state::Tuple{Int, Int})
    sccs = strongly_connected_components(cr.dg)
    scc = pop!(sccs)
    v, w = state[1], state[2]
    for w in fadj(dg,v)
        if w == startnode
            cr.done = true
            return vmap[vis.stack], state
        elseif !cr.vis.blocked[w]
            cir, newstate = next(cr, (w, startnode))
            cr.done = true
            return cir, newstate
        end
    end
    if cr.done
        unblock!(v, cr.vis.blocked, cr.vis.blockedmap)
    else
        for w in fadj(dg, v)
            if !in(cr.vis.blockedmap[w], v)
                push!(cr.vis.blockedmap[w], v)
            end
        end
    end
    pop!(cr.vis.stack)
    return Int[], 0
end

function done(cr::Circuits, state::Tuple{Int,Int})
    return cr.done && state[2] == nv(cr.dg)
end

type Circuits
    dg::Digraph
end

type CircuitsState
    sccs::Vector{Vector{Int}}
    currentvertex::Int
    stack::Vector{Int}
    blocked::Vector{Bool}
    blockedmap::Vector{Set{Int}}
    vmap::Vector{Int}
    startvertex::Int
    done::Bool
end

function Circuits(dg::DiGraph)
    return Circuits(dg, 1, [1], falses(vertices(dg)), [], zeros(Int, nv(dg)), 1, false)
end


function start(cr::Circuits)
    sccs = strongly_connected_components(cr.dg)
    return 1
end

function next(cir::Circuits, state::CircuitsState)
    while !isempty(state.sccs)
        state.scc=pop!(state.sccs)
        # order of scc determines ordering of nodes
        wdg, vmap = induced_subgraph(

        state.startnode = pop!(state.scc)
        # Processing node runs "circuit" routine from recursive version
        path=[state.startnode]
        state.blocked = falses(vertices(wdg)) # vertex: blocked from search?
        state.blockedmap =  # nodes involved in a cycle
        blocked.add(startnode)
        B=defaultdict(set) # graph portions that yield no elementary circuit
        stack=[ (startnode,list(subG[startnode])) ]  # subG gives component nbrs
        while stack:
            thisnode,nbrs = stack[-1]
            if nbrs:
                nextnode = nbrs.pop()
#                    print thisnode,nbrs,":",nextnode,blocked,B,path,stack,startnode
#                    f=raw_input("pause")
                if nextnode == startnode:
                    yield path[:]
                    closed.update(path)
#                        print "Found a cycle",path,closed
                elif nextnode not in blocked:
                    path.append(nextnode)
                    stack.append( (nextnode,list(subG[nextnode])) )
                    closed.discard(nextnode)
                    blocked.add(nextnode)
                    continue
            # done with nextnode... look for more neighbors
            if not nbrs:  # no more nbrs
                if thisnode in closed:
                    _unblock(thisnode,blocked,B)
                else:
                    for nbr in subG[thisnode]:
                        if thisnode not in B[nbr]:
                            B[nbr].add(thisnode)
                stack.pop()
#                assert path[-1]==thisnode
                path.pop()
        # done processing this node
        subG.remove_node(startnode)
        H=subG.subgraph(scc)  # make smaller to avoid work in SCC routine
        sccs.extend(list(nx.strongly_connected_components(H)))
