# These are test functions only, used for consistent centrality comparisons.
function Graph(nv::Integer, ne::Integer)
    g = Graph(nv)

    i = 1
    while i <= ne
        source = rand(1:nv)
        dest = rand(1:nv)
        e = (source, dest)
        if (source != dest) && !(has_edge(g,source,dest))
            i+= 1
            add_edge!(g,source,dest)
        end
    end
    return g
end

function DiGraph(nv::Integer, ne::Integer)
    g = DiGraph(nv)

    i = 1
    while i <= ne
        source = rand(1:nv)
        dest = rand(1:nv)
        e = (source, dest)
        if (source != dest) && !(has_edge(g,source,dest))
            i+= 1
            add_edge!(g,source,dest)
        end
    end
    return g
end

function erdos_renyi(n::Integer, p::Real; is_directed=false)
    if is_directed
        g = DiGraph(n)
    else
        g = Graph(n)
    end

    for i = 1:n
        jstart = is_directed? 1 : i
        for j = jstart : n
            if i != j && rand() <= p
                add_edge!(g, i, j)
            end
        end
    end
    return g
end

function watts_strogatz(n::Integer, k::Integer, β::Real; is_directed=false)
    @assert k < n/2
    if is_directed
        g = DiGraph(n)
    else
        g = Graph(n)
    end
    for s in 1:n
        for i in 1:(floor(Integer, k/2))
            target = ((s + i - 1) % n) + 1
            if rand() > β && !has_edge(g,s,target)
                add_edge!(g, s, target)
            else
                while true
                    d = target
                    while d == target
                        d = rand(1:(n-1))
                        if s < d
                            d += 1
                        end
                    end
                    if !has_edge(g, s, d)
                        add_edge!(g, s, d)

                        break
                    end
                end
            end
        end
    end
    return g
end
