@test adjacency_matrix(g3)[3,2]
@test !adjacency_matrix(g3)[2,4]
@test laplacian_matrix(g3)[3,2]
@test !laplacian_matrix(g3)[1,3]
@test laplacian_spectrum(g3)[5] == 2.7320508075688767
@test adjacency_spectrum(g3)[1] == -1.732050807568878
