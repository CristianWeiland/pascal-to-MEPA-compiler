(* Procedure com 2 params por valor com sobrescrita em variavel *)
program p(input, output);
var a, b: integer;
procedure p(a, c: integer);
    begin
        c := 2
    end;
begin
    a := 2;
    b := 1
end.
