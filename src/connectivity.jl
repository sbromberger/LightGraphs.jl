# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

function connected_components!(label::AbstractVector, g::AbstractGraph{T}) where T
    Base.depwarn("`connected_components!` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.connected_components!`.", :connected_components!)
    LightGraphs.Connectivity.connected_components!(label, g)
end

function components_dict(labels::Vector{T}) where T <: Integer
    Base.depwarn("`components_dict` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.components_dict`.", :components_dict)
    LightGraphs.Connectivity.components_dict(labels)
end

function components(labels::Vector{T}) where T <: Integer
    Base.depwarn("`components` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.components`.", :components)
    LightGraphs.Connectivity.components(labels)
end

function connected_components(g::AbstractGraph{T}) where T
    Base.depwarn("`connected_components` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.connected_components`.", :connected_components)
    LightGraphs.Connectivity.connected_components(g)
end

function is_connected(g::AbstractGraph)
    Base.depwarn("`is_connected` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.is_connected`.", :is_connected)
    LightGraphs.Connectivity.is_connected(g)
end

function weakly_connected_components(g)
    Base.depwarn("`weakly_connected_components` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.weakly_connected_components`.", :weakly_connected_components)
    LightGraphs.Connectivity.weakly_connected_components(g)
end

function is_weakly_connected(g::AbstractGraph)
    Base.depwarn("`is_weakly_connected` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.is_weakly_connected`.", :is_weakly_connected)
    LightGraphs.Connectivity.is_weakly_connected(g)
end

function strongly_connected_components(g)
    Base.depwarn("`strongly_connected_components` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.strongly_connected_components`.", :strongly_connected_components)
    LightGraphs.Connectivity.strongly_connected_components(g)
end


function strongly_connected_components_kosaraju(g)
    Base.depwarn("`strongly_connected_components_kosaraju` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.strongly_connected_components_kosaraju`.", :strongly_connected_components_kosaraju)
    LightGraphs.Connectivity.strongly_connected_components_kosaraju(g)
end


function is_strongly_connected(g)
    Base.depwarn("`is_strongly_connected` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.is_strongly_connected`.", :is_strongly_connected)
    LightGraphs.Connectivity.is_strongly_connected(g)
end

function period(g)
    Base.depwarn("`period` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.period`.", :period)
    LightGraphs.Connectivity.period(g)
end

function condensation(g, scc)
    Base.depwarn("`condensation` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.condensation`.", :condensation)
    LightGraphs.Connectivity.condensation(g, scc)
end
function condensation(g)
    Base.depwarn("`condensation` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.condensation`.", :condensation)
    LightGraphs.Connectivity.condensation(g)
end

function attracting_components(g)
    Base.depwarn("`attracting_components` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.attracting_components`.", :attracting_components)
    LightGraphs.Connectivity.attracting_components(g)
end

function neighborhood(g::AbstractGraph, v::Integer, d; dir=:out) 
    Base.depwarn("`neighborhood` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.neighborhood`.", :neighborhood)
    dir == :out ? LightGraphs.Connectivity.neighborhood(g, v, d) : LightGraphs.Connectivity.neighborhood(g, v, d; neighborfn=inneighbors)
end

function neighborhood(g::AbstractGraph, v::Integer, d, distmx::AbstractMatrix; dir=:out)
    Base.depwarn("`neighborhood` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.neighborhood`.", :neighborhood)
    dir == :out ? LightGraphs.Connectivity.neighborhood(g, v, d, distmx) : LightGraphs.Connectivity.neighborhood(g, v, d, distmx; neighborfn=inneighbors)
end

function neighborhood_dists(g::AbstractGraph, v, d; dir=:out)
    Base.depwarn("`neighborhood_dists` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.neighborhood_dists`.", :neighborhood_dists)
    dir == :out ? LightGraphs.Connectivity.neighborhood_dists(g, v, d) : LightGraphs.Connectivity.neighborhood_dists(g, v, d; neighborfn=inneighbors)
end

function neighborhood_dists(g::AbstractGraph, v, d, distmx::AbstractMatrix; dir=:out)
    Base.depwarn("`neighborhood_dists` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.neighborhood_dists`.", :neighborhood_dists)
    dir == :out ? LightGraphs.Connectivity.neighborhood_dists(g, v, d, distmx) : LightGraphs.Connectivity.neighborhood_dists(g, v, d, distmx; neighborfn=inneighbors)
end


"""
    isgraphical(degs)

Return true if the degree sequence `degs` is graphical.
A sequence of integers is called graphical, if there exists a graph where the degrees of its vertices form that same sequence.

### Performance
Time complexity: ``\\mathcal{O}(|degs|*\\log(|degs|))``.

### Implementation Notes
According to Erdös-Gallai theorem, a degree sequence ``\\{d_1, ...,d_n\\}`` (sorted in descending order) is graphic iff the sum of vertex degrees is even and the sequence obeys the property -
```math
\\sum_{i=1}^{r} d_i \\leq r(r-1) + \\sum_{i=r+1}^n min(r,d_i)
```
for each integer r <= n-1
"""
function isgraphical(degs::Vector{<:Integer})
    Base.depwarn("`isgraphical` is deprecated. Equivalent functionality has been moved to `LightGraphs.Connectivity.is_graphical`.", :isgraphical)
    LightGraphs.Connectivity.is_graphical(degs)
end
