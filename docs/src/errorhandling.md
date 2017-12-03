## Error Handling

In an ideal world, all software would work perfectly all the time. However, in
the real world software encounters errors due to the outside world, bad input, bugs, or
programmer error.

### Types of Errors

#### Sentinel Values
It is the position of this project that error conditions that happen often,
typically due to bad data should be handled with sentinel values returned to
indicate the failure condition. These are used for functions such as
`add_edge!(g, u, v)`. If you try to add an edge with negative vertex numbers, or
vertices that exceed the number of vertices in the graph, then you will get a
return value of `false`.

#### Errors / Exceptions

For more severe failures such as bad arguments or failure to converge, we use
exceptions. The primary distinction between Sentinel Values and Argument Errors
has to do with the run time of the function being called. In a function that is
expected to be a called in a tight loop such as `add_edge!`, we will use a
sentinel value rather than an exception. This is because it is faster to do a
simple if statement to handle the error than a full try/catch block. For
functions that take longer to run, we use Exceptions. If you find an exception
with an error message that isn't helpful for debugging, please file a bug
report so that we can improve these messages.

- ArgumentError: the inputs to this function are not valid
- InexactError: there are types that cannot express something with the necessary
  precision
