suite["parallel"]["egonets"] = BenchmarkGroup(["vertex_function", "twohop", "singlethread_vertex_function", "singlethread_twohop"])

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
            a += degree(g, v)
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
g = SimpleGraph(nv_, 64 * nv_)
f = vertex_function

suite["parallel"]["egonets"]["singlethread_vertex_function"] = @benchmarkable mapvertices_single(vertex_function, $g)
suite["parallel"]["egonets"]["singlethread_twohop"] = @benchmarkable mapvertices_single(twohop, $g)
suite["parallel"]["egonets"]["vertex_function"] = @benchmarkable mapvertices(vertex_function, $g)
suite["parallel"]["egonets"]["twohop"] = @benchmarkable mapvertices(twohop, $g)
