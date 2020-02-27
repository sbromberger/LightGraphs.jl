#=
a nive algorithm for fininding the dominator ,

 first if we know that u and v are dominators of some node w, then it must be that one node is a dominator of the other,
 the immidiate_dominator of some node u is the node that dominats u but is dominated by all other dominators of u,
 if y is dominated by x then it must be the case that preorder of y is smaller than x’s ,
 then the immediate dominator of u is the node that has the bigest preorder among the dominators of u,
 then  if ignor some node u, perform a dfs,and couldnot  reach some node v,then v is dominated by u,
 the biggest such a node is the immediate dominator

=#
function naivedom(g::AG,r)  where {T, AG<:AbstractGraph{T}}

  domin=zeros(T,nv(g))
  # this array will mark the nodes that are reachable
  vi1=zeros(T,nv(g))

  #this function make a dfs with exclding some node the nodes that cannot ne reached are dominated by this node
  function testnode(u)
    #visit array
    vi2=falses(nv(g))
    #making vi2[u] equal to true will prevent any path to go Through it
    vi2[u]=true
    function dfs2(u)
      vi2[u]==true&&return
      vi2[u]=true

      for w in outneighbors(g,u)
        dfs2(w)
      end
    end
      dfs2(r)

      #=we look for the node that havn’t been reached after we exculde u but was reachable before
      and declar u as its dominator , the last node to do that is the immediate domintor=#

      for i in vertices(g)

        if vi2[i]==false && vi1[i]==true
          domin[i]=u
        end
      end

    end




  #=sort the node by preorder to ensure that we will testnode(v) after all of ancesstors of v,
   which mean that the last node of dominators of u  to declare itself as the dominator of u, is the immediate dominator of u=#
  ordered=Array{}([])
  function dfs1(u)
    if vi1[u]==1
      return
    end
    vi1[u]=1
    push!(ordered,u)
    for w in outneighbors(g,u)
      dfs1(w)
    end
  end
    dfs1(r)
  for i in ordered
    testnode(i)
  end


  domin[r]=0
  return domin
end

function generate_flow_digraph(n,d,seed)
  s=Vector{}([])
  push!(s,1)
  visit=zeros(Int,n)
  g=SimpleDiGraph(n)
  temp=Vector{}([])
  for ii in 1: d
    rng = MersenneTwister(seed);
    while isempty(s)!=true
      b= randn!(rng, zeros(n))
      v=pop!(s)
      for i in 1:n
        if b[i]>0.8
          add_edge!(g,v,i)
          if visit[i]==0
            push!(temp,i)
            visit[i]=1
          end
        end
      end
    end
    s=temp
    temp=[]
  end
   return g
 end

function dom_tree_test_withgraph(g::AG, source) where {T, AG<:AbstractGraph{T}}



d3=Dominator_Tree(g,source)
d2=naivedom(g,source)
d1=dominator_Tree(g,source)
@test d1==d2 && d2==d3
return
end
function domtreetest(n,d,seed)


  g=generate_flow_digraph(n,d,seed)

  dom_tree_test_withgraph(g,1)

end





















@testset "test domintor" begin

  g=LightGraphs.binary_tree(6)
  dom_tree_test_withgraph(g,1)
  domtreetest(30,3,22)
  domtreetest(100,3,123)

  domtreetest(50,4,1254)
  domtreetest(10,3,77)
  domtreetest(15,3,677)
  domtreetest(15,3,877)
  domtreetest(15,3,5)
  domtreetest(15,3,10)

  domtreetest(20,4,992)


end
