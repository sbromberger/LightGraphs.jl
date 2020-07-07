"""
    struct LubyMaximalIndSet <: VertexSubset

Struct representing a multithreaded algorithm to calculate the maximal [independent set](https://en.wikipedia.org/wiki/Maximal_independent_set)
of a graph.

### Optional Arguments
- `rng<:AbstractRNG`: override default random number generator (`GLOBAL_RNG`).

### References
- [Luby's Algorithm](http://people.disim.univaq.it/guido.proietti/slide_algdist2015/Luby%27s%20Algorithm.pdf)
"""
struct LubyMaximalIndSet{R<:AbstractRNG} <: VertexSubset
    rng::R
end
LubyMaximalIndSet(;rng=GLOBAL_RNG) = LubyMaximalIndSet(rng)

function independent_set(g::AbstractGraph{T}, alg::LubyMaximalIndSet) where T <: Integer
    nvg = nv(g)
    nthrds = nthreads()
    deg = degree(g)
    V = filter(u -> !has_edge(g, u, u), vertices(g))    # vertex set
    inV = ones(Bool, nvg)         # used to mark vertices present in vertex set
    deleted = [has_edge(g, u, u) for u in vertices(g)]  # used to mark vertices deleted from vertex set
    V_new = Vector{T}()           # temp array for storing new vertex set for next iteration
    ind_set = Vector{T}()         # independent set
    in_ind_set = zeros(Bool, nvg) # used to mark vertices present in independent set
    sizehint!(ind_set, nvg)
    S = Vector{T}()

    while !isempty(V)
        # mark vertices to be included in ind_set with probability 1/(2*degree)
        for u in V
            if deg[u] == 0 || (rand(alg.rng) <= 1.0/(2*deg[u]))
                in_ind_set[u] = true
                push!(S, u)
            end
        end
        partitions = greedy_contiguous_partition(map(u -> degree(g, u), S), nthrds)
        # resolve conflicts in chosen vertices. if any of the chosen vertices
        # are neighbors, then unmark the vertex with lower degree
        @threads for i_set in partitions
            for i in i_set
                u = S[i]
                for v in neighbors(g, u)
                    deleted[v] && continue
                    if in_ind_set[v]
                        if deg[v] < deg[u] || (deg[v] == deg[u] && v < u)
                            in_ind_set[v] = false
                        else
                            in_ind_set[u] = false
                            break
                        end
                    end
                end
            end
        end
        empty!(S)
        for u in V
            if in_ind_set[u]
                push!(S, u)
            end
        end
        partitions = greedy_contiguous_partition(map(u -> degree(g, u), S), nthrds)
        @threads for i_set in partitions
            for i in i_set
                u = S[i]
                deleted[u] = true
                for v in neighbors(g, u)
                    deleted[v] = true
                end
            end
        end
        # create new vertex set with vertices that are not marked deleted
        for u in V
            if !deleted[u]
                push!(V_new, u)
            end
        end
        partitions = greedy_contiguous_partition(map(u -> degree(g, u), V_new), nthrds)
        # update degrees of vertices in new vertex set
        @threads for i_set in partitions
            for i in i_set
                u = V_new[i]
                for v in neighbors(g, u)
                    # check if neighbor was in the vertex set and now deleted
                    if inV[v] && deleted[v]
                        deg[u] -= 1
                    end
                end
            end
        end
        # update inV for next iteration
        @threads for u in V
            if deleted[u]
                inV[u] = false
            end
        end
        append!(ind_set, S)
        empty!(V)
        V, V_new = V_new, V
        empty!(S)
    end

    return ind_set
end
