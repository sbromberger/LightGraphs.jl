#=
a nive algorithm for fininding the dominator ,

 first if we know that u and v are dominators of some node w, then it must be that one node is a dominator of the other,
 the immidiate_dominator of some node u is the node that dominats u but is dominated by all other dominators of u,
 if y is dominated by x then it must be the case that preorder of y is smaller than x’s ,
 then the immediate dominator of u is the node that has the bigest preorder among the dominators of u,
 then  if ignor some node u, perform a dfs,and couldnot  reach some node v,then v is dominated by u,
 the biggest such a node is the immediate dominator 
 
=#
function naivedom(g,r)

  domin=Array{UInt8,1}(undef,nv(g))

  function testnode(u)
    vi2=zeros(UInt8,nv(g))
    vi2[u]=1
    function dfs2(u)
      t=vi2[u]
      if t==1
        return
      end
      vi2[u]=1

      for w in outneighbors(g,u)
        dfs2(w)
      end
    end
      dfs2(r)
      for i in vertices(g)
        if vi2[i]==0
          domin[i]=u
        end
      end
    end


  vi1=zeros(UInt8,nv(g))
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

function generate_connected_digraph(n,d,seed)
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


function domtest(n,d,seed)

#=  g=generate_connected_digraph(n,d)
  list=bfs_parents(g,1)
  println()
  ind=0
  for i in 1:nv(g)
    println(i)
    println(outneighbors(g,i))
    println(inneighbors(g,i))
  end
  d1=naivedom(g,1)
  
  for i in list
    ind+=1
    if i!=0
    print(d1[ind], " ")
  end
  end
  println()
  d2=dominator(g,1)
  
  ind=0
  for i in list
    ind+=1
    if i!=0
    print(d2[ind], " ")
  end
  end
  =#
  g=generate_connected_digraph(n,d,seed)
  list=bfs_parents(g,1)
  d1=naivedom(g,1)
  d2=Dominator_Tree(g,1)
  ind=0
  for i in list
    ind+=1
    if i!=0
      @test d1[ind]==d2[ind] 
    
  
  end
end

end


@testset "test domintor" begin
  domtest(30,3,22)
  domtest(100,3,123)

  domtest(50,4,1254)
  domtest(10,3,77)
  domtest(15,3,677)
  domtest(15,3,877)
  domtest(15,3,5)
  domtest(15,3,10)

  domtest(20,4,992)

  
end
