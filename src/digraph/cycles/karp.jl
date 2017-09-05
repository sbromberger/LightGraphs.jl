# Karp, R. M.
# A characterization of the minimum cycle mean in a digraph
# Discrete Mathematics, 1978, 23, 309 - 311
function _karp_minimum_cycle_mean(
    g::AbstractGraph,
    distmx::AbstractMatrix{T},
    component::Vector{U}
    ) where T where U<:Integer

    v2j = Dict{U, Int}()
    for (j, v) in enumerate(component)
        v2j[v] = j
    end
    n = length(component)
    F = Matrix{float(T)}(n+1, n)
    F[1, 1] = 0.
    for v in 2:length(component)
        F[1, v] = Inf
    end
    for i in 2:n+1
        for (j, v) in enumerate(component)
            F[i, j] = Inf
            for u in in_neighbors(g, v)
                k = get(v2j, u, 0)
                if !iszero(k)
                    F[i, j] = min(F[i, j], F[i-1, k] + distmx[u, v])
                end
            end
        end
    end

    # Extracting the cycle of minimal mean is not explained in Karp's paper.
    # Let
    # V* = argmin_v max_k (F_n(v) - F_k(v)) / (n - k)
    # Intuitively, one would think that it can be found by walking backward
    # using the F matrix starting from a vertex v ∈ V*.
    # However, it may not work as shown by the example in the tests.
    #
    # Fortunately, one can show that it works if we pick the v ∈ argmin_{v ∈ V*} F_n(v)
    # Indeed, suppose we walk backward and find v_0, ..., v_n=v.
    # Since there are n+1 nodes, there must be a cycle.
    # If the cycle is not of minimum cycle mean, then if we remove this cycle
    # and appends nodes of one of the cycle of minimum cycle mean containing v such that
    # the length is again n+1, we get a new walk of length n+1 ending at a node v' of the cycle.
    # Moreover, we know that v' ∈ V* and F_n(v') < F_n(v). Therefore if v minimizes F_n(v) among the nodes of V*, this cannot happen.

    # Find jbest ∈ V*
    λmin = Inf
    jbest = 0

    for j in 1:n
        λ = maximum(map(i -> (F[n+1, j] - F[i, j]) / (n+1 - i), 1:n))
        if λ < λmin || (isfinite(λ) && λ ≈ λmin && F[n+1, j] < F[n+1, jbest])
            λmin = λ
            jbest = j
        end
    end
    
    if iszero(jbest)
        return U[], Inf
    end

    # Backward walk from jbest
    walk = zeros(Int, n+1)
    walk[n+1] = jbest
    for i in n:-1:1
        v = component[walk[i+1]]
        dmin = Inf
        for u in in_neighbors(g, v)
            j = get(v2j, u, 0)
            if !iszero(j)
                dcur = F[i, j] + distmx[u, v]
                if dcur < dmin
                    walk[i] = j
                    dmin = dcur
                end
            end
        end
    end

    # Extract cycle in the walk
    invmap = zeros(Int, n)
    I = 1:0
    for i in n+1:-1:1
        if iszero(invmap[walk[i]])
            invmap[walk[i]] = i
        else
            I = i+1:invmap[walk[i]]
            break
        end
    end
    return component[walk[I]], λmin
end

"""
    karp_minimum_cycle_mean(g::::IsDirected, distmx::::AbstractMatrix{T}=weights(g))

Compute minimum cycle mean of the graph `g` with edge weights `distmx`.

### References
- [Karp](http://dx.doi.org/10.1016/0012-365X(78)90011-0).
"""
function karp_minimum_cycle_mean end
#@traitfn function karp_minimum_cycle_mean(
#    g::::IsDirected,
#    distmx::::AbstractMatrix = weights(g)
#    )
function karp_minimum_cycle_mean(g, distmx)
    cycle = Int[]
    λmin = Inf
    for component in strongly_connected_components(g)
        c, λ = _karp_minimum_cycle_mean(g, distmx, component)
        if λ < λmin
            cycle = c
            λmin = λ
        end
    end
    cycle, λmin
end
