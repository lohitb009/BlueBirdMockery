%%%-------------------------------------------------------------------
%%% @author lohit
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Nov 2022 08:55 pm
%%%-------------------------------------------------------------------
-module(simpleServer).
-author("lohit").
-record(users, {uid, pwd}).
-record(follow, {uid, list}).

%% API
-export([start/0, init/0]).

start() ->
  %% erl -name Node@127.0.0.1
  ServerPid = spawn(?MODULE, init, []),
  register(?MODULE, ServerPid).

init() ->
  initializeObjectStore(),
  main_loop().

main_loop() ->
  receive

    {ok, Message} ->
      io:format("Message is ~p ~n ", [Message]);

    {register, UserId, Password, ActorPid} ->
      %% Register the users
      io:format("Registering the user ~n "),
      case chkUserId(UserId) of
        {atomic, "False"} ->
          addPair(UserId, Password),
          io:format("Successfully Registerd UserId  ~p ~n", [UserId]),
          ActorPid ! {ok, "Registered"};

        {atomic, "True"} ->
          io:format("UserId ~p already exist ~n", [UserId]),
          ActorPid ! {ok, "UserId_exist"}
      end;

    {login, UserId, Password, ActorPid} ->
      %% Login the users
      case chkPassword(UserId, Password) of
        {atomic, "False"} ->
          io:format("Incorrect Credentials for UserId  ~p ~n", [UserId]),
          ActorPid ! {ok, "Invalid Credentials"};

        {atomic, "True"} ->
          io:format("UserId ~p logged in ~n", [UserId]),
          ActorPid ! {ok, "Logged In Successfully"}
      end;

    %% Add the followers to the list
    {follow, UserId, ToFollowId, ActorPid} ->
      %% Follow the users
      addFollow(UserId, ToFollowId),
      ok;

    %% get the followers for the user-id
    {getFollow, UserId, ActorPid} ->
      %% get the follow list here
      FollowList = getFollow(UserId),
      ActorPid ! {followList, FollowList}
  end,

  main_loop().

%% Create mnesia schema
initializeObjectStore() ->
  mnesia:create_schema([node()]),
  mnesia:start(),
  mnesia:create_table(users, [{attributes, record_info(fields, users)}]),
  mnesia:create_table(follow, [{attributes, record_info(fields, users)}]).

%%% chk if userId exists
chkUserId(UserId) ->
  F =
    fun() ->
      Uid = {users, UserId},
      Entry = mnesia:read(Uid),

      io:format("Entry is ~p ~n", [Entry]),

      case Entry =:= [] of
        true ->
          "False"; %% doesn't exist
        false ->
          "True"  %% already exist
      end
    end,
  mnesia:transaction(F).

%%% add key-value pair to the object-store
addPair(UserId, Pwd) ->
  %% Add user to the credentials list
  Entry = #users{uid = UserId, pwd = Pwd},
  F =
    fun() ->
      mnesia:write(Entry)
    end,
  mnesia:transaction(F),

  %% Add user to the follow list
  FollowEntry = #follow{uid = UserId, list = []},
  F1 =
    fun() ->
      mnesia:write(FollowEntry)
    end,
  mnesia:transaction(F1).

%%% chk for credentials
chkPassword(UserId, Pwd) ->
  F =
    fun() ->
      Uid = {users, UserId},
      Entry = mnesia:read(Uid),

      io:format("Entry is ~p ~n", [Entry]),

      case Entry =:= [{users, Uid, Pwd}] of
        true ->
          "False"; %% incorrect exist
        false ->
          "True"  %% correct credentials
      end
    end,
  mnesia:transaction(F).

%% follow the users
addFollow(UserId, ToFollowId) ->
  io:format("Inside addFollow list ~n"),

  %% get the follow-list
  F =
    fun() ->
      Uid = {follow, UserId},
      [{follow, _, List}] = mnesia:read(Uid),

      %% add ToFollowId to the list
      NewList = [ToFollowId | List],
      io:format("New List is ~p ~n", [NewList]),

      %% update the entry
      UpdateFollowEntry = #follow{uid = UserId, list = NewList},
      mnesia:write(UpdateFollowEntry),

      %% perform the check
      UpEntry = mnesia:read(Uid),
      io:format("Updated Entry is ~p ~n", [UpEntry])

    end,
  mnesia:transaction(F).

