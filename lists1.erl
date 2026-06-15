-module(lists1).
-export([min/1, max/1, min_max/1]).

% MIN FUNCTIONS
% -------------
min([First | Rest]) -> min_loop(Rest, First).

min_loop([], MinSoFar) -> MinSoFar;
min_loop([Head | Tail], MinSoFar) ->
  NewMin = if
    Head < MinSoFar -> Head;
    true -> MinSoFar
  end,
  min_loop(Tail, NewMin).


% MAX FUNCTIONS
% -------------
max([First | Rest]) -> max_loop(Rest, First).

max_loop([], MaxSoFar) -> MaxSoFar;
max_loop([Head | Tail], MaxSoFar) ->
  NewMax = if
    Head > MaxSoFar -> Head;
    true -> MaxSoFar
  end,
  max_loop(Tail, NewMax).


% MINMAX FUNCTION
% ---------------
min_max([First | Rest]) -> min_max_loop(Rest, First, First).

min_max_loop([], MinSoFar, MaxSoFar) -> {MinSoFar, MaxSoFar};
min_max_loop([Head | Tail], MinSoFar, MaxSoFar) ->
  NewMin = if Head < MinSoFar -> Head; true -> MinSoFar end,
  NewMax = if Head > MaxSoFar -> Head; true -> MaxSoFar end,
  min_max_loop(Tail, NewMin, NewMax).

