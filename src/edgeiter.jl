type EdgeIterState
    s::Int  # src vertex
    di::Int # index into adj of dest vertex
    fin::Bool
end

type EdgeIter
    m::Int
    adj::Vector{Vector{Int}}
    start::EdgeIterState
    directed::Bool
end

# eltype(::Type{Edge}) = Edge
eltype(::Type{EdgeIter}) = Edge


function EdgeIter(g::Graph)
    di = 1
    s = 1
    while di > length(g.fadjlist[s])    # get to the first valid edge.
        s += 1
        di = 1
        s > length(g.fadjlist) && return EdgeIter(ne(g), g.fadjlist, EdgeIterState(1,1, true), false)
    end
    return EdgeIter(ne(g), g.fadjlist, EdgeIterState(s, di, false), false)
end

function EdgeIter(g::DiGraph)
    di = 1
    s = 1
    while di > length(g.fadjlist[s])
        s += 1
        di = 1
        s > length(g.fadjlist) && return EdgeIter(ne(g), g.fadjlist, EdgeIterState(1,1, true), true)
    end
    return EdgeIter(ne(g), g.fadjlist, EdgeIterState(s, di, false), true)
end


# EdgeIter(ne(g), g.fadjlist, EdgeIterState(1, 1, ifelse((ne(g) == 0), true, false)), false)
# EdgeIter(g::DiGraph) = EdgeIter(ne(g), g.fadjlist, EdgeIterState(1, 1, ifelse((ne(g) == 0), true, false)), true)

start(eit::EdgeIter) = eit.start
done(eit::EdgeIter, state::EdgeIterState) = state.fin

_isfin(eit::EdgeIter, state::EdgeIterState) =
    state.s > length(eit.adj) || (
        state.s == length(eit.adj) &&
        state.di > length(eit.adj[state.s])
    )

function next(eit::EdgeIter, state::EdgeIterState)
    # println("in next: s = $(state.s), di = $(state.di)")
    # calculate the edge we're currently looking at.
    # this is guaranteed to be valid.
    d = eit.adj[state.s][state.di]
    edge = Edge(state.s, d)
    found = false       # have we found a valid next state?

    # now, let's get the next valid state, or set fin if there are no more.

    while !found
        state.di += 1                           # increase di.
        while (state.s < length(eit.adj) &&     # if we're at the end of a vector and
            state.di > length(eit.adj[state.s]))  # not at the end of the list
            # println("end of vector $(state.s)")
            state.s += 1                        # go to the next vector, and
            state.di = 1                        # index to the first element.
        end
        if _isfin(eit, state)                   # oops, we've hit the end
            state.fin = true
            return(edge, state)             # return a finished nextstate
        end
        if !eit.directed                    # for undirected graphs
            if state.s <= eit.adj[state.s][state.di]     # skip edges where s > d
                found = true
            # else
            #     println("skipping because $(state.s) > $(eit.adj[state.s][state.di])")
            end
        else
            found = true
        end
    end
    state.fin = _isfin(eit, state)                   # oops, we've hit the end
    return (edge, state)
