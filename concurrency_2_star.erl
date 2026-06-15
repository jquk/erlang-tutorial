-module(concurrency_2_star).
-export([start/2, worker/0]).

% Main entry point
start(N, M) ->
  io:format("Starting star topology with ~p workers...~n", [N]),
  % Step 1: Spawn N worker processes
  Workers = [spawn(?MODULE, worker, []) || _ <- lists:seq(1, N)],
    
  % Step 2: Send M messages to each worker
  io:format("Sending ~p messages to each worker...~n", [M]),
  [send_messages(Worker, M) || Worker <- Workers],
    
  % Step 3: Tell each worker to stop gracefully
  io:format("Stopping workers gracefully...~n"),
  [Worker ! stop || Worker <- Workers],
  ok.

% Helper function to send M messages to a single worker
send_messages(_Worker, 0) -> 
  ok;
send_messages(Worker, Count) ->
  Worker ! {msg, "Hello"},
  send_messages(Worker, Count - 1).

% Worker process loop
worker() ->
  receive
    {msg, Text} ->
      io:format("Worker ~p received: ~p~n", [self(), Text]),
      worker(); % Loop to wait for more messages
    stop ->
      io:format("Worker ~p terminating gracefully.~n", [self()]),
      ok % Terminate the process loop
  end.

