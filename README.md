[![Build Status](https://travis-ci.com/yowcow/erlbench.svg?branch=master)](https://travis-ci.com/yowcow/erlbench)

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
    100000, % count of iterations
    [
        {"function A", fun() -> ... end},
        {"function B", fun() -> ... end},
        {"function C", fun() -> ... end}
    ]
).

erlbench:format(Result).
```
