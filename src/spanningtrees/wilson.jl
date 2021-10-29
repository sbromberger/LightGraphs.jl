"""
    wilson_rst(g, distmx=weights(g); seed=-1, rng=GLOBAL_RNG)
                    
Randomly sample a spanning tree from an undirected connected graph g using 
[Wilson's algorithm](https://en.wikipedia.org/wiki/Loop-erased_random_walk).
The tree will be sampled with probability measure proportional to the product 
of the edge weights (given by distmx).

The exact probability of the tree may be determined by computing the 
normalization constant of the distribution via [Kirchoff's](https://en.wikipedia.org/wiki/Kirchhoff%27s_theorem)
or [Tutte's Matrix Tree](https://personalpages.manchester.ac.uk/staff/mark.muldoon/Teaching/DiscreteMaths/LectureNotes/MatrixTreeProof.pdf)
theorem, which is equivalent to the determinant of any minor of the Laplacian matrix.

e.g.

tree = wilson_rst(g)
probability_of_tree = prod([weights(g)[src(e), dst(e)] for e in tree])
probability_of_tree /= det(laplacian_matrix(g)[2:nv(g), 2:nv(g)]))
"""
function wilson_rst end
@traitfn function wilson_rst(g::AG::(!IsDirected),
    distmx::AbstractMatrix{T}=weights(g);
    seed::Int=-1,
    rng::AbstractRNG=GLOBAL_RNG
) where {T <: Real, U, AG <: AbstractGraph{U}}

    if seed >= 0
        rng = getRNG(seed)
    end

    start1 = rand(rng, 1:nv(g))
    start2 = rand(rng, 1:nv(g))

    walk = loop_erased_randomwalk(g, start1, distmx=distmx, f=[start2], rng=rng)

    tree = SimpleGraph(nv(g))
    for i = 1:length(walk)-1
        add_edge!(tree, walk[i], walk[i+1])
    end

    visited_vertices = Set(walk)
    unvisited_vertices = setdiff(Set([i for i = 1:nv(g)]), visited_vertices)

    while length(unvisited_vertices) > 0
        v = rand(rng, unvisited_vertices)
        walk = loop_erased_randomwalk(g, v, distmx=distmx, f=visited_vertices, 
                                      rng=rng)

        for i = 1:length(walk)-1
            add_edge!(tree, walk[i], walk[i+1])
        end
        walk_set = Set(walk)
        union!(visited_vertices, walk_set)
        unvisited_vertices = setdiff(unvisited_vertices, walk_set)
    end
    return [e for e in edges(tree)]
end

