(* Testa caso de ambiguidade (identacao errada de proposito) *)
program p(input, output);
var a: integer;
begin
    a := 1;
    if(a > 0)
        if(a = 2)
            a := 5
    else
        a := 3
end.
