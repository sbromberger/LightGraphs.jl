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
   get_distinct_colors(g, v, seen, max_col) 

Get number of distinct colors adjacent to `v`.
Currently, the graph is colored by `max_col` vertices.
`seen[i]` == true iff node `i` has been colored.
"""
function get_distinct_colors(
    g::AbstractGraph,
    v::T, cols::Vector{T},
    seen::Vector{Bool},
    max_col::T
    ) where T <: Integer 

    col_seen = zeros(Bool, max_col)
    num_distinct = zero(T)
    for i in neighbors(g, v)
        if seen[i]
            col_seen[cols[i]] || (num_distinct += one(T))
            col_seen[cols[i]] = true
        end
    end
    return num_distinct
end

"""
    smallest_valid_color(g, v, max_col, cols, seen)

Find the smallest color that none of the neighbors of `v` possess.
Currently, the graph is colored by `max_col` vertices.
`seen[i]` == true iff node `i` has been colored.
"""
function smallest_valid_color(
    g::AbstractGraph,
    v::T, max_col::T,
    cols::Vector{T},
    seen::Vector{Bool}
    ) where T <: Integer 

    to_consider = min(degree(g, v), max_col)
    colors_used = zeros(Bool, to_consider)
    for w in neighbors(g, v)
        if seen[w] && cols[w] <= to_consider
            colors_used[cols[w]] = true
        end
    end

    best_col = to_consider+one(T)
    for i in one(T):to_consider
        if !colors_used[i]
            best_col = i
            break
        end
    end
    return best_col
end

"""
    invalidate_distinct_colors!(g, v, valid_distinct_cols)

Set the `valid_distinct_cols` of the the neighbors of `v` to be invalid.
Used after assigning `v` its color. 
"""
function invalidate_distinct_colors!(
    g::AbstractGraph,
    v::T, 
    valid_distinct_cols::Vector{Bool}
    ) where T <: Integer
    
    @inbounds @simd for u in neighbors(g, v)
        valid_distinct_cols[u] = false    
    end
end

"""
    exchange_cols!(g, v, max_col, cols, valid_distinct_colors, distinct_colors, seen)
        
Check which neighbors of `v` can change their color with increasing the number of colors used.
Then assign `v` that color and change the neighbors's color.
Updates `seen` and `cols`.
"""
function exchange_cols!(
    g::AbstractGraph,
    v::T, max_col::T,
    cols::Vector{T},
    valid_distinct_cols::Vector{Bool},
    distinct_cols::Vector{T},
    seen::Vector{Bool}
    )  where T <: Integer


    possible_cols = ones(Bool, max_col)
    for u in neighbors(g, v)
        seen[u] || continue
        if !valid_distinct_cols[u]
            distinct_cols[u] = get_distinct_colors(g, u, cols, seen, max_col)
            valid_distinct_cols[u] = true
        end
        #Condition to check exchange would help
        (distinct_cols[u] > max_col-2) && (possible_cols[cols[u]] = false)
    end

    #Check if exchange could help
    best_col = max_col+one(T)
    for i in 1:max_col
        if possible_cols[i]
            best_col = i
            break
        end
    end
    cols[v] = best_col
    invalidate_distinct_colors!(g, v, valid_distinct_cols)
    seen[v] = true
    (best_col == max_col+1) && return #Exchange is useless

    #Perform exchange. max_col will not increase in this step 
    #because distinct_cols[u] <= max_col-2
    for u in neighbors(g, v)
        if seen[u] && cols[u] == best_col
            distinct_cols[u] += 1 #By property of colors
            valid_distinct_cols[u] = true
            cols[u] = smallest_valid_color(g, u, max_col, cols, seen)
            invalidate_distinct_colors!(g, u, valid_distinct_cols)
        end
    end

end

"""
    perm_greedy_color_exchange(g, seq)

Color graph `g` according to an order specified by `seq` using a greedy heuristic.
seq[i] = v imples that vertex v is the i<sup>th</sup> vertex to be colored.
Assumes `seq` is a permutation of the vertices of `g`.
### Performance
Runtime: O(|V|*|E|)
This a cynical upper bound as it depends on the orientation of the edges
and the order of the coloring.
Memory Overhead: O(|V|)
"""
function perm_greedy_color_exchange(
    g::AbstractGraph,
    seq::Vector{T}
    ) where T <: Integer 

    nvg::T = nv(g)
    cols = Vector{T}(undef, nvg)  
    seen = zeros(Bool, nvg)
    distinct_cols = zeros(T, nvg)
    valid_distinct_cols = zeros(Bool, nvg) #Check if number of distinct_colors must be recalculated.
    max_col = one(T)

    for v in seq
        best_col = smallest_valid_color(g, v, max_col, cols, seen)

        if best_col <= max_col 
            cols[v] = best_col
            seen[v] = true
            invalidate_distinct_colors!(g, v, valid_distinct_cols)
            continue
        end

        exchange_cols!(g, v, max_col, cols, valid_distinct_cols, distinct_cols, seen)
        max_col = max(max_col, cols[v])
    end

    return coloring{T}(maximum(cols), cols)
end


"""
    perm_greedy_color(g, seq)

