# TODO 2.0.0: Remove this file
@deprecate best_color LightGraphs.Traversals.best_color
function degree_greedy_color(g::AbstractGraph)
    Base.depwarn(
        "`degree_greedy_color` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.greedy_color`.",
        :degree_greedy_color,
    )
    Traversals.greedy_color(g, Traversals.DegreeColoring())
end

function perm_greedy_color(g::AbstractGraph, seq)
    Base.depwarn(
        "`perm_greedy_color` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.greedy_color`.",
        :perm_greedy_color,
    )
    Traversals.greedy_color(g, Traversals.FixedColoring(seq))
end

function random_greedy_color(g::AbstractGraph, reps::Integer = 1; seed = -1)
    Base.depwarn(
        "`random_greedy_color` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.greedy_color`.",
        :random_greedy_color,
    )
    Traversals.greedy_color(
        g,
        Traversals.RandomColoring(niter = reps, rng = LightGraphs.getRNG(seed)),
    )
end

function greedy_color(g::AbstractGraph; sort_degree::Bool = false, reps::Integer = 1)
    Base.depwarn(
        "`greedy_color` is deprecated. Equivalent functionality has been moved to `LightGraphs.Traversals.greedy_color`.",
        :greedy_color,
    )
    coloralg =
        sort_degree ? Traversals.DegreeColoring() : Traversals.RandomColoring(niter = reps)
    Traversals.greedy_color(g, coloralg)
end
