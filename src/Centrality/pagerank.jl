# Parts of this code were taken / derived from NetworkX. See LICENSE for
# licensing details.

"""
    struct PageRank <: CentralityMeasure
        α::Float64
        n::Integer
        ϵ::Float64
    end

A structure representing an algorithm to calculate the [PageRank](https://en.wikipedia.org/wiki/PageRank) of the
graph `g` parameterized by damping factor `α`, number of iterations 
`n`, and convergence threshold `ϵ`. 

### Optional Arguments
- `α::Float64=0.85`: the damping factor
- `n::Integer=100`: the number of iterations to run
- `ϵ::Float64=1.0e-6`: the convergence threshold above which a [`ConvergenceError`](@ref) is thrown.
"""
struct PageRank <: CentralityMeasure
    α::Float64
    n::Integer
    ϵ::Float64
end
PageRank(;α=0.85, n=100, ϵ=1.0e-6) = PageRank(α, n, ϵ)

function centrality(g::AbstractGraph{U},  alg::PageRank) where {U<:Integer}
    α_div_outdegree = Vector{Float64}(undef,nv(g))
    dangling_nodes = Vector{U}()
    for v in vertices(g)
        if outdegree(g, v) == 0
            push!(dangling_nodes, v)
        end
        α_div_outdegree[v] = (alg.α/outdegree(g, v))
    end
    N = Int(nv(g))
    # solution vector and temporary vector
    x = fill(1.0 / N, N)
    xlast = copy(x)
    for _ in 1:alg.n
        dangling_sum = 0.0
        for v in dangling_nodes
            dangling_sum += x[v]
        end
        # flow from teleprotation
        for v in vertices(g)
            xlast[v] = (1 - alg.α + alg.α * dangling_sum) * (1.0 / N)
        end
        # flow from edges
        
        for v in vertices(g)
            for u in inneighbors(g, v)
                xlast[v] += (x[u] * α_div_outdegree[u])
            end
        end
        # l1 change in solution convergence criterion
        err = 0.0
        for v in vertices(g)
            err += abs(xlast[v] - x[v])
            x[v] = xlast[v]
        end
        if (err < N * alg.ϵ)
            return x
        end
    end
    throw(ConvergenceError("Pagerank did not converge after $(alg.n) iterations."))
end
