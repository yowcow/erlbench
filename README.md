erlbench
========

A benchmarking library to compare performance of functions.

Build
-----

    $ rebar3 compile

How to Use
----------

In erlang shell or so, do:

```erlang
Result = erlbench:timethese(
    100000, % count of iteratios
    [
        {"function A", fun() -> ... end},
        {"function B", fun() -> ... end},
        {"function C", fun() -> ... end}
    ]
).

erlbench:format(Result).
```