end
#     if !eit.directed
#         while state.s > eit.adj[state.s][state.di]      # we're skipping edges where s > d
#             println("  s ($(state.s)) > d ($(eit.adj[state.s][state.di]))")
#             state.di += 1
#             if state.di > length(eit.adj[state.s])
#                 state.s += 1
#                 state.di = 1
#             end
#             if _isfin(eit, state)
#                 state.fin = true
#                 return (edge, state)
#             end
#         end
#     end
#     state.fin = _isfin(eit,state)
#     return (edge, state)
# end
#
#
# #
# #
# #     d = 0
# #     println("top of next: eit = $eit, state = $state")
# #     while state.di <= length(eit.adj[state.s])      # while the index to dest vertex is still within the src vertex vector
# #         d  = eit.adj[state.s][state.di]             # set d to the dest vertex
# #         !eit.directed && d >= state.s && break      # if the dest vertex is >= to the source, stop the loop
# #         state.di += 1                               # else increase the dest vertex index
# #     end
# #     while state.di > length(eit.adj[state.s])       # while the index to the dest vertex is greater than the src vertex vector
# #         state.di = 1                                # reset the dest vertex indicator
# #         state.s += 1                                # go to the next source vertex vector
# #         while state.di <= length(eit.adj[state.s])  # do it all again.
# #             d = eit.adj[state.s][state.di]
# #             !eit.directed && d >= state.s && break
# #             state.di += 1
# #         end
# #     end
# #     e = !eit.directed && d < state.s ? Edge(d, state.s) : Edge(state.s, d)
# #     state.di += 1
# #     state.it += 1
# #     return (e, state)
# # end
#
# length(eit::EdgeIter) = eit.m
#
# # note: e in edges(g) will not necessarily be the same as
# # e in collect(edges(g)) for undirected graphs. The former will be true
# # when s > d; the latter will not.
# function in(e::Edge, eit::EdgeIter)
#     if !is_ordered(e)
#         e = reverse(e)
#     end
#     s, t = e
#     n = length(eit.adj)
#     !(1 <=  s <= n) && return false
#     !(1 <=  t <= n) && return false
#     return t in eit.adj[s]
# end

# function getindex(eit::EdgeIter, n::Int)
#     1 <= n <= eit.m || throw(BoundsError())
#     offsetsum = 0
#     i = 1
#     e = Edge(0,0)
#     ordered = false
#     while !ordered
#         info("top of loop: n = $n, offsetsum = $offsetsum, i = $i, e = $e")
#         while (offsetsum < n)
#             offsetsum += length(eit.adj[i])
#             i += 1
#         end
#         i -= 1
#         info("out of loop: n = $n, offsetsum = $offsetsum, i = $i, e = $e")
#         offsetsum -= length(eit.adj[i])
#         d = eit.adj[i][n - offsetsum]
#         e = Edge(i,d)
#         info("pre-order check: n = $n, offsetsum = $offsetsum, i = $i, e = $e")
#         ordered = is_ordered(e)
#         if !ordered
#             n += 1
#         end
#     end
#     return e
# end


# getindex(eit::EdgeIter, n::UnitRange{Int64}) = [getindex(eit, x) for x in n]

#TODO implement using a loop and ∈, so that no memory is allocated
function _isequal(e1::EdgeIter, e2)
    for e in e2
        s, d = e
        found = length(searchsorted(e1.adj[s], d)) > 0
        if !e1.directed
            found = found || length(searchsorted(e1.adj[d],s)) > 0
        end
        !found && info("can't find $s -> $d") && return false
    end
    return true
end
==(e1::EdgeIter, e2::AbstractArray{Edge,1}) = _isequal(e1, e2)
==(e1::AbstractArray{Edge,1}, e2::EdgeIter) = _isequal(e2, e1)
==(e1::EdgeIter, e2::Set{Edge}) = _isequal(e1, e2)
==(e1::Set{Edge}, e2::EdgeIter) = _isequal(e2, e1)


function ==(e1::EdgeIter, e2::EdgeIter)
    length(e1.adj) == length(e2.adj) || return false
    e1.directed == e2.directed || return false
    for i in length(e1.adj)
        e1.adj[i] == e2.adj[i] || return false
    end
    return true
end



show(io::IO, eit::EdgeIter) = write(io, "EdgeIter $(eit.m)")
show(io::IO, s::EdgeIterState) = write(io, "EdgeIterState [$(s.s), $(s.di), $(s.fin)]")


# function ltg(i::Int, x::Vector{Int})
#
#     b = x[x .>= i]
#     a = fill(i, length(b))
#     return zip(a,b)
# end
#
# # _order(e::Edge) = is_ordered(e)? e : reverse(e)
#
# # mke(sd::Tuple{Int, Int}) = Edge(sd[1],sd[2])
# function edges2(g::Graph)
#     return imap(x->Edge(x[1],x[2]),chain(imap(ltg, 1:nv(g), LightGraphs.fadj(g))...))
# end