Color graph `g` according to an order specified by `seq` using a greedy heuristic.
seq[i] = v imples that vertex v is the i<sup>th</sup> vertex to be colored.
Assumes `seq` is a permutation of the vertices of `g`.
"""
function perm_greedy_color_no_exchange(
    g::AbstractGraph,
    seq::Vector{T}
    ) where T <: Integer 

    nvg::T = nv(g)
    cols = Vector{T}(undef, nvg)  
    seen = zeros(Bool, nvg)
    max_col = one(T)

    for v in seq
        cols[v] = smallest_valid_color(g, v, max_col, cols, seen)
        seen[v] = true
        max_col = max(max_col, cols[v])
    end

    return coloring{T}(maximum(cols), cols)
end

"""
    perm_greedy_color(g, seq, exchange)

Color graph `g` according to an order specified by `seq` using a greedy heuristic.
If `exchange` is true then at every iteration, we will avoid introducing a new color
into the partial coloring with changing the color of its neighbors.
"""
perm_greedy_color(g::AbstractGraph, seq::Vector{T}, exchange::Bool) where T <: Integer = exchange ? 
perm_greedy_color_exchange(g, seq) : perm_greedy_color_no_exchange(g, seq)

"""
    degree_greedy_color(g, exchange)

Color graph `g` iteratively in the descending order of the degree of the vertices.
"""
function degree_greedy_color(g::AbstractGraph{T}, exchange::Bool) where T<:Integer 
    seq = convert(Vector{T}, sortperm(degree(g) , rev=true)) 
    return perm_greedy_color(g, seq, exchange)
end

"""
    parallel_random_greedy_color(g, reps, exchange)

Color graph `g` iteratively in a random order using a greedy heuristic and
choose the best coloring out of `reps` number of colorings computed in parallel.
"""
function parallel_random_greedy_color(
    g::AbstractGraph{T},
    reps::Integer,
    exchange::Bool
) where T<:Integer 

    best = @distributed (best_color) for i in 1:reps
        seq = shuffle(vertices(g))
        perm_greedy_color(g, seq, exchange)
    end

    return convert(coloring{T} ,best)
end

"""
    seq_random_greedy_color(g, reps, exchange)

Color graph `g` iteratively in a random order using a greedy heuristic
and choose the best coloring out of `reps` such random coloring.
"""
function seq_random_greedy_color(
    g::AbstractGraph{T}, 
    reps::Integer,
    exchange::Bool
) where T <: Integer 

    seq = shuffle(vertices(g))
    best = perm_greedy_color(g, seq, exchange)

    for i in 2:reps
        shuffle!(seq)
        best = best_color(best, perm_greedy_color(g, seq, exchange))
    end
    return best
end

"""
    random_greedy_color(g, reps=1, exchange=false, parallel=false)

Color graph `g` iteratively in a random order using a greedy heruistic
and choose the best coloring out of `reps` such random coloring.

If parallel is true then the colorings are executed in parallel.
"""
random_greedy_color(g::AbstractGraph{T}, reps::Integer, exchange::Bool, parallel::Bool) where {T<:Integer} =
parallel ? parallel_random_greedy_color(g, reps, exchange) : seq_random_greedy_color(g, reps, exchange)

"""
    greedy_color(g; sort_degree=false, parallel=false, reps = 1)

Color graph `g` based on [Greedy Coloring Heuristics](https://en.wikipedia.org/wiki/Greedy_coloring)

The heuristics can be described as choosing a permutation of the vertices and assigning the 
lowest color index available iteratively in that order.

If `sort_degree` is true then the permutation is chosen in reverse sorted order of the degree of the vertices.
`parallel` and `reps` are irrelevant in this case.

If `sort_degree` is false then `reps` colorings are obtained based on random permutations and the one using least
colors is chosen.

If 'exchange' is true then at every iteration, if a new color must be introduced, then the algorithm will attempt
to avoid introducing a new color by changing the colors of its neighbors. It requires much more computation
but will likely reduce the number of colors used.

If `parallel` is true then this function executes coloring in parallel.
"""
greedy_color(g::AbstractGraph{U}; sort_degree::Bool=false, parallel::Bool =false, exchange=false, reps::Integer=1) where {U <: Integer} =
sort_degree ? degree_greedy_color(g, exchange) : random_greedy_color(g, reps, exchange, parallel)
