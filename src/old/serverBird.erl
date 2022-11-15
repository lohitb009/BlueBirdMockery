%%%-------------------------------------------------------------------
%%% @author lohit
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. Nov 2022 12:56 pm
%%%-------------------------------------------------------------------
-module(serverBird).
-author("lohit").
-record(users, {uid, pwd}).

%% API
-export([startServer/0,init/0]).

%%-----Visible outside-----
%% Start the server
startServer() ->
  ServerPid = spawn(?MODULE,init,[]),
  register(?MODULE,ServerPid).

%%-----Private Only-----
init()->
  initializeObjectStore(),
  acceptState().

%% Create mnesia schema
initializeObjectStore() ->
  mnesia:create_schema([node()]),
  mnesia:start(),
  mnesia:create_table(users, [{attributes, record_info(fields, users)}]).

%%% Accept State
acceptState() ->
  receive
    {register,UserId,Pwd,ActorPid}->
      case chkUserId(UserId) of
        "False" ->
          addPair(UserId, Pwd),
          io:format("Successfully Registerd UserId  ~p ~n", [UserId]);

        "True" ->
          io:format("UserId ~p already exist ~n", [UserId])
      end;
    {login,UserId,Pwd}->
      case chkPassword(UserId,Pwd) of
        "False" ->
          io:format("Incorrect Credentials for UserId  ~p ~n", [UserId]);

        "True" ->
          io:format("UserId ~p logged in ~n", [UserId])
      end
  end.

%%% Receive Communication


%%% add key-value pair to the object-store
addPair(UserId, Pwd) ->
  Entry = #users{uid = UserId, pwd = Pwd},
  F =
    fun() ->
      mnesia:write(Entry)
    end,
  mnesia:transaction(F).

%%% chk if userId exists
chkUserId(UserId) ->
  F =
    fun() ->
      Uid = {users, UserId},
      Entry = mnesia:read(Uid),

      io:format("Entry is ~p ~n",[Entry]),

      case Entry =:= [] of
        true ->
          "False"; %% doesn't exist
        false ->
          "True"  %% already exist
      end
    end,
  mnesia:transaction(F).

%%% chk for password
chkPassword(UserId, Pwd) ->
  F =
    fun() ->
      Uid = {users, UserId},
      Entry = mnesia:read(Uid),

      io:format("Entry is ~p ~n",[Entry]),

      case Entry =:= [{users,Uid,Pwd}] of
        true ->
          "False"; %% incorrect exist
        false ->
          "True"  %% correct credentials
      end
    end,
  mnesia:transaction(F).