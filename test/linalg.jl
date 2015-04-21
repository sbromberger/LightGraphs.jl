@test adjacency_matrix(g3)[3,2] == 1
@test adjacency_matrix(g3)[2,4] == 0
@test laplacian_matrix(g3)[3,2] == -1
@test laplacian_matrix(g3)[1,3] == 0
@test laplacian_spectrum(g3)[5] == 3.6180339887498945
@test adjacency_spectrum(g3)[1] == -1.732050807568878
@test pagerank(g5)[3] == 0.3175410567582492
@test_throws ErrorException pagerank(g5, 2)
@test_throws ErrorException pagerank(g5, 0.85, 2)
