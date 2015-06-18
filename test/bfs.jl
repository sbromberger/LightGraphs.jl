z = bfs_tree(g5, 1)
@test nv(z) == 4 && ne(z) == 3 && !has_edge(z, 2, 3)
