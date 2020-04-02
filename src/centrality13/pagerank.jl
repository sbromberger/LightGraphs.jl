@traitfn function pagerank(
        g::G,
        α=0.85,
        n::Integer=100,
        ϵ=1.0e-6
    ) where {U <: Integer, G <: AbstractGraph{U}; HasContiguousVertices{G}}

    Base.depwarn("`pagerank` is deprecated. Equivalent functionality has been moved to `LightGraphs.ShortestPaths.centrality`.", :pagerank)
    alg = LightGraphs.Centrality.PageRank(α=α, n=n, ϵ=ϵ)
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
