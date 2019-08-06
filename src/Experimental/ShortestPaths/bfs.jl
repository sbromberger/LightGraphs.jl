struct BFS <: ShortestPathAlgorithm end
struct BFSResults{U<:Integer} <: ShortestPathResults
    parents::Vector{U}
    dists::Vector{U}
end

function shortest_paths(
    g::AbstractGraph{U},
    ss::AbstractVector{U},
    alg::BFS,
    sort_alg= QuickSort
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
            @inbounds @simd for i in outneighbors(g, v)
                if !visited[i]
                    push!(next_level, i)
                    dists[i] = n_level
                    parents[i] = v
                    visited[i] = true
                end
            end
        end
        n_level += one(U)
        empty!(cur_level)
        cur_level, next_level = next_level, cur_level
        sort!(cur_level, alg=sort_alg)
    end
    return BFSResults(parents, dists)
end

shortest_paths(g::AbstractGraph{U}, ss::AbstractVector{<:Integer}, alg::BFS) where {U<:Integer} = shortest_paths(g, U.(ss), alg)
shortest_paths(g::AbstractGraph{U}, s::Integer, alg::BFS) where {U<:Integer} = shortest_paths(g, Vector{U}([s]), alg)
