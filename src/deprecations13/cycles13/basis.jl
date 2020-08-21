# Code in this file inspired by NetworkX.

using LightGraphs.SimpleGraphsCore: AbstractSimpleGraph, SimpleGraph, SimpleEdge
function cycle_basis(g::AbstractSimpleGraph, root=nothing)
    Base.depwarn("`cycle_basis` is deprecated. Equivalent functionality has been moved to `LightGraphs.Cycles.cycle_basis`.", :cycle_basis)
    if root == nothing
        LightGraphs.Cycles.cycle_basis(g)
    else
        LightGraphs.Cycles.cycle_basis(g, root)
    end
end
