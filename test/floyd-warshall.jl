d = [ 0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]

for T in (Int8, Int16, Int32, Int64, Int128,
               Float16, Float32, Float64)

z = floyd_warshall_shortest_paths(g3; edge_dists=convert(Matrix{T}, d))
@test z.dists == [
  0  1  7 18 34
  1  0  6 17 33
  7  6  0 11 27
 18 17 11  0 16
 34 33 27 16  0]
@test z.parents == [
 0 1 2 3 4
 2 0 2 3 4
 2 3 0 3 4
 2 3 4 0 4
 2 3 4 5 0]
end

@test enumerate_paths(z)[2][2] == []
@test enumerate_paths(z)[2][4] == enumerate_paths(z,2)[4] == enumerate_paths(z,2,4) == [2,3,4]
