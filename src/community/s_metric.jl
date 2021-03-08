function s_metric(g::AbstractGraph)
    s = 0
    for e in edges(g)
        s += degree(g,src(e)) * degree(g,dst(e))
    end
    return s
end

function s_metric_nx(g::AbstractGraph)
    gnx = to_nx(g)
    nx.s_metric(gnx,normalized = false)
end

function smax(g::AbstractGraph)
    sm =
    return sum(degree(g).^3)/2
    s_metric(g) / sm
end

function smin(g::AbstractGraph)
    Z = vcat([fill(d,d) for d in sort(degree(g),rev=true)]...)
    return 0.5 * dot(Z,reverse(Z))
end

function smax_metric(g::AbstractGraph)
    return s_metric(g) / smax(g)
end
