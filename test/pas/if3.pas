(* Testa if's aninhados (sem else) *)
program p(input, output);
var a: integer;
begin
    a := 2;
    if(a = 2) then
        if(a > 1) then
            a := 1
end.
