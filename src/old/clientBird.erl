%%%-------------------------------------------------------------------
%%% @author lohit
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. Nov 2022 02:16 pm
%%%-------------------------------------------------------------------
-module(clientBird).
-author("lohit").
-define(Port, 8082).

%% API
-export([startClient/0, registerAccount/2]).

%% -----Exposed Function ----
%% communication with the server
startClient() ->
  io:format("Welcome to Blue Bird ~n"),
  net_kernel:connect_node('Server@127.0.0.1'),
  nodes(),
  receive
    {register, UserId, Password} ->
      registerAccount(UserId, Password)
%%  ;
%%
%%    {login, UserId, Password} ->
%%      loginAccount(UserId, Password)
  end.


%% -----Internal Function----
%% client-server connection
%%clientSocket(String) ->
%%  {ok, Socket} = gen_tcp:connect("localhost", ?Port, [binary, {active, true}]),
%%  io:format("Socket ~p ~n", [Socket]),
%%  gen_tcp:send(Socket, list_to_binary(String)).


%% Register Client
registerAccount(UserId, Password) ->
  net_kernel:connect_node('Server@127.0.0.1'),
  {serverBird,'Server@127.0.0.1'} ! {register,UserId,Password,self()},
  ok.
%%  String = "Register" ++ "-" ++ UserId ++ "-" ++ Password,
%%  clientSocket(String).

%% Login to the Account
%%loginAccount(UserId, Password) ->
%%  String = "Login" ++ "-" ++ UserId ++ "-" ++ Password,
%%  clientSocket(String).