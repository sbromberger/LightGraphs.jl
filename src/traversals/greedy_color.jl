"""
    struct coloring{T}

Store number of colors used and mapping from vertex to color
"""
struct coloring{T <: Integer} <: Any
    num_colors::T
    colors::Vector{T}
end

"""
   get_distinct_colors(g, v, seen, max_col) 

Get the number of distinct colors adjacent to `v`.
Currently, the graph is colored by `max_col` vertices.
`seen[i]` == true iff node `i` has been colored.
"""
function get_distinct_colors(
    g::AbstractGraph{T},
    v::T, 
    cols::Vector{T},
    seen::BitArray{1},
    max_col::T
    ) where T <: Integer 

    col_seen = falses(max_col)
    num_distinct = zero(T)
    @inbounds @simd for i in neighbors(g, v)
        if seen[i] && !col_seen[cols[i]]
            num_distinct += one(T)
            col_seen[cols[i]] = true
        end
    end
    return num_distinct
end

"""
    smallest_valid_color(g, v, max_col, cols, seen)

Find the smallest color that none of the neighbors of `v` possess.
Currently, the graph is colored by colors in `1:max_cols`.
`cols[i]` is the color of node `i`.
`seen[i]` == true iff node `i` has been colored.
Returns `max_col+1` if no valid color is present.
"""
function smallest_valid_color(
    g::AbstractGraph{T},
    v::T, 
    max_col::T,
    cols::Vector{T},
    seen::BitArray{1}
    ) where T <: Integer 

    to_consider = min(degree(g, v), max_col)
    colors_used = falses(to_consider+1)
    for w in neighbors(g, v)
        if seen[w] && cols[w] <= to_consider
            colors_used[cols[w]] = true
        end
    end

    best_col = findfirst(isequal(false), colors_used)
    return (best_col == nothing) ? (max_col+one(T)) : best_col
end

"""
    invalidate_distinct_colors!(g, v, valid_distinct_cols)

Set the `valid_distinct_cols` of the the neighbors of `v` to be invalid (false).
May be used after assigning `v` its color. 
"""
invalidate_distinct_colors!(
    g::AbstractGraph{T},
    v::T, 
    valid_distinct_cols::BitArray{1}
    ) where T <: Integer = (valid_distinct_cols[neighbors(g, v)] .= false)

"""
    exchange_cols!(g, v, max_col, cols, valid_distinct_colors, distinct_colors, seen)
        
Check which neighbors N of `v` can change their colors to avoid increasing the number of colors used.
Assign `v` those N's colors and find new colors for N.
`cols[i]` is the color of vertex `i`.
`distinct_colors[i]` is the number of distinct colors surrounding vertex `i`.
`valid_distinct_colors[i]` is true if `distinct_colors[i]` stores the correct value.
Update `seen` and `cols`.
"""
function exchange_cols!(
    g::AbstractGraph{T},
    v::T, 
    max_col::T,
    cols::Vector{T},
    valid_distinct_cols::BitArray{1},
    distinct_cols::Vector{T},
    seen::BitArray{1}
    )  where T <: Integer

    #Find the colors that can be exchanged to avoid introducing a new color.
    possible_exchange = trues(max_col)
    for u in neighbors(g, v)
        seen[u] || continue
        if !valid_distinct_cols[u]
            distinct_cols[u] = get_distinct_colors(g, u, cols, seen, max_col)
            valid_distinct_cols[u] = true
        end
        #Condition to check exchange will help
        if distinct_cols[u] > max_col-2 
            possible_exchange[cols[u]] = false
        end
    end
    best_col = findfirst(isequal(true), possible_exchange)
    best_col = (best_col == nothing) ? (max_col+one(T)) : best_col
    
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
    g::AbstractGraph{T},
    seq::Vector{T}
    ) where T <: Integer 

    nvg::T = nv(g)
    cols = Vector{T}(undef, nvg)  
    seen = falses(nvg)
    distinct_cols = zeros(T, nvg)
    valid_distinct_cols = falses(nvg) #Check if number of distinct_colors must be recalculated.
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

    return coloring{T}(max_col, cols)
end


"""
    perm_greedy_color_no_exchange(g, seq)

Color graph `g` according to an order specified by `seq` using a greedy heuristic.
seq[i] = v imples that vertex v is the i<sup>th</sup> vertex to be colored.
Assumes `seq` is a permutation of the vertices of `g`.
"""
function perm_greedy_color_no_exchange(
    g::AbstractGraph{T},
    seq::Vector{T}
    ) where T <: Integer 

    nvg::T = nv(g)
    cols = Vector{T}(undef, nvg)  
    seen = falses(nvg)
    max_col = one(T)

    for v in seq
        cols[v] = smallest_valid_color(g, v, max_col, cols, seen)
        seen[v] = true
        max_col = max(max_col, cols[v])
    end

    return coloring{T}(max_col, cols)
end

"""
    perm_greedy_color(g, exchange, seq=shuffle(vertices(g)))

Color graph `g` according to an order specified by `seq` using a greedy heuristic.
If `exchange` is true then at every iteration, we will avoid introducing a new color
into the partial coloring with changing the color of its neighbors.
"""
perm_greedy_color(g::AbstractGraph{T}, exchange::Bool, seq::Vector{T}=shuffle(vertices(g))) where T <: Integer = exchange ? 
perm_greedy_color_exchange(g, seq) : perm_greedy_color_no_exchange(g, seq)

"""
    degree_greedy_color(g, exchange)

Color graph `g` iteratively in the reverse sorted order of the degree of the vertices.
"""
function degree_greedy_color(g::AbstractGraph{T}, exchange::Bool) where T<:Integer 
    seq = convert(Vector{T}, sortperm(degree(g) , rev=true)) 
    return perm_greedy_color(g, exchange, seq)
end

"""
    greedy_color(g; sort_degree=false, exchange=false)

Color graph `g` based on [Greedy Coloring Heuristics](https://en.wikipedia.org/wiki/Greedy_coloring)

The heuristics can be described as choosing a permutation of the vertices and assigning the 
lowest color index available iteratively in that order.

### Optional Arguements
If `sort_degree` is `true` then the permutation is chosen in reverse sorted order of the degree of the vertices.

If `sort_degree` is `false` then a colorings are obtained based on random permutations and the one using least
colors is chosen.

If 'exchange' is `true` then at every iteration, if a new color must be introduced, then the algorithm will attempt
to avoid introducing a new color by changing the colors of its neighbors. It requires much more computation
but will likely reduce the number of colors used.
"""
greedy_color(g::AbstractGraph{T}; sort_degree::Bool=false, exchange=false) where {T <: Integer} =
sort_degree ? degree_greedy_color(g, exchange) : perm_greedy_color(g, exchange)

"""
    parallel_random_greedy_color(g, Reps; exchange=false)

Perform [`LightGraphs.perm_greedy_color`](@ref) `Reps` times in parallel 
and return the solution with the fewest colors.
"""
parallel_random_greedy_color(g::AbstractGraph{T}, Reps::Integer; exchange=false) where {T <: Integer} = 
generate_min_colors(g, (g)->perm_greedy_color(g, exchange), Reps)