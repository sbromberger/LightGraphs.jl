function Dominator_Tree(g::AG, source) where {T, AG<:AbstractGraph{T}}

  parent=zeros(T,nv(g))
  size=ones(T,nv(g))

  
  #= the semi dominator is the first elemnt on the path between the root and the node of interst, 
  such that  there is at least two disjoint paths between it and the node of interst ,
  if there is not such a node we will consider the parent of the node of interst to be the semi dominator of it
   there is a duality between the semi dominator and the  immediate dominator 
   min(preorderof(semi_dominator(v)))>=max(preorder(dominator(v)) 
   for more details see the paper
   the key theorm is 
   Let w != the source and let u be a vertex for which semi_dominator(u) is minimum 
   among vertices between w and its semi dominator. 
   Then the immediate dominator is  
   semi_dominator(w) if semi_dominator(w) = semi_dominator(u), 
   immidiate_dominator(w) =  immidiate_dominator(u) otherwise.
  =#
  semi=zeros(T,nv(g))
  #==# 
   
  #=
   we will store each node in the bucket of its semi dominator,
   untill we we figure out all the semi dominator of the nodes between them 
  =#       
     
  buctes=Array{Array,1}(undef,nv(g)) 

  verticesar=zeros(T,nv(g)) #map between each preorder of a node and its real name 
  dom=zeros(T,nv(g))        #the immediate dominator of the the node 
  #=
  one important step in the algorithm is to know a  vertex u for which semi_dominator(u) is minimum 
  among vertices between every node and its semi dominator,
  after we order the vertices by preorder, we will scan them backwards,
  then we can imagine the graph as a forest of trees, in each step we merge two trees by making the root of one tree the 
  child of the root of the other tree, now we decoverd another child of the later root,let it be w
  then we will see if there is node u that consider w to be its semi dominator, and look for the smalest smei dominator in the path between w and u
  we can leverage some facts
  - we donot need to travel all the path each time, we can do path decompsion
  - each time we do a merge one of the two trees will not be affected at all, 
  in the other tree if there is a node that has semi dominator smaller than the new root itse descendants will not be affected
      
  =#
  
  childs=zeros(T,nv(g)) # the  child u of a node w of the the node that its suntree has a big size and its has a semi_dominator snaller than w 
  ancesstor=zeros(T,nv(g)) # the  ancesstor u of node w is the cuurent parent of w in the forest  
  labels=zeros(T,nv(g))       # the label u of node w is the result of accumalteing some of its parents nodes in the operation of path decompostion 

  parent[source]=1
  #find the the node u the has the smalest semi_dominator in the path between v and the current root of its subtree in the current forest
  function eval(v)

    s=v
    parents=ancesstor[s]
    vstack=Vector{Int32}([])

    if parents==0
      return labels[s]
    end
    while ancesstor[parents]!=0
          push!(vstack,s)
          s=parents
          parents=ancesstor[parents]
        end
        boss=parents
        parents=s
        len=length(vstack)
        while len!=0
          len-=1
          s=pop!(vstack)
          if semi[labels[s]]>semi[labels[parents]]
             labels[s]=labels[parents]
          end
          ancesstor[s]=boss
          parents=s
        end
        if semi[labels[v]]<semi[labels[ancesstor[v]]]
          return labels[v]
        else
          return labels[ancesstor[v]]
        end
  end




  #make w a child of v that we will merge the subtree of w into the subtree of v

  function link(v,w)

      s=w
      newsemi=semi[labels[w]]
      while childs[s]!=0 && semi[labels[childs[s]]]>newsemi
        s2=childs[childs[s]]
        s2= s2==0 ? 0 : size[s2]
        if size[s]+s2>=2*size[childs[s]]
          ancesstor[childs[s]]=s
          childs[s]=childs[childs[s]]
       else
         size[childs[s]]=size[s]
         s=ancesstor[s]=childs[s]
       end
     end
     labels[s]=labels[w]
     size[v]+=size[w]
     if size[v]<2*size[w]
       s,childs[v]=childs[v],s
     end
     while s!=0
       ancesstor[s]=v
       s=childs[s]
     end
   end








  counter=Int(0)


  function dfs(v)
    counter=counter+1
    semi[v]=counter
    labels[v]=v
    verticesar[Int(counter)]=v
    buctes[v]=Array{T}([])
    for w in outneighbors(g,v)
      if parent[w]==0
        parent[w]=v
        dfs(w)
      end
    end

    end
    dfs(source)

    x=counter
    while x >= 2
      w=verticesar[x]
      for u in inneighbors(g,w)
          z=eval(u)
          z==0 && continue
          if semi[z]<semi[w]
            semi[w]=semi[z]
          end
        end
        push!(buctes[verticesar[semi[w]]],w)
        p=parent[w]
        link(p,w)

        
        le=length(buctes[p])
        while le>0
          z=pop!(buctes[p])
          y=eval(z)
          if semi[y]<semi[p]
            dom[z]=y
          else
            dom[z]=p

          end
          le-=1
        end
      x-=1
    end


    for i in 2:counter
      v=verticesar[i]
      if verticesar[semi[v]]!=dom[v]
        dom[v]=dom[dom[v]]
      end
    end
    dom[source]=0
    return dom
  end
