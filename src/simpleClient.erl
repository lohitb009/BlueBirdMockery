%%%-------------------------------------------------------------------
%%% @author lohit
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Nov 2022 08:55 pm
%%%-------------------------------------------------------------------
-module(simpleClient).
-author("lohit").

%% API
-export([sendMessage/0]).

sendMessage() ->

  %% 1. Connect with server
  %% erl -name Client@127.0.0.1
  net_kernel:connect_node('Server@127.0.0.1'),
  {simpleServer, 'Server@127.0.0.1'} ! {ok, "Hello"},

  %% 2. Start the function
  clientInput().

clientInput() ->

  io:format("Welcome to Twitter ~n"),
  io:format("1. Register ~n"),
  io:format("2. Login ~n"),

  {ok, Input} = io:read("Enter Register or Login: "),
  io:format("You entered ~p ~n", [Input]),

  case Input of
    "Register" ->
      {ok, UserId} = io:read("Enter UserId: "),
      {ok, Password} = io:read("Enter Password: "),
      registerUser(UserId, Password);

    "Login" ->
      {ok, UserId} = io:read("Enter UserId: "),
      {ok, Password} = io:read("Enter Password: "),
      loginUser(UserId, Password)

  end.

registerUser(UserId, Password) ->
  io:format("Entered UserId is ~p ~n", [UserId]),
  io:format("Entered Password is ~p ~n", [Password]),
  {simpleServer, 'Server@127.0.0.1'} ! {register, UserId, Password, self()},
  receive
    {ok, "Registered"} ->
      %% Do login
      io:format("User is successfully registered ~n"),
      loginUser(UserId, Password);

    {ok, "UserId_exist"} ->
      io:format("User already exist ~n"),
      {ok, UserId} = io:read("Enter UserId: "),
      {ok, Password} = io:read("Enter Password: "),
      registerUser(UserId, Password)
  end.

loginUser(UserId, Password) ->
  {simpleServer, 'Server@127.0.0.1'} ! {login, UserId, Password, self()},
  receive
    {ok, "Logged In Successfully"} ->
      io:format("User Logged In Successfully~n"),
      %% go to twitter wall
      twitterWall(UserId);

    {ok, "Invalid Credentials"} ->
      io:format("Invalid Credentials ~n"),
      {ok, UserId} = io:read("Enter UserId: "),
      {ok, Password} = io:read("Enter Password: "),
      loginUser(UserId, Password)
  end.

twitterWall(UserId) ->
  %% follow the users
  %% go for tweets
  io:format("Inside Twitter ~n"),
  io:format("What do you want to do? ~n"),

  io:format("1. Follow ~n"),
  io:format("2. Tweets ~n"),

  {ok, Input} = io:read("Enter Follow or Tweets: "),
  io:format("You entered ~p ~n", [Input]),

  case Input of
    "Follow" ->
      followUsers(UserId);

    "Tweets" ->
      %% sendTweet(UserId)
      insideTwitter(UserId)
  end,
  twitterWall(UserId).

followUsers(UserId) ->
  io:format("Follow the users ~n"),
  {ok, FollowId} = io:read("Enter the follow-Id: "),

  case FollowId of
    "Done" ->
      ok;
    _ ->
      {simpleServer, 'Server@127.0.0.1'} ! {follow, UserId, FollowId},
      followUsers(UserId)
  end.

%% Inside Twitter
insideTwitter(UserId) ->
  io:format("What do you want to-do? ~n"),
  io:format("1. Feed ~n"),
  io:format("2. Post ~n"),
  {ok, Input} = io:read("Your Input: "),
  io:format("You entered ~p ~n", [Input]),
  case Input of
    "Feed" ->
      getFeed(UserId);
    "Post" ->
      sendTweet(UserId)
  end.

%% Send the tweet message
sendTweet(UserId) ->
  {ok, PostMessage} = io:read("Write your thoughts here: "),
  {simpleServer, 'Server@127.0.0.1'} ! {userPost, UserId, PostMessage, self()},
  receive
    {post, "Posted"} ->
      io:format("Message Posted ~n"),
      io:format("Your post is :~p ~n", [PostMessage])
  end.

%% Get the Feed for the user
getFeed(UserId) ->
  {simpleServer, 'Server@127.0.0.1'} ! {getFeed, UserId, self()},
  receive
    {feed, Result} ->
      {atomic,MessageBox} = Result,
      io:format("The users message box is ~p ~n",[MessageBox])
  end.