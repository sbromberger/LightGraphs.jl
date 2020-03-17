
# A nive algorithm for fininding the dominator, for testing purpose.
function naivedom(g::AG, r::T)  where {T, AG<:AbstractGraph{T}}
    domin=zeros(T, nv(g))
    _, verts_ord, ord_verts, cnt = Traversals.parent_order(g, r)
    # the immediate dominator of v is the domiantor whith the latest dfs numper
    # so if we ordered the nodes the last of them to declare him self as
    # dominator of v is the immediate dominator of v .
    for i in 1:cnt
      v = ord_verts[i]
      testnode(g, v, r, ord_verts, cnt, domin)
    end
    domin[r] = r
    return domin
end


# This function make a dfs with exclding some node v the nodes that cannot ne reached are dominated by v.
function testnode(g::SimpleDiGraph{T}, v::T, r::T, ord_verts::Vector{T}, cnt::T, domin::Vector{T}) where T
    #visit array
    vi2 = falses(nv(g))
    #making vi2[u] equal to true, will prevent any path to go Through it
    vi2[v] = true

    function dfs2(u)
        vi2[u] == true && return
        vi2[u] = true

        for w in outneighbors(g, u)
          dfs2(w)
        end
    end

    dfs2(r)
    #=we look for the node that havn’t been reached after we exculde u but was reachable before
    and declar u as its dominator , the last node to do that is the immediate domintor=#
    for i in 2:cnt
        x = ord_verts[i]
        if !vi2[x]
            domin[x] = v
        end
    end
end

@testset "Dominator tree" begin
    gint = SimpleDiGraph(3)
    add_edge!(gint, 1, 2)
    add_edge!(gint, 2, 3)
    for g in testdigraphs(gint)
        T = eltype(g)
        @test dominator_tree(g, T(1)) == [1, 1, 2]
    end
    gint = SimpleDiGraph(10, 30)
    for g in testdigraphs(gint)
        T = eltype(g)
        @test dominator_tree(g, T(1)) == naivedom(g, T(1))
        @test dominator_tree(g, T(10)) == naivedom(g, T(10))
    end

    gint = SimpleDiGraph(20, 40)
    for g in testdigraphs(gint)
        T = eltype(g)
        @test dominator_tree(g, T(1)) == naivedom(g, T(1))
        @test dominator_tree(g, T(10)) == naivedom(g, T(10))
    end
end
