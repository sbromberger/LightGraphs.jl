"""
    struct ThreadedPageRank <: CentralityMeasure
        α::Float64
        n::Integer
        ϵ::Float64
    end

A structure representing a threaded algorithm to calculate the [PageRank](https://en.wikipedia.org/wiki/PageRank) of the
graph `g` parameterized by damping factor `α`, number of iterations 
`n`, and convergence threshold `ϵ`. 

### Optional Arguments
- `α::Float64=0.85`: the damping factor
- `n::Integer=100`: the number of iterations to run
- `ϵ::Float64=1.0e-6`: the convergence threshold above which a [`ConvergenceError`](@ref) is thrown.
"""
struct ThreadedPageRank <: CentralityMeasure
    α::Float64
    n::Integer
    ϵ::Float64
end

ThreadedPageRank(; α=0.85, n=100, ϵ=1.0e-6) = ThreadedPageRank(α, n, ϵ)

function centrality(
    g::AbstractGraph{U},
    alg::ThreadedPageRank
    ) where U <: Integer

    # indegree(g, v) is estimated run-time to iterate over inneighbors(g, v)
    partitions = LightGraphs.optimal_contiguous_partition(indegree(g), nthreads(), nv(g))

    α_div_outdegree = Vector{Float64}(undef,nv(g))
    dangling_nodes = Vector{U}()
    @inbounds for v in vertices(g)
        if outdegree(g, v) == 0
            push!(dangling_nodes, v)
        end
        α_div_outdegree[v] = (alg.α/outdegree(g, v))
    end

    nvg = Int(nv(g))
    # solution vector and temporary vector
    x = fill(1.0 / nvg, nvg)
    xlast = copy(x)
    @inbounds for _ in 1:alg.n
        dangling_sum = 0.0
        for v in dangling_nodes
            dangling_sum += x[v]
        end
        # flow from teleprotation
        y = (1 - alg.α + alg.α * dangling_sum) * (1.0 / nvg)
        xlast .= y
        # flow from edges
        let x = x
            @threads for v_set in partitions
                for v in v_set
                    for u in inneighbors(g, v)
                        xlast[v] += (x[u] * α_div_outdegree[u])
                    end
                end
            end
        end

        # l1 change in solution convergence criterion
        err = 0.0
        for v in vertices(g)
            err += abs(xlast[v] - x[v])
            x[v] = xlast[v]
        end
        if (err < nvg * alg.ϵ)
            return x
        end
    end
    throw(ConvergenceError("Pagerank did not converge after $(alg.n) iterations."))
end
