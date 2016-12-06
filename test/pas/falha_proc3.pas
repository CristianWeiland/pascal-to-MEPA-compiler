(* Procedure com referencia e recursao. e expressão como parametro*)
program p(input, output);
var a, b: integer;
procedure p(var a: integer; c: integer);
    begin
        if(a <> 0) then
        begin
            a := a-1;
            p(a,c + a)
        end;
        a := 5
    end;
begin
    a := 2;
    b := 1;
    p(a + b, b)
end.
