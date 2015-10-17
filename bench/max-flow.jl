function bench_maxflow(n)
    p = 8.0/n
    A = sprand(n,n,p)
    g = DiGraph(A)
    cap = round(A*100)
    @time maximum_flow(g, 1, n, cap)
end

for n in 3:13
    bench_maxflow(2^n)
end
