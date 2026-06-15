-module(my_time).
-export([swedish_date/0]).

swedish_date() ->
  {Year, Month, Day} = erlang:date(),
  ShortYear = Year rem 100,

  % ~n adds a newline character at the end
  io:format("~2..0w~2..0w~2..0w~n", [ShortYear, Month, Day]).

