%%%-------------------------------------------------------------------
%% @doc brender_erl_server public API
%% @end
%%%-------------------------------------------------------------------

-module(brender_erl_server_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    io:format("this is a ~s ~n", ["hello world"]),

    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", echo_handler, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http, [{port, 9000}], #{
        env => #{dispatch => Dispatch}
    }),
    
    brender_erl_server_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
