(* Procedure com 2 params por valor sem sobrescrita em variavel mas sem chamada do procedimento *)
program p(input, output);
var a, b: integer;
procedure p(c: integer; d: integer);
    begin
        c := 2
    end;
begin
    a := 2;
    b := 1
end.
