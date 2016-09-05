(* Testa operadores = e <> em while. *)
program p(input, output);
var a: integer;
begin
    a := 0;
    while(a = 0) do
        a := 5;
    while(a <> 3) do
        a := a - 1
end.
