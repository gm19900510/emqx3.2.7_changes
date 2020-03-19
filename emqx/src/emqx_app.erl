%% Copyright (c) 2013-2019 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(emqx_app).

-behaviour(application).

-export([ start/2
        , stop/1
        ,loop/0
        ,call/1]).

-define(APP, emqx).

%%--------------------------------------------------------------------
%% Application callbacks
%%--------------------------------------------------------------------
call(M) ->
    emqx ! M.

loop() ->
    logger:error("waiting new message", []),
    receive
        M -> 
            io:format("new message: ~p ~n ~n", [M]),
            logger:error("new message: ~p", [M]),
            emqx_listeners:stop_listener(tcp,{"127.0.0.1",11883},[]),
	    %%emqx_listeners:start_listener({tcp,{"127.0.0.1", 17087}, []}),
            %%io:format("listeners: ~w ~n~n", [application:get_env(emqx,listeners, [])]),
            %%io:format("get_env: ~w ~n~n", [application:get_env(emqx, tcp)]),
            %%application:set_env(emqx, tcp, 12883),
            %%io:format("info: ~w ~n~n", [application:info()]),
            %%io:format("get_application: ~w ~n~n", [application:get_application(self())]),
            %%io:format("get_env: ~w ~n~n", [application:get_env(emqx, tcp)]),
            %%io:format("listeners: ~w ~n~n", [application:get_env(emqx,listeners, [])]),
            %%emqx_listeners:stop(),
            emqx_listeners:start()
            %%loop()
    end.

start(_Type, _Args) ->
    %%{Udp_Result, Socket} = gen_udp:open(18104, [binary]),
    %%io:format("Udp_Result = ~w Socket = ~w ~n", [Udp_Result,Socket]),
    print_banner(),
    ekka:start(),
    {ok, Sup} = emqx_sup:start_link(),
    emqx_modules:load(),
    emqx_plugins:init(),
    emqx_plugins:load(),
    %%emqx_listeners:start(),
    emqx_listeners:start_listener({tcp,{"127.0.0.1",11883} , [{deflate_options,[]},{tcp_options,[{backlog,512},{send_timeout,5000},{send_timeout_close,true},{nodelay,false},{reuseaddr,true}]},{acceptors,4},{max_connections,1024000},{max_conn_rate,1000},{active_n,1000},{zone,internal}]}),
    logger:error("complete listener: ~p", [11883]),    
    start_autocluster(),
    
    %%register(emqx, spawn(?MODULE, loop, [Socket])),
    register(emqx, spawn(?MODULE, loop, [])),
    emqx_alarm_handler:load(),
    print_vsn(),
    %%call("123123123"),
    {ok, Sup}.

-spec(stop(State :: term()) -> term()).
stop(_State) ->
    emqx_alarm_handler:unload(),
    emqx_listeners:stop(),
    emqx_modules:unload().

%%--------------------------------------------------------------------
%% Print Banner
%%--------------------------------------------------------------------

print_banner() ->
    io:format("Starting ~s on node ~s~n", [?APP, node()]).

print_vsn() ->
    {ok, Descr} = application:get_key(description),
    {ok, Vsn} = application:get_key(vsn),
    io:format("~s ~s is running now!~n", [Descr, Vsn]).

%%--------------------------------------------------------------------
%% Autocluster
%%--------------------------------------------------------------------

start_autocluster() ->
    ekka:callback(prepare, fun emqx:shutdown/1),
    ekka:callback(reboot,  fun emqx:reboot/0),
    ekka:autocluster(?APP).

