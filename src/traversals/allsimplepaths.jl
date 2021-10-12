using DataStructures

"""
    all_simple_paths(g, source, targets, cutoff)

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
function all_simple_paths(g::AbstractGraph, source::T, targets::Vector{T}; cutoff::T=typemax(T)) where T <: Integer
    return SimplePathIterator(g, source, Set(targets), cutoff=cutoff)
end


"""
    all_simple_paths(g, source, target, cutoff)

This function is equivalent to `all_simple_paths(g, source, [target], cutoff)`.
This is provided for convenience.

See also `all_simple_paths(g, source, targets, cutoff)`.
"""
function all_simple_paths(g::AbstractGraph, source::T, target::T; cutoff::T=typemax(T)) where T <: Integer
    return SimplePathIterator(g, source, Set(target), cutoff=cutoff)
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
    cutoff::T  # Max length of resulting paths

    function SimplePathIterator(g::AbstractGraph, source::T, targets::Set{T}; cutoff::T=typemax(T)) where T <: Integer
        new{T}(g, source, targets, cutoff)
    end
end


"""
    SimplePathIteratorState{T <: Integer}

SimplePathIterator's state.
"""
mutable struct SimplePathIteratorState{T <: Integer}
    stack::Stack{Vector{T}}  # Store information used to restore iteration of child nodes. Each vector has two elements which are a parent node and an index of children.
    visited::Stack{T}  # Store current path candidate
    queued_targets::Vector{T}  # Store rest targets if path length reached cutoff.
    function SimplePathIteratorState(spi::SimplePathIterator{T}) where T <: Integer
        stack = Stack{Vector{T}}()
        visited = Stack{T}()
        queued_targets = Vector{T}()
        push!(visited, spi.source)  # Add a starting node to the path candidate
        push!(stack, [spi.source, 1])  # Add a child node with index = 1
        new{T}(stack, visited, queued_targets)
    end
end

"""
    function _stepback!(state)

A helper function that updates iterator state.
For internal use only.
"""
function _stepback!(state::SimplePathIteratorState)
    pop!(state.stack)
    pop!(state.visited)
end


"""
    Base.iterate(spi::SimplePathIterator{T}, state=nothing)

Returns a next simple path based on DFS.
If `cutoff` is specified in `SimplePathIterator`, the path length is limited up to `cutoff`.
"""
function Base.iterate(spi::SimplePathIterator{T}, state::Union{SimplePathIteratorState,Nothing}=nothing) where T <: Integer

    state = isnothing(state) ? SimplePathIteratorState(spi) : state

    while !isempty(state.stack)

        if !isempty(state.queued_targets)
            # Consumes queueed targets
            target = pop!(state.queued_targets)
            result = vcat(reverse(collect(state.visited)), target)
            if isempty(state.queued_targets)
                _stepback!(state)
            end
            return result, state
        end

        parent_node, next_childe_index = first(state.stack)
        children = outneighbors(spi.g, parent_node)
        if length(children) < next_childe_index
            # All children have been checked, step back.
            _stepback!(state)
            continue
        end

        child = children[next_childe_index]    
        # Move child index forward.
        first(state.stack)[2] += 1

        if child in state.visited
            # Avoid loop
            continue
        end

        if length(state.visited) < spi.cutoff
            result = (child in spi.targets) ? vcat(reverse(collect(state.visited)), [child]) : nothing

            # Update state variables
            push!(state.visited, child)  # Move to child node
            if !isempty(setdiff(spi.targets, state.visited))  # Expand stack until find all targets
                push!(state.stack, [child, 1])  #  Add the child node as a parent for next iteration.
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
            rest_children = Set(children[next_childe_index: end])
            state.queued_targets = collect(setdiff(intersect(spi.targets, rest_children), Set(state.visited)))

            if isempty(state.queued_targets)
                _stepback!(state)
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
    for _ in spi
        c += 1
    end
    return c
end
