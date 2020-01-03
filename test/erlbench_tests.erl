-module(erlbench_tests).

-include_lib("eunit/include/eunit.hrl").

timethese_test_() ->
    Tasks = [
        {
            "sleep longer",
            fun() ->
                timer:sleep(30),
                (1/3) * 3
            end
        },
        {
            "sleep none",
            fun() ->
                (1/3) * 3
            end
        },
        {
            "sleep short",
            fun() ->
                timer:sleep(5),
                (1/3) * 3
            end
        }
    ],
    {timeout, 5, fun() ->
        Results = erlbench:timethese(10, Tasks),
        ?assertMatch(
            [
                {"sleep longer", _, _},
                {"sleep short", _, _},
                {"sleep none", _, _}
            ],
            Results
        )
    end}.

format_test_() ->
    Results = [
        {"SLOWER", 1.23, 500},
        {"NORMAL", 2.46, 250},
        {"FASTER", 4.92, 125}
    ],
    register(erlbench_output_pid, self()),
    ok = erlbench:format(Results),
    Result = [
        {
            "row 1",
            "SLOWER at rate 1.230000/s is...\n"
            "\t* -50.000000% faster than NORMAL\n"
            "\t* -75.000000% faster than FASTER\n\n",
            wait()
        },
        {
            "row 2",
            "NORMAL at rate 2.460000/s is...\n"
            "\t* 100.000000% faster than SLOWER\n"
            "\t* -50.000000% faster than FASTER\n\n",
            wait()
        },
        {
            "row 3",
            "FASTER at rate 4.920000/s is...\n"
            "\t* 300.000000% faster than SLOWER\n"
            "\t* 100.000000% faster than NORMAL\n\n",
            wait()
        }
    ],
    unregister(erlbench_output_pid),
    [
        {Title, ?_assertEqual(Expected, lists:flatten(Actual))}
        || {Title, Expected, Actual} <- Result
    ].

wait() ->
    receive X -> X end.
