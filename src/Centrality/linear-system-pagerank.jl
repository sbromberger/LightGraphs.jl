import LinearAlgebra: norm

"""
    struct LinearSystemPageRank <: CentralityMeasure
        α::Float64
        n::Integer
        ϵ::Float64
    end

A structure representing an algorithm to calculate the [PageRank](https://en.wikipedia.org/wiki/PageRank) of the
graph `g` parameterized by damping factor `α`, number of iterations
`n`, and convergence threshold `ϵ`. The PageRank is computed as a sparse linear system.

### Optional Arguments
- `α::Float64=0.85`: the damping factor
- `n::Integer=100`: the number of iterations to run
- `ϵ::Float64=1.0e-6`: the convergence threshold above which a [`ConvergenceError`](@ref) is thrown.
"""
struct LinearSystemPageRank <: CentralityMeasure
    α::Float64
    n::Integer
    ϵ::Float64
end
LinearSystemPageRank(;α=0.85, n=100, ϵ=1.0e-6) = LinearSystemPageRank(α, n, ϵ)

function centrality(g::AbstractGraph{U},  alg::LinearSystemPageRank) where {U<:Integer}
    dangling_nodes = Vector{U}()
    for v in vertices(g)
        if (outdegree(g, v) == 0)
            push!(dangling_nodes, v)
        end
    end
    N = Int(nv(g))
    # non-normalized solution vector
    y = fill(1.0 / N, N)
    for _ in 1:alg.n
        err = 0.0
        for i in vertices(g)
            s = 0.0
            self_loop = false
            for j in inneighbors(g, i)
                if (j != i)
                    s += y[j] / outdegree(g, j)
                else
                    self_loop = true
                end
            end
            y_new = 1 + (alg.α * s)
            if (self_loop)
                y_new /= 1 - (alg.α / outdegree(g, i))
            end
            # Computes the L1 norm of the difference between successive
            # iterations without explicitly store the previous iteration.
            err += abs(y_new - y[i])
            y[i] = y_new
        end
        # The condition number of the sparse matrix is less than or equal to
        # ((1 + alg.α) / (1 - alg.α)) so we can use it as a threshold
        if (err < ((1 + alg.α) / (1 - alg.α)) * alg.ϵ)
            return y / norm(y, 1)
        end
    end
    throw(ConvergenceError("Pagerank did not converge after $(alg.n) iterations."))
end
