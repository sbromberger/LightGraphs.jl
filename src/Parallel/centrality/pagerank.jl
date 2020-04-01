function pagerank(
    g::AbstractGraph{U},
    α=0.85,
    n=100::Integer,
    ϵ=1.0e-6
    ) where U <: Integer

    Base.depwarn("`pagerank` is deprecated. Equivalent functionality has been moved to `LightGraphs.Centrality.centrality`.", :pagerank)

    alg = LightGraphs.Centrality.ThreadedPageRank(α, n, ϵ)
    try
        LightGraphs.Centrality.centrality(g, alg)
    catch e
        if isa(e, LightGraphs.Centrality.ConvergenceError)
            error("Pagerank did not converge after $n iterations.")
        else
            throw(e)
        end
    end
end
