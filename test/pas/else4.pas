(* Testa caso de ambiguidade (identacao errada de proposito) *)
program p(input, output);
var a: integer;
begin
    a := 1;
    if(a > 0) then
        if(a = 2) then
            a := 5
    else
        a := 3
end.
