(*Procedure sem params sem sobrescrita em variavel*)
program p(input, output);
var a, b: integer;
procedure p;
    begin
        a := 2+1
    end;
begin
    a := 2;
    p;
    b := 1
end.
