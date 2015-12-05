a = [1,1,1,2,2,2]
b = [1,1,1,2,2,2]
@test mutual_information(a, b, normalized=true) ≈ 1.0

n=10
g10 = CompleteGraph(n)
z = copy(g10)
for k=2:5
    z = blkdiag(z, g10)
    add_edge!(z, (k-1)*n, k*n)
    c = label_propagation(z)
    a = collect(n:n:k*n)
    a = Int[div(i-1,n)+1 for i=1:k*n]
    @test mutual_information(a, c, normalized=true) ≈ 1.0
end
