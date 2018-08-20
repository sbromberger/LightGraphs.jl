"""
    eigenvector_centrality(g)

Compute the eigenvector centrality for the graph `g`.

Eigenvector centrality computes the centrality for a node based on the
centrality of its neighbors. The eigenvector centrality for node `i` is
the \$i^{th}\$ element of \$\\mathbf{x}\$ in the equation
``
    \\mathbf{Ax} = λ \\mathbf{x}
``
where \$\\mathbf{A}\$ is the adjacency matrix of the graph `g` 
with eigenvalue λ.

By virtue of the Perron–Frobenius theorem, there is a unique and positive
solution if λ is the largest eigenvalue associated with the
eigenvector of the adjacency matrix \$\\mathbf{A}\$.

### References

- Phillip Bonacich: Power and Centrality: A Family of Measures.
    American Journal of Sociology 92(5):1170–1182, 1986
    http://www.leonidzhukov.net/hse/2014/socialnetworks/papers/Bonacich-Centrality.pdf
- Mark E. J. Newman: Networks: An Introduction.
       Oxford University Press, USA, 2010, pp. 169.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> eigenvector_centrality(g)
5-element Array{Float64,1}:
 0.301511344577763
 0.30151134457776335
 0.3015113445777637
 0.6030226891555275
 0.6030226891555271
```
"""
eigenvector_centrality(g::AbstractGraph) = abs.(vec(eigs(adjacency_matrix(g), nev=1)[2]))::Vector{Float64}
