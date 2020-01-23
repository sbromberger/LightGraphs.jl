@inline function nop(x...) end

abstract type AbstractTraversalState end

struct DefaultTraversalState <: AbstractTraversalState end

function bfs_visit(
    g::AbstractGraph{U},
    ss::AbstractVector{U},
    previsitfn::Function = nop,
    newvisitfn::Function = nop,
    visitfn::Function = nop,
    postvisitfn::Function = nop,
    state::AbstractTraversalState=DefaultTraversalState(),
    ) where U<:Integer


    n = nv(g)
    dists = fill(typemax(U), n)
    parents = zeros(U, n)
    visited = falses(n)
    n_level = one(U)
    cur_level = Vector{U}()
    sizehint!(cur_level, n)
    next_level = Vector{U}()
    sizehint!(next_level, n)
    @inbounds for s in ss
        dists[s] = zero(U)
        visited[s] = true
        push!(cur_level, s)
    end
    while !isempty(cur_level)
        @inbounds for v in cur_level
            previsitfn(v)
            @inbounds @simd for i in outneighbors(g, v)
                if !visited[i]
                    newvisitfn(v, i)
                    push!(next_level, i)
                    dists[i] = n_level
                    parents[i] = v
                    visited[i] = true
                end
                visitfn(v, i)
            end
            postvisitfn(v)
        end
        n_level += one(U)
        empty!(cur_level)
        cur_level, next_level = next_level, cur_level
        sort!(cur_level, alg=BFS().sort_alg)
    end
    return BFSResult(parents, dists)
end

