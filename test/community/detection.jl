n=10
g10 = CompleteGraph(n)
z = copy(g10)
for k=2:5
    z = blkdiag(z, g10)
    add_edge!(z, (k-1)*n, k*n)
    c = community_detection_nback(z, k)
    a = collect(n:n:k*n)
    @test length(c[a]) == length(unique(c[a]))
    for i=1:k
        for j=(i-1)*n+1:i*n
            @test c[j] == c[i*n]
        end
    end
end
