"""
    struct JonesPlassmann <: ThreadedColoringAlgorithm

A struct representing a [`ThreadedColoringAlgorithm`](@ref).

### Optional Arguments
- `rng::AbstractRNG`: a random number generator (default `Random.GLOBAL_RNG`)

### References
- [A Comparison of Parallel Graph Coloring Algorithms](http://www.new-npac.org/users/fox/pdftotal/sccs-0666.pdf)
"""
struct JonesPlassmann{R<:AbstractRNG} <: ThreadedColoringAlgorithm
    rng::R
end
JonesPlassmann(;rng=GLOBAL_RNG) = JonesPlassmann(rng)

function color(g::AbstractGraph{T}, alg::JonesPlassmann) where {T <: Integer}
    nvg = nv(g)
    V = collect(vertices(g))
    V_new = Vector{T}()
    indset = Vector{T}(undef, nvg)
    i = Atomic{Int64}(1)
    wts = shuffle(alg.rng, vertices(g))
    C = zeros(T, nvg)
    S = [IntSet() for _ in 1:nthreads()]

    while !isempty(V)
        i[] = 1
        @threads for u in V
            flag = true
            for v in neighbors(g, u)
                if C[v] == 0 && wts[v] > wts[u]
                    flag = false
                    break
                end
            end
            if flag
                j = atomic_add!(i, 1)
                indset[j] = u
            end
        end
        indset_sz = i[]-1
        @threads for k in 1:indset_sz
            mincolor = 1
            u = indset[k]
            St = S[threadid()]
            for v in neighbors(g, u)
                if C[v] != 0
                    push!(St, C[v])
                end
            end
            for c in St
                c != mincolor && break
                mincolor += 1
            end
            C[u] = mincolor
            empty!(St)
        end
        for u in V
            if C[u] == 0
                push!(V_new, u)
            end
        end
        empty!(V)
        V, V_new = V_new, V
    end
    return GraphColoring(maximum(C), C)
end
