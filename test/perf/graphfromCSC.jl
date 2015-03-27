using LightGraphs

n = 10000
p = 30/n
a = sprandbool(n, n, p)
a += a'
a = int(a)
for i = 1:n
	if a[i,i] != 0
		a[i,i] = 0
	end
end
@time fulla = full(a)
@time h = Graph(fulla)
@time h = Graph(fulla)

@time g = Graph(a)
@time g = Graph(a)
#@show a-b