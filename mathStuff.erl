-module(mathStuff).
-export([perimeter/2]).

square_perimeter(Side) -> Side*4.
circle_perimeter(Radius) -> Radius*3.14159.
triangle_perimeter(Side) -> 3*Side.

perimeter(Form, Value) ->
  case Form of
    "square" -> square_perimeter(Value);
    "circle" -> circle_perimeter(Value);
    "triangle" -> triangle_perimeter(Value);
    _Other -> {error, unknown_form}
  end.
