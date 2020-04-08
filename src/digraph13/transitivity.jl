function transitiveclosure! end
@traitfn function transitiveclosure!(g::::IsDirected, selflooped=false)
    Base.depwarn("`transitiveclosure!` is deprecated. Equivalent functionality has been moved to `LightGraphs.Transitivity.transitive_closure!`.", :transitiveclosure!)
    LightGraphs.Transitivity.transitive_closure!(g, selflooped)
end

function transitiveclosure(g::DiGraph, selflooped=false)
    Base.depwarn("`transitiveclosure` is deprecated. Equivalent functionality has been moved to `LightGraphs.Transitivity.transitive_closure`.", :transitiveclosure)
    LightGraphs.Transitivity.transitive_closure(g, selflooped)
end

@traitfn function transitivereduction(g::::IsDirected; selflooped::Bool=false)
    Base.depwarn("`transitivereduction` is deprecated. Equivalent functionality has been moved to `LightGraphs.Transitivity.transitive_reduction`.", :transitivereduction)
    LightGraphs.Transitivity.transitive_reduction(g, selflooped)
end
