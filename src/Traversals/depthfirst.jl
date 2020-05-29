import Base.showerror
struct CycleError <: Exception end
Base.showerror(io::IO, e::CycleError) = print(io, "Cycles are not allowed in this function.")

"""
    DepthFirst{F <: Function} <: TraversalAlgorithm

Struct representing the DFS traversal algorithm.

### Optional Arguments
- `neighborfn::Function`: the function to use to compute the neighbors of a vertex (default [`outneighbors`](@ref)).

### Visitor Function Usage
- `preinitfn!`: continue with normal execution if `VSUCCESS`, otherwise terminate
- `initfn!`: continue with normal execution if `VSUCCESS`, otherwise terminate
- `previsitfn!`: continue with normal execution if `VSUCCESS`, otherwise terminate
- `visitfn!`: this function is called for every neighbor (irrespective of whether it is already
              visited or not) of the vertex being explored
              if `VTERMINATE`: terminate
              if `VSKIP`: skip neighbor
              if `VFAIL`: stop exploring neighbors 
              if `VSUCCESS`: continue with normal execution
- `newvisitfn!`: same as `visitfn!` but for newly discovered neighbors
- `revisitfn!`: same as `visitfn!` but for re-discovered neighbors
- `postvisitfn!`: continue with normal execution if `VSUCCESS`, otherwise terminate
- `postlevelfn!`: continue with normal execution if `VSUCCESS`, otherwise terminate
"""
struct DepthFirst{F<:Function} <: TraversalAlgorithm
    neighborfn::F
end

DepthFirst(;neighborfn=outneighbors) = DepthFirst(neighborfn)

function traverse_graph!(
    g::AbstractGraph{U},
    ss,
    alg::DepthFirst,
    state::TraversalState,
    ) where U<:Integer

    n = nv(g)
    visited = falses(n)
    S = Vector{Tuple{U, U}}()
    sizehint!(S, length(ss))
    is_successful(preinitfn!(state, visited)) || return false

    @inbounds for s in ss
        us = U(s)
        visited[us] && continue

        visited[us] = true
        push!(S, (us, 1))
        is_successful(initfn!(state, us)) || return false
        ptr = one(U)

        while !isempty(S)
            v, _ = S[end]
            is_successful(previsitfn!(state, v)) || return false
            neighs=alg.neighborfn(g, v)
            @inbounds while ptr <= length(neighs)
                i = neighs[ptr]
                x = visitfn!(state, v, i)
                x ==  VTERMINATE && return false # terminate dfs
                if x == VSKIP # skip this neighbor
                    ptr += 1
                    continue
                end
                if x == VFAIL # stop exploring all neighbors
                    ptr = length(neighs)+1
                    break
                end
                if !visited[i]  # find the first unvisited neighbor
                    # newvisitfn! return values have same effect as visitfn! but only for
                    # newly discovered vertices
                    x = newvisitfn!(state, v, i)
                    x ==  VTERMINATE && return false
                    if x == VSKIP
                        ptr += 1
                        continue
                    end
                    if x == VFAIL
                        ptr = length(neighs)+1
                        break
                    end
                    visited[i] = true
                    push!(S, (i, ptr+1))
                    break
                else
                    # revisitfn! return values have same effect as visitfn! but only for
                    # rediscovered vertices
                    x = revisitfn!(state, v, i)
                    x ==  VTERMINATE && return false
                    if x == VSKIP
                        ptr += 1
                        continue
                    end
                    if x == VFAIL
                        ptr = length(neighs)+1
                        break
                    end
                end
                ptr += 1
            end
            is_successful(postvisitfn!(state, v)) || return false
            # if ptr > length(neighs) then we have finished all children of the node,
            # and the next time we pop from the stack we will be in the parent of the current
            # node. We would like to continue from where we stoped, otherwise we have found
            # a new unvisited child, so we will make ptr = 1
            if ptr > length(neighs)
                is_successful(postlevelfn!(state)) || return false
                _, ptr =pop!(S)
            else
                ptr = 1 # we will enter new node
            end
        end
    end
    return true
end

mutable struct TopoSortState{T<:Integer} <: TraversalState
    vcolor::Vector{UInt8}
    verts::Vector{T}
    w::T
end

# 1 = visited
# 2 = vcolor 2
# @inline initfn!(s::TopoSortState{T}, u) where T = s.vcolor[u] = one(T)
function previsitfn!(s::TopoSortState{T}, u) where T
    s.w = 0
    return VSUCCESS
end
function visitfn!(s::TopoSortState{T}, u, v) where T
    s.vcolor[v] != one(T) && return VSUCCESS
    return VTERMINATE
end
function newvisitfn!(s::TopoSortState{T}, u, v) where T
    s.w = v
    return VSUCCESS
end
function postvisitfn!(s::TopoSortState{T}, u) where T
    if s.w != 0
        s.vcolor[s.w] = one(T)
    else
        s.vcolor[u] = T(2)
        push!(s.verts, u)
    end
    return VSUCCESS
end


"""
    topological_sort(g, alg=DepthFirst())

Return a [topological sort](https://en.wikipedia.org/wiki/Topological_sorting) of a directed graph `g`
using [`TraversalAlgorithm`](@ref) `alg` as a vector of vertices in topological order.
"""
function topological_sort end

@traitfn function topological_sort(g::AG::IsDirected, alg::TraversalAlgorithm=DepthFirst()) where {T, AG<:AbstractGraph{T}}
    vcolor = zeros(UInt8, nv(g))
    verts = Vector{T}()
    state = TopoSortState(vcolor, verts, zero(T))
    sources = filter(x -> indegree(g, x) == 0, vertices(g))

    traverse_graph!(g, sources, DepthFirst(), state) || throw(CycleError())

    length(state.verts) < nv(g) && throw(CycleError())
    length(state.verts) > nv(g) && throw(TraversalError())
    return reverse!(state.verts)
end

mutable struct CycleState{T<:Integer} <: TraversalState
    vcolor::Vector{UInt8}
    w::T
end

function previsitfn!(s::CycleState{T}, u) where T
    s.w = 0
    return VSUCCESS
end
function visitfn!(s::CycleState{T}, u, v) where T
    s.vcolor[v] != one(T) && return VSUCCESS
    return VTERMINATE
end
function newvisitfn!(s::CycleState{T}, u, v) where T
    s.w = v
    return VSUCCESS
end
function postvisitfn!(s::CycleState{T}, u) where T
    if s.w != 0
        s.vcolor[s.w] = one(T)
    else
        s.vcolor[u] = T(2)
    end
    return VSUCCESS
end

@traitfn function is_cyclic(g::AG::IsDirected, alg::TraversalAlgorithm=DepthFirst()) where {T, AG<:AbstractGraph{T}}
    vcolor = zeros(UInt8, nv(g))
    state = CycleState(vcolor, zero(T))
    @inbounds for v in vertices(g)
        state.vcolor[v] != 0 && continue
        state.vcolor[v] = 1
        !traverse_graph!(g, v, alg, state) && return true
    end
    return false
end

@traitfn is_cyclic(g::::(!IsDirected), alg::TraversalAlgorithm=DepthFirst()) = ne(g) > 0
