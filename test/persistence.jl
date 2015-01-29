
(f,fio) = mktemp()
@test write(p1, f) == (46, 69)
@test write(p1, f; compress=false) == (46, 69)
@test (ne(p2), nv(p2)) == (9, 10)
@test length(sprint(write, p1)) == 461
@test length(sprint(write, p2)) == 51

rm(f)
