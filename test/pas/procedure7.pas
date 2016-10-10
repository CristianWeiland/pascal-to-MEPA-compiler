(* Procedure com chamada recursiva. *)
program p(input, output);
var a, b: integer;
procedure p(a, c: integer);
    begin
        if(c > 1) then
        begin
            c := c - 1;
            p(1, c)
        end;
        a := c
    end;
begin
    b := 2;
    p(a, b)
end.
