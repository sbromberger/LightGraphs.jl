# Contributor Guide

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

- Put type assertions on all function arguments where conflict may arise (use abstract types, Union, or Any if necessary).
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
    return f!(g, v, storage)
end

function f!(g::AbstractGraph, v::Integer, storage::AbstractVector{Int})
    # some code operating on storage, g, and v.
    for i in 1:nv(g)
        storage[i] = v-i
    end
    return sum(storage)
end
```
This gives users the option of reusing memory and improving performance.

## Git usage

In order to make it easier for you to review Pull Requests (PRs), you can add this to your git config file, which should be located at `$HOME/.julia/v0.6/LightGraphs/.git/config`. Follow the instructions [here]( https://gist.github.com/piscisaureus/3342247).

Locate the section for your github remote in the `.git/config` file. It looks like this:

```
[remote "origin"]
	fetch = +refs/heads/*:refs/remotes/origin/*
	url = git@github.com:JuliaGraphs/LightGraphs.jl.git
```

Now add the line `fetch = +refs/pull/*/head:refs/remotes/origin/pr/*` to this section. Obviously, change the github url to match your project's URL. It ends up looking like this:

```
[remote "origin"]
	fetch = +refs/heads/*:refs/remotes/origin/*
	url = git@github.com:JuliaGraphs/LightGraphs.jl.git
	fetch = +refs/pull/*/head:refs/remotes/origin/pr/*
```

Now fetch all the pull requests:

```
$ git fetch origin
From github.com:JuliaGraphs/LightGraphs.jl
 * [new ref]         refs/pull/1000/head -> origin/pr/1000
 * [new ref]         refs/pull/1002/head -> origin/pr/1002
 * [new ref]         refs/pull/1004/head -> origin/pr/1004
 * [new ref]         refs/pull/1009/head -> origin/pr/1009
...
```

To check out a particular pull request:

```
$ git checkout pr/999
Branch pr/999 set up to track remote branch pr/999 from origin.
Switched to a new branch 'pr/999'
```

Now you can test a PR by running `git fetch && git checkout pr/PRNUMBER && julia -e 'Pkg.test("LightGraphs")`
