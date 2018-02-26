"""
    struct coloring{T}

Store number of colors used and mapping from vertex to color
"""
struct coloring{T<:Integer} <: Any
    num_colors::T
    colors::Vector{T}
end

best_color(c1::coloring, c2::coloring) = c1.num_colors < c2.num_colors ? c1 : c2

"""
    perm_greedy_color(g, seq)

Color graph `g` according to an order specified by `seq` using a greedy heuristic.
seq[i] = v imples that vertex v is the i<sup>th</sup> vertex to be colored.
"""
function perm_greedy_color(
    g::AbstractGraph,
    seq::Vector{T}
    ) where T <: Integer 

    nvg::T = nv(g)
    cols = Vector{T}(uninitialized, nvg)  
    seen = zeros(Bool, nvg + 1)

    for v in seq
        seen[v] = true
        colors_used = zeros(Bool, nvg)

        for w in neighbors(g, v)
            if seen[w]
                colors_used[cols[w]] = true
            end
        end

     
        for i in one(T):nvg
            if colors_used[i] == false
                cols[v] = i
                break;
            end
        end
    end

    return coloring{T}(maximum(cols), cols)
end

"""
    degree_greedy_color(g)

Color graph `g` iteratively in the descending order of the degree of the vertices.
"""
function degree_greedy_color(g::AbstractGraph{T}) where T<:Integer 
    seq = convert(Vector{T}, sortperm(degree(g) , rev=true)) 
    return perm_greedy_color(g, seq)
end

"""
    parallel_random_greedy_color(g, reps)

Color graph `g` iteratively in a random order using a greedy heuristic and
choose the best coloring out of `reps` number of colorings computed in parallel.
"""
function parallel_random_greedy_color(
    g::AbstractGraph{T},
    reps::Integer
) where T<:Integer 

    best = @distributed (best_color) for i in 1:reps
        seq = shuffle(vertices(g))
        perm_greedy_color(g, seq)
    end

    return convert(coloring{T} ,best)
end

"""
    seq_random_greedy_color(g, reps)

Color graph `g` iteratively in a random order using a greedy heuristic
and choose the best coloring out of `reps` such random coloring.
"""
function seq_random_greedy_color(
    g::AbstractGraph{T}, 
    reps::Integer
) where T <: Integer 

    seq = shuffle(vertices(g))
    best = perm_greedy_color(g, seq)

    for i in 2:reps
        shuffle!(seq)
        best = best_color(best, perm_greedy_color(g, seq))
    end
    return best
end

"""
    random_greedy_color(g, reps=1, parallel=false)

Color graph `g` iteratively in a random order using a greedy heruistic
and choose the best coloring out of `reps` such random coloring.

If parallel is true then the colorings are executed in parallel.
"""
random_greedy_color(g::AbstractGraph{T}, reps::Integer = 1, parallel::Bool = false) where {T<:Integer} =
parallel ? parallel_random_greedy_color(g, reps) : seq_random_greedy_color(g, reps)

@doc_str """
    greedy_color(g; sort_degree=false, parallel=false, reps = 1)

Color graph `g` based on [Greedy Coloring Heuristics](https://en.wikipedia.org/wiki/Greedy_coloring)

The heuristics can be described as choosing a permutation of the vertices and assigning the 
lowest color index available iteratively in that order.

If `sort_degree` is true then the permutation is chosen in reverse sorted order of the degree of the vertices.
`parallel` and `reps` are irrelevant in this case.

If `sort_degree` is false then `reps` colorings are obtained based on random permutations and the one using least
colors is chosen.

If `parallel` is true then this function executes coloring in parallel.
"""
greedy_color(g::AbstractGraph{U}; sort_degree::Bool=false, parallel::Bool =false, reps::Integer=1) where {U <: Integer} =
sort_degree ? degree_greedy_color(g) : random_greedy_color(g, reps, parallel)

