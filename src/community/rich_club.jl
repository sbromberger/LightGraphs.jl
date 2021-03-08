function rich_club(g::AbstractGraph,k::Int)
    E = 0
    for e in edges(g)
        if (degree(g,src(e)) >= k) && (degree(g,dst(e)) >= k )
            E +=1
        end
    end
    N = count(degree(g) .>= k)
    return 2*E / (N*(N-1))
end
