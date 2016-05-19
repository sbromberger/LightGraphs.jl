
<a id='Operators-1'></a>

# Operators


*LightGraphs.jl* implements the following graph operators. In general, functions with two graph arguments will require them to be of the same type (either both `Graph` or both `DiGraph`).

<a id='Base.complement' href='#Base.complement'>#</a>
**`Base.complement`** &mdash; *Function*.



```rst
..  complement(s)

Returns the set-complement of :obj:`IntSet` ``s``.
```

```
complement(g)
```

Produces the [graph complement](https://en.wikipedia.org/wiki/Complement_graph) of a graph.

<a id='Base.reverse' href='#Base.reverse'>#</a>
**`Base.reverse`** &mdash; *Function*.



```
reverse(s::AbstractString) -> AbstractString
```

Reverses a string

```
reverse(v [, start=1 [, stop=length(v) ]] )
```

Return a copy of `v` reversed from start to stop.

```
reverse(g::DiGraph)
```

Produces a graph where all edges are reversed from the original.

<a id='Base.reverse!' href='#Base.reverse!'>#</a>
**`Base.reverse!`** &mdash; *Function*.



```rst
..  reverse!(v [, start=1 [, stop=length(v) ]]) -> v

In-place version of :func:`reverse`.
```

```
reverse!(g::DiGraph)
```

In-place reverse (modifies the original graph).

<a id='Base.SparseMatrix.blkdiag' href='#Base.SparseMatrix.blkdiag'>#</a>
**`Base.SparseMatrix.blkdiag`** &mdash; *Function*.



```
blkdiag(A...)
```

Concatenate matrices block-diagonally. Currently only implemented for sparse matrices.

```
blkdiag(g, h)
```

Produces a graph with $|V(g)| + |V(h)|$ vertices and $|E(g)| + |E(h)|$ edges.

Put simply, the vertices and edges from graph `h` are appended to graph `g`.

<a id='Base.union' href='#Base.union'>#</a>
**`Base.union`** &mdash; *Function*.



```
union(s1,s2...)
∪(s1,s2...)
```

Construct the union of two or more sets. Maintains order with arrays.

```
union(g, h)
```

Merges graphs `g` and `h` by taking the set union of all vertices and edges.

<a id='Base.intersect' href='#Base.intersect'>#</a>
**`Base.intersect`** &mdash; *Function*.



```
intersect(s1,s2...)
∩(s1,s2)
```

Construct the intersection of two or more sets. Maintains order and multiplicity of the first argument for arrays and ranges.

```
intersect(g, h)
```

Produces a graph with edges that are only in both graph `g` and graph `h`.

Note that this function may produce a graph with 0-degree vertices.

<a id='LightGraphs.difference' href='#LightGraphs.difference'>#</a>
**`LightGraphs.difference`** &mdash; *Function*.



```
difference(g, h)
```

Produces a graph with edges in graph `g` that are not in graph `h`.

Note that this function may produce a graph with 0-degree vertices.

<a id='LightGraphs.symmetric_difference' href='#LightGraphs.symmetric_difference'>#</a>
**`LightGraphs.symmetric_difference`** &mdash; *Function*.



```
symmetric_difference(g, h)
```

Produces a graph with edges from graph `g` that do not exist in graph `h`, and vice versa.

Note that this function may produce a graph with 0-degree vertices.

<a id='LightGraphs.induced_subgraph' href='#LightGraphs.induced_subgraph'>#</a>
**`LightGraphs.induced_subgraph`** &mdash; *Function*.



```
induced_subgraph(g, iter)
```

Filters graph `g` to include only the vertices present in the iterable argument `vs`. Returns the subgraph of `g` induced by `vs`.

<a id='Base.join' href='#Base.join'>#</a>
**`Base.join`** &mdash; *Function*.



```
join(strings, delim, [last])
```

Join an array of `strings` into a single string, inserting the given delimiter between adjacent strings. If `last` is given, it will be used instead of `delim` between the last two strings. For example, `join(["apples", "bananas", "pineapples"], ", ", " and ") == "apples, bananas and pineapples"`.

`strings` can be any iterable over elements `x` which are convertible to strings via `print(io::IOBuffer, x)`.

```
join(g, h)
```

Merges graphs `g` and `h` using `blkdiag` and then adds all the edges between  the vertices in `g` and those in `h`.

<a id='LightGraphs.tensor_product' href='#LightGraphs.tensor_product'>#</a>
**`LightGraphs.tensor_product`** &mdash; *Function*.



```
tensor_product(g, h)
```

Returns the (tensor product)[https://en.wikipedia.org/wiki/Tensor_product_of_graphs] of `g` and `h`

<a id='LightGraphs.cartesian_product' href='#LightGraphs.cartesian_product'>#</a>
**`LightGraphs.cartesian_product`** &mdash; *Function*.



```
cartesian_product(g, h)
```

Returns the (cartesian product)[https://en.wikipedia.org/wiki/Tensor_product_of_graphs] of `g` and `h`

<a id='LightGraphs.crosspath' href='#LightGraphs.crosspath'>#</a>
**`LightGraphs.crosspath`** &mdash; *Function*.



```
crosspath(len::Integer, g::Graph)
```

Replicate `len` times `h` and connect each vertex with its copies in a path

