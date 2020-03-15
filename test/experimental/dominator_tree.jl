#=
a nive algorithm for fininding the dominator,
 first if we know that u and v are dominators of some node w, then it must be that one node is a dominator of the other,
 the immidiate_dominator of some node u is the node that dominats u but is dominated by all other dominators of u,
 if y is dominated by x then it must be the case that preorder of y is smaller than x’s ,
 then the immediate dominator of u is the node that has the bigest preorder among the dominators of u,
 then  if ignor some node u, perform a dfs,and couldnot  reach some node v,then v is dominated by u,
 the biggest such a node is the immediate dominator
=#
function naivedom(g::AG, r::T)  where {T, AG<:AbstractGraph{T}}
    domin=zeros(T, nv(g))
    # this array will mark the nodes that are reachable
    _, verts_ord, ord_verts, cnt = parent_order(g, r)
    for i in 1:cnt
      v = ord_verts[i]
      testnode(g, v, r, ord_verts, cnt, domin)
    end
    domin[r] = r
    return domin
end


#this function make a dfs with exclding some node the nodes that cannot ne reached are dominated by this node
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
        if x == 0
            println()
        end
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

@testset "ParentOrder" begin
    g1 = star_digraph(4)
    g2 = path_digraph(4)

    for g in testdigraphs(g1)
        T = eltype(g)
        parent, verts_ord, ord_verts, cnt = parent_order(g, T(1))
        @test (parent, verts_ord, ord_verts, cnt) == ([0, 1, 1, 1], [1, 2, 3, 4], [1, 2, 3, 4], 4)
    end

    for g in testdigraphs(g2)
        T = eltype(g)
        parent, verts_ord, ord_verts, cnt = parent_order(g, T(1))
        @test (parent, verts_ord, ord_verts, cnt) == ([0, 1, 2, 3], [1, 2, 3, 4], [1, 2, 3, 4], 4)
    end
end
