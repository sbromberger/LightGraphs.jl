"""
    simplecycles_hawick_james(g)

Find circuits (including self-loops) in `g` using the algorithm
of Hawick & James.

### References
- Hawick & James, "Enumerating Circuits and Loops in Graphs with Self-Arcs and Multiple-Arcs", 2008
"""
function simplecycles_hawick_james end
# see https://github.com/mauro3/SimpleTraits.jl/issues/47#issuecomment-327880153 for syntax
@traitfn function simplecycles_hawick_james(g::AG::IsDirected) where {T, AG<:AbstractGraph{T}}
    Base.depwarn("`simplecycles_hawick_james` is deprecated. Equivalent functionality has been moved to `LightGraphs.Cycles.simple_cycles`.", :simplecycles_hawick_james)
    LightGraphs.Cycles.simple_cycles(g, LightGraphs.Cycles.HawickJames())
end
