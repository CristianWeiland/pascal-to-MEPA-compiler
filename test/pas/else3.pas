(* Testa if's aninhados com else *)
program p(input, output);
var a: integer;
begin
    a := 2;
    if(a = 2) then
        if(a > 1) then
            a := 1
        else
            a := 2
    else
        if(a < 2) then
            a := 5
        else
            a := 6

end.
