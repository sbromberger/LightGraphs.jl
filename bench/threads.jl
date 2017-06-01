using LightGraphs
using BenchmarkTools
@show Threads.nthreads()

function vertex_function(g::Graph, i::Int)
    a = 0
    for u in neighbors(g, i)
        a += degree(g, u)
    end
    return a
end

function twohop(g::Graph, i::Int)
    a = 0
    for u in neighbors(g, i)
        for v in neighbors(g, u)
            a += degree(g,v)
        end
    end
    return a
end


function mapvertices(f, g::Graph)
    n = nv(g)
    a = zeros(Int, n)
    Threads.@threads for i in 1:n
        a[i] = f(g, i)
    end
    return a
end

function mapvertices_single(f, g)
    n = nv(g)
    a = zeros(Int, n)
    for i in 1:n
        a[i] = f(g, i)
    end
    return a
end

nv_ = 10000
g = Graph(nv_, 64*nv_)
f = vertex_function
println(g)

function comparison(f, g)
  println("Mulithreaded on $(Threads.nthreads())")
  b1 =  @benchmark mapvertices($f, $g)
  println(b1)

  println("singlethreaded")
  b2 = @benchmark mapvertices_single($f, $g)
  println(b2)
  println("done")
end

comparison(vertex_function, g)
comparison(twohop, g)
