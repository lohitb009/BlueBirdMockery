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
-record(userActor, {uid, actorId}).
-record(users, {uid, pwd}).
-record(follow, {uid, list}).
-record(twitterWall, {uid, followsPost}).

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

  %% register the user
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

  %% user login
    {login, UserId, Password, ActorPid} ->
      %% Login the users
      case chkPassword(UserId, Password) of
        {atomic, "False"} ->
          io:format("Incorrect Credentials for UserId  ~p ~n", [UserId]),
          ActorPid ! {ok, "Invalid Credentials"};

        {atomic, "True"} ->
          io:format("UserId ~p logged in ~n", [UserId]),
          upsert_userActor(UserId, ActorPid), %% UserId-ActorId entry
          ActorPid ! {ok, "Logged In Successfully"}
      end;

  %% Add the followers to the list
    {follow, UserId, ToFollowId} ->
      %% Follow the users
      addFollow(UserId, ToFollowId),
      ok;

  %% get the followers for the user-id
    {getFollow, UserId, ActorPid} ->
      %% get the follow list here
      FollowList = getFollow(UserId),
      io:format("Follow-list is ~p ~n", [FollowList]),
      ActorPid ! {followList, FollowList};

  %% get the ActorId
    {getActorId, FollowUserId, ActorPid} ->
      %% get the FollowUserId's ActorId
      FollowActorId = getFollowActorId(FollowUserId),
      ActorPid ! {followActorId, FollowActorId};

  %% post from the user
    {userPost, UserId, PostMessage, ActorPid} ->
      %% get the User's followers list
      {atomic, FollowersList} = getFollow(UserId),
      %% on the basis of id add the message to the "twitterWall" of user
      addTwitterWall(FollowersList, PostMessage),
      ActorPid ! {post, "Posted"};

  %% Get the feed for the user
    {getFeed, UserId, ActorPid} ->
      %% get the users message box
      MessageBox = getMessageBox(UserId),
      ActorPid ! {feed, MessageBox}
  end,
  main_loop().

%% Create mnesia schema
initializeObjectStore() ->
  mnesia:create_schema([node()]),
  mnesia:start(),
  mnesia:create_table(userActor, [{attributes, record_info(fields, userActor)}]),
  mnesia:create_table(users, [{attributes, record_info(fields, users)}]),
  mnesia:create_table(follow, [{attributes, record_info(fields, follow)}]),
  mnesia:create_table(twitterWall, [{attributes, record_info(fields, twitterWall)}]).

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
  mnesia:transaction(F1),

  %% Add user to the twitterWall
  FollowPost = #twitterWall{uid = UserId, followsPost = []},
  F2 =
    fun() ->
      mnesia:write(FollowPost)
    end,
  mnesia:transaction(F2).

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
%% 16-11-2022; Corrected the follow logic here.
addFollow(UserId, ToFollowId) ->
  io:format("Inside addFollow list ~n"),

  %% get the follow-list
  F =
    fun() ->
      Fid = {follow, ToFollowId},
      [{follow, _, List}] = mnesia:read(Fid),

      %% add ToFollowId to the list
      NewList = [UserId | List],
      io:format("New List is ~p ~n", [NewList]),

      %% update the entry
      UpdateFollowEntry = #follow{uid = ToFollowId, list = NewList},
      mnesia:write(UpdateFollowEntry),

      %% perform the check
      UpEntry = mnesia:read(Fid),
      io:format("Updated Entry is ~p ~n", [UpEntry])

    end,
  mnesia:transaction(F).

%% get followers list
getFollow(UserId) ->
  io:format("Inside the getFollow function ~n"),
  %% get the follow-list
  F =
    fun() ->
      Uid = {follow, UserId},
      [{follow, _, List}] = mnesia:read(Uid),
      List
    end,
  mnesia:transaction(F).

%% upsert userActor list
upsert_userActor(UserId, ActorId) ->

  io:format("Upserting the pair in userActor list ~n"),
  F =
    fun() ->
      Entry = #userActor{uid = UserId, actorId = ActorId},
      mnesia:write(Entry)
    end,
  mnesia:transaction(F),

  %% show the entry
  F1 =
    fun() ->
      Uid = {userActor, UserId},
      Entry = mnesia:read(Uid),
      io:format("UserActor Entry is ~p ~n", [Entry])
    end,
  mnesia:transaction(F1).

%% get Followers ActorId
getFollowActorId(FollowUserId) ->
  %% show the entry
  F =
    fun() ->
      Uid = {userActor, FollowUserId},
      [{userActor, _, FollowActorId}] = mnesia:read(Uid),
      io:format("FollowActorId Entry is ~p ~n", [FollowActorId]),
      FollowActorId
    end,
  mnesia:transaction(F).

%%% --- For SENDING the messages to the Followers of a User
%% update the message in twitterWall
upsertMessage(FollowerId,UpdatedMessageBox)->
  F1 =
    fun() ->
      Entry = #twitterWall{uid = FollowerId, followsPost = UpdatedMessageBox},
      mnesia:write(Entry),
      Entry
    end,
  mnesia:transaction(F1).

%% get the Followers Message Box
getFollowersMessageBox(FollowerId)->
  F =
    fun() ->
      Uid = {twitterWall, FollowerId},
      Entry = mnesia:read(Uid),
      Entry
    end,
  mnesia:transaction(F).

%% chk for the message entry
chkMessageEntry(FollowerId)->
  F2 =
    fun() ->
      Uid = {twitterWall, FollowerId},
      Entry = mnesia:read(Uid),
      Entry
    end,
  mnesia:transaction(F2).

%% add the message to the twitterWall of followers
addTwitterWall([], _) ->
  done;
addTwitterWall(FollowersList, Message) ->
  %% get the followerId
  [FollowerId | Tail] = FollowersList,
  io:format("Follower Id is ~p ~n", [FollowerId]),

  %% get the MessageBox
  Entry = getFollowersMessageBox(FollowerId),
  io:format("Entry is ~p ~n",[Entry]),
  {atomic,[{twitterWall,_,MessageBox}]} = Entry,
  io:format("Message Box ~p ~n",[MessageBox]),

  %% add the message to the MessageBox
  UpdatedMessageBox = [Message] ++ MessageBox,
  io:format("Updated Message-Box is ~p ~n", [UpdatedMessageBox]),

  %% add the UpdatedMessageBox to the twitterWall
  UpsertedMessage = upsertMessage(FollowerId,UpdatedMessageBox),
  io:format("Upserted Message is  ~p ~n",[UpsertedMessage]),

  %% chk for the message entry
  Result = chkMessageEntry(FollowerId),
  io:format("Feed Check is ~p ~n",[Result]),

  %% recursively call the function for the rest
  addTwitterWall(Tail, Message).

%% get the users message-box
getMessageBox(UserId) ->
  F =
    fun() ->
      Uid = {twitterWall, UserId},
      [{twitterWall, _, MessageBox}] = mnesia:read(Uid),
      %% io:format("Message-Box is ~p ~n", [MessageBox]),
      MessageBox
    end,
  mnesia:transaction(F).
