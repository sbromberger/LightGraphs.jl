function edit_distance(G₁::AbstractGraph, G₂::AbstractGraph;
                        insert_cost::Function=v -> 1.0,
                        delete_cost::Function=u -> 1.0,
                        subst_cost::Function=(u, v) -> 0.5,
                        heuristic::Function=DefaultEditHeuristic)

    Base.depwarn("`edit_distance` is deprecated. Equivalent functionality has been moved to `LightGraphs.Structure.edit_distance`.", :edit_distance)
    LightGraphs.Structure.edit_distance(G₁, G₂, insert_cost=insert_cost, delete_cost=delete_cost, subst_cost=subst_cost, heuristic=heuristic)
end

function DefaultEditHeuristic(λ, G₁::AbstractGraph, G₂::AbstractGraph)
    Base.depwarn("`DefaultEditHeuristic` is deprecated. Equivalent functionality has been moved to `LightGraphs.Structure.DefaultEditHeuristic`.", :DefaultEditHeuristic)
    LightGraphs.Structure.DefaultEditHeuristic(λ, G₁, G₂)
end

#-------------------------
# Edit path cost functions
#-------------------------

function MinkowskiCost(μ₁::AbstractVector, μ₂::AbstractVector; p::Real=1)
    Base.depwarn("`MinkowskiCost` is deprecated. Equivalent functionality has been moved to `LightGraphs.Structure.MinkowskiCost`.", :MinkowskiCost)
    LightGraphs.Structure.MinkowskiCost(μ₁, μ₂, p=p)
end

function BoundedMinkowskiCost(μ₁::AbstractVector, μ₂::AbstractVector; p::Real=1, τ::Real=1)
    Base.depwarn("`BoundedMinkowskiCost` is deprecated. Equivalent functionality has been moved to `LightGraphs.Structure.BoundedMinkowskiCost`.", :BoundedMinkowskiCost)
    LightGraphs.Structure.BoundedMinkowskiCost(μ₁, μ₂, p=p, τ=τ)
end
