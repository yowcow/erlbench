%%
%% @doc erlbench is a library for benchmarking functions
%%
-module(erlbench).

-export([
    timethese/2,
    format/1
]).

-type task() :: {string(), fun(() -> no_return())}.
-type result() :: {string(), float(), integer()}.

-define(NOW, erlang:system_time(nanosecond)).
-define(NANOSECS, 1000000000).

-spec timethese(non_neg_integer(), [task()]) -> [result()].
timethese(Count, Tasks) ->
    timethese(Count, Tasks, []).

timethese(_, [], Results) ->
    lists:sort(
        fun({_, _, TA}, {_, _, TB}) -> TA >= TB end,
        Results
    );
timethese(Count, [Task|L], Results) ->
    timethese(Count, L, [timethis(Count, Count, Task, ?NOW)|Results]).

-spec timethis(non_neg_integer(), non_neg_integer(), task(), integer()) -> result().
timethis(0, Count, {Title, _}, T0) ->
    Dur = ?NOW - T0,
    Rate = Count*?NANOSECS/Dur,
    {Title, Rate, Dur};
timethis(Rem, Count, {_, Fun} = Task, T0) ->
    Fun(),
    timethis(Rem - 1, Count, Task, T0).

-spec format([result()]) -> no_return().
format(Results) ->
    format(0, Results, Results).

format(_, [], _) ->
    ok;
format(Current, [{Title, Rate, Dur}|L], Results) ->
    Heading = Title ++ io_lib:format(" at rate ~f/s is...", [Rate]),
    Body = compare_results({Current, Dur}, 0, Results, ""),
    output(io_lib:format("~ts~n~ts~n", [Heading, Body])),
    format(Current + 1, L, Results).

-spec output(string()) -> no_return().
-ifdef(TEST).
output(Out) ->
    erlbench_output_pid ! Out.
-else.
output(Out) ->
    io:format("~ts", [Out]).
-endif.

compare_results(_, _, [], Acc) ->
    Acc;
compare_results({Idx, _} = Base, Idx, [_|L], Acc) ->
    compare_results(Base, Idx + 1, L, Acc);
compare_results({_, Dur} = Base, Idx, [{CTitle, _, CDur}|L], Acc) ->
    Diff = CDur - Dur,
    Acc2 = Acc++io_lib:format("\t* ~f% faster than ~ts~n", [Diff/Dur*100, CTitle]),
    compare_results(Base, Idx + 1, L, Acc2).
