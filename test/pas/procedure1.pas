(* Procedure com 1 param por valor sem sobrescrita em variavel *)
program p(input, output);
var a, b: integer;
procedure p(c: integer);
    begin
        a := 1;
        c := 2
    end;
begin
    a := 2;
    b := 1
end.
