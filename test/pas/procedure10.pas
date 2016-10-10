(* Procedure com referencia e recursao invertida reversa ao contrario. *)
program p(input, output);
var a, b: integer;
procedure p(var a: integer; c: integer);
    begin
        if(a <> 0) then
        begin
            a := a-1;
            p(c,a)
        end;
        a := 5
    end;
begin
    a := 2;
    b := 1;
    p(a, 1)
end.
