
f = IOBuffer()
@test write(f,p1) == (46, 69)
@test (ne(p2), nv(p2)) == (9, 10)
