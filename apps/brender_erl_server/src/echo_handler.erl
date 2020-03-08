-module(echo_handler).
-include_lib("amqp_client/include/amqp_client.hrl").

-export([init/2]).

init(Req0, Opts) ->
	Method = cowboy_req:method(Req0),
	#{echo := Echo} = cowboy_req:match_qs([{echo, [], undefined}], Req0),
	Req = echo(Method, Echo, Req0),
	{ok, Req, Opts}.

echo(<<"GET">>, undefined, Req) ->
	% 172.18.0.1 is get by 
	% pata@ubuntu:~$ ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n 1 
	% just like nginx reverse proxy settings

	% 10.0.2.2 is get by ifconfig to get local gateway with virtualbox network set as NAT
	{ok, Connection} = amqp_connection:start(#amqp_params_network{host = "10.0.2.2"}),
    {ok, Channel} = amqp_connection:open_channel(Connection),

    amqp_channel:call(Channel, #'queue.declare'{queue = <<"hello">>}),

    amqp_channel:cast(Channel,
                      #'basic.publish'{
                        exchange = <<"">>,
                        routing_key = <<"hello">>},
                      #amqp_msg{payload = <<"Hello World!">>}),
    io:format(" [x] Sent 'Hello World!'~n"),
    ok = amqp_channel:close(Channel),
    ok = amqp_connection:close(Connection),

	cowboy_req:reply(400, #{}, <<"Missing echo parameter.">>, Req);
echo(<<"GET">>, Echo, Req) ->
	cowboy_req:reply(200, #{
		<<"content-type">> => <<"text/plain; charset=utf-8">>
	}, Echo, Req);
echo(_, _, Req) ->
	%% Method not allowed.
	cowboy_req:reply(405, Req).