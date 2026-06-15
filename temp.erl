-module(temp).
-export([convert/2]).

f2c(F) -> (F-32)*5/9.
c2f(C) -> C*(9/5)+32.

convert(Unit, Value) ->
	case Unit of
		"celsius" ->
			c2f(Value);
		"farenheit" ->
			f2c(Value);
		"c" ->
			c2f(Value);
		"f" ->
			f2c(Value);
		_Other -> {error, unknown_unit}
	end.
