# VehicleRoutingProblems

[![Build Status](https://github.com/payakorn/VehicleRoutingProblems.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/payakorn/VehicleRoutingProblems.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/payakorn/VehicleRoutingProblems.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/payakorn/VehicleRoutingProblems.jl)


## Particle Swarm Optimization



!!! terminology "julia vs Julia"

    Strictly speaking, "Julia" refers to the language,
    and "julia" to the standard implementation.

!!! note

    This is the content of the note.

!!! warning "Beware!"

    And this is another one.

    This warning admonition has a custom title: `"Beware!"`.

Text above the line.

---

And text below the line.

```math
f(a) = \frac{1}{2\pi}\int_{0}^{2\pi} (\alpha+R\cos(\theta))d\theta
```

Here's a quote:

> Julia is a high-level, high-performance dynamic programming language for
> technical computing, with syntax that is familiar to users of other
> technical computing environments.

A code block without a "language":

```
function func(x)
    # ...
end
```

and another one with the "language" specified as `julia`:

```julia
function func(x)
    # ...
end
```

This is a paragraph.

And this is *another* paragraph containing some emphasized text.
A new line, but still part of the same paragraph.

A paragraph containing a numbered footnote [^1] and a named one [^named].

"""
    tryparse(type, str; base)

Like [`parse`](@ref), but returns either a value of the requested type,
or [`nothing`](@ref) if the string does not contain a valid number.
"""