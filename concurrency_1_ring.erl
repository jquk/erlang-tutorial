-module(concurrency_1_ring).
-export([start/1, leader_loop/2, follower_loop/0]).

% Main function to spawn both processes and kick off the loop
start(M) ->
  % 1. Spawn the Follower process first
  FollowerPid = spawn(?MODULE, follower_loop, []),
    
  % 2. Spawn the Leader process, passing M and the Follower's Pid
  spawn(?MODULE, leader_loop, [M, FollowerPid]),
  ok.

% The Leader manages the message count M
leader_loop(0, FollowerPid) ->
  io:format("Leader: Limit reached. Telling Follower to stop.~n"),
  FollowerPid ! stop, % Tell the follower to terminate
  io:format("Leader terminating gracefully.~n");

leader_loop(M, FollowerPid) ->
  io:format("Leader sending message. Remaining rounds: ~p~n", [M]),
  FollowerPid ! {ping, self()}, % Send message to follower with Leader's Pid
    
  receive
    pong -> 
      % Wait for the reply, then loop with M - 1
      leader_loop(M - 1, FollowerPid)
  end.

% The Follower simply bounces messages back until told to stop
follower_loop() ->
  receive
    {ping, LeaderPid} ->
      io:format("Follower received ping. Bouncing it back.~n"),
      LeaderPid ! pong, % Send message back to Leader
      follower_loop(); % Keep listening
    stop ->
      io:format("Follower terminating gracefully.~n")
  end.

