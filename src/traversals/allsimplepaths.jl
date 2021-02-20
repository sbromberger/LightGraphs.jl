using DataStructures

"""
    all_simple_paths(g, source, targets, cutoff=nothing)

Returns an iterator that generates all simple paths in the graph `g` from `source` to `targets`.
If `cutoff` is given, the paths' lengths are limited to equal or less than `cutoff`.
Note that the length of a path is defined as the number of edges, not the number of elements.
ex. the path length of `[1, 2, 3]` is two.
Internally, a DFS algorithm is used to search paths.

# Examples

```jldoctest
julia> using LightGraphs
julia> g = complete_graph(4)
julia> collect(all_simple_paths(g, 1, [4]))
5-element Array{Array{Int64,1},1}:
 [1, 4]
 [1, 3, 4]
 [1, 3, 2, 4]
 [1, 2, 4]
 [1, 2, 3, 4]
 ```
"""
function all_simple_paths(g::AbstractGraph, source::T, targets::Vector{T}; cutoff::Union{Int,Nothing}=nothing) where T <: Integer
    return SimplePathIterator(g, source, targets, cutoff=cutoff)
end


"""
    all_simple_paths(g, source, target, cutoff=nothing)

This function is equivalent to `all_simple_paths(g, source, [target], cutoff)`.
This is provided for convenience.

See also `all_simple_paths(g, source, targets, cutoff)`.
"""
function all_simple_paths(g::AbstractGraph, source::T, target::T; cutoff::Union{Int,Nothing}=nothing) where T <: Integer
    return SimplePathIterator(g, source, [target], cutoff=cutoff)
end


"""
    SimplePathIterator{T <: Integer}

Iterator that generates all simple paths.
The iterator holds the condition specified in `all_simple_path` function.
"""
struct SimplePathIterator{T <: Integer}
    g::AbstractGraph
    source::T  # Starting node
    targets::Set{T}  # Target nodes
    cutoff::Union{Int,Nothing}  # Max length of resulting paths

    function SimplePathIterator(g::AbstractGraph, source::T, targets::Vector{T}; cutoff::Union{Int,Nothing}=nothing) where T <: Integer
        new{T}(g, source, Set(targets), cutoff)
    end
end


"""
    SimplePathIteratorState{T <: Integer}

SimplePathIterator's state.
"""
mutable struct SimplePathIteratorState{T <: Integer}
    stack::Stack{Vector{T}}  # Store child nodes
    visited::Stack{T}  # Store current path candidate
    queued_targets::Vector{T}  # Store rest targets if path length reached cutoff.
    function SimplePathIteratorState(spi::SimplePathIterator{T}) where T <: Integer
        stack = Stack{Vector{T}}()
        visited = Stack{T}()
        queued_targets = Vector{T}()
        push!(visited, spi.source)  # Add a starting node to the path candidate
        push!(stack, copy(outneighbors(spi.g, spi.source)))  # Add child nodes from the start
        new{T}(stack, visited, queued_targets)
    end
end

"""
    function stepback!(state)

A helper function that updates iterator state.
For internal use only.
"""
function stepback!(state::SimplePathIteratorState)
    pop!(state.stack)
    pop!(state.visited)
end


"""
    Base.iterate(spi::SimplePathIterator{T}, state=nothing)

Returns a next simple path based on DFS.
If `cutoff` is specified in `SimplePathIterator`, the path length is limited up to `cutoff`
"""
function Base.iterate(spi::SimplePathIterator{T}, state::Union{SimplePathIteratorState,Nothing}=nothing) where T <: Integer

    state = isnothing(state) ? SimplePathIteratorState(spi) : state

    while !isempty(state.stack)

        if !isempty(state.queued_targets)
            # Consumes queueed targets
            target = pop!(state.queued_targets)
            result = vcat(reverse(collect(state.visited)), target)
            if isempty(state.queued_targets)
                stepback!(state)
            end
            return result, state
        end

        children = first(state.stack)

        if isempty(children)
            # Now leaf node, step back.
            stepback!(state)
            continue
        end

        child = pop!(children)
        if child in state.visited
            # Avoid loop
            continue
        end

        if isnothing(spi.cutoff) || length(state.visited) < spi.cutoff
            result = (child in spi.targets) ? vcat(reverse(collect(state.visited)), [child]) : nothing

            # Update state variables
            push!(state.visited, child)  # Move to child node
            if !isempty(setdiff(spi.targets, state.visited))  # Expand stack until find all targets
                push!(state.stack, copy(outneighbors(spi.g, child)))  # Add child nodes and step forward
            else
                pop!(state.visited)  # Step back and explore the remaining child nodes
            end

            # If found a new path, returns it.
            if !isnothing(result)
                return result, state
            end
        else
            # Now length(visited) == cutoff
            # Collect adjacent targets if exist and add them to queue.
            rest_children = union(Set(children), Set(child))
            state.queued_targets = collect(setdiff(intersect(spi.targets, rest_children), Set(state.visited)))

            if isempty(state.queued_targets)
                stepback!(state)
            end
        end
    end
end


"""
    Base.collect(spi::SimplePathIterator{T})

Makes an array of paths from iterator.
Note that this can take much memory space and cpu time when the graph is dense.
"""
function Base.collect(spi::SimplePathIterator{T}) where T <: Integer
    res = Vector{Vector{T}}()
    for x in spi
        push!(res, x)
    end
    return res
end


"""
    Base.length(spi::SimplePathIterator{T})

Returns searched paths count.
Note that this can take much cpu time when the graph is dense.
"""
function Base.length(spi::SimplePathIterator{T}) where T <: Integer
    c = 0
    for x in spi
        c += 1
    end
    return c
end
