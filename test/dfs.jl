z = dfs_tree(g5,1)

@test ne(z) == 3 && nv(z) == 4
@test !has_edge(z, 1, 3)
