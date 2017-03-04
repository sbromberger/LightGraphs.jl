We welcome all possible contributors and ask that you read these guidelines before starting to work on this project. Following these guidelines will reduce friction and improve the speed at which your code gets merged.

## Bug reports
If you notice code that is incorrect/crashes/too slow please file a bug report. The report should be raised as a github issue with a minimal working example that reproduces the error message. The example should include any data needed. If the problem is incorrectness, then please post the correct result along with an incorrect result.

Please include version numbers of all relevant libraries and Julia itself.

## Development guidelines

- PRs should contain one logical enhancement to the codebase.
- Squash commits in a PR.
- Open an issue to discuss a feature before you start coding (this maximizes the likelihood of patch acceptance).
- Minimize dependencies on external packages, and avoid introducing new dependencies. In general,

    - PRs introducing dependencies on core Julia packages are ok.
    - PRs introducing dependencies on non-core "leaf" packages (no subdependencies except for core Julia packages) are less ok.
    - PRs introducing dependencies on non-core non-leaf packages require strict scrutiny and will likely not be accepted without some compelling reason (urgent bugfix or much-needed functionality).

- Put type assertions on all function arguments (use abstract types, Union, or Any if necessary).
- If the algorithm was presented in a paper, include a reference to the paper (i.e. a proper academic citation along with an eprint link).
- Take steps to ensure that code works on graphs with multiple connected components efficiently.
- Correctness is a necessary requirement; efficiency is desirable. Once you have a correct implementation, make a PR so we can help improve performance.
- We can accept code that does not work for directed graphs as long as it comes with an explanation of what it would take to make it work for directed graphs.
- Style point: prefer the short circuiting conditional over if/else when convenient, and where state is not explicitly being mutated (*e.g.*, `condition && error("message")` is good; `condition && i += 1` is not).
- When possible write code to reuse memory. For example:
```julia
function f(g, v)
    storage = Vector{Int}(nv(g))
    # some code operating on storage, g, and v.
    for i in 1:nv(g)
        storage[i] = v-i
    end
    return sum(storage)
end
```
should be rewritten as two functions
```julia
function f(g::AbstractGraph, v::Integer)
    storage = Vector{Int}(nv(g))
    return inner!(storage, g, v)
end

function inner!(storage::AbstractArray{Int,1}, g::AbstractGraph, v::Integer)
    # some code operating on storage, g, and v.
    for i in 1:nv(g)
        storage[i] = v-i
    end
    return sum(storage)
end
```
This allows us to reuse the memory and improve performance.
