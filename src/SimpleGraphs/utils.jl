"""
    deepcopy_adjlist(adjlist::Vector{Vector{T}})

Internal utility function for copying adjacency lists.
On adjacency lists this function is more efficient than `deepcopy` for two reasons:
-  As of Julia v1.0.2, `deepcopy` is not typestable.
- `deepcopy` needs to track all references when traversing a recursive data structure
    in order to ensure that references to the same location do need get assigned to
    different locations in the copy. Because we can assume that all lists in our
    adjacency list are different, we don't need to keep track of them.
If `T` is not a bitstype (e.g. `BigInt`), we use the standard `deepcopy`.
"""
function deepcopy_adjlist(adjlist::Vector{Vector{T}}) where {T}
    isbitstype(T) || return deepcopy(adjlist)

    result = Vector{Vector{T}}(undef, length(adjlist))
    @inbounds for (i, list) in enumerate(adjlist)
        result_list = Vector{T}(undef, length(list))
        for (j, item) in enumerate(list)
            result_list[j] = item
        end
        result[i] = result_list
    end
    return result
end
