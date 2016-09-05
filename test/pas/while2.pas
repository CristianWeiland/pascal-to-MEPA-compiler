(* Testa operadores >, <=, >=. *)
program p(input, output);
var a: integer;
begin
    a := 3;
    while(a > 0) do
        a := a - 1;
    while(a <= 2) do
        a := a + 1;
    while(a >= 1) do
        a := a - 1
end.
