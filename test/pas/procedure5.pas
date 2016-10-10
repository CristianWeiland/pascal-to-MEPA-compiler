(* Procedure com 1 param por valor sem sobrescrita em variavel e com outro procedure sem parametro *)
program p(input, output);
var a, b: integer;
procedure p(c: integer);
    procedure q;
        var x: integer;
        begin
            x := 2
        end;

    begin
        c := 2
    end;
begin
    a := 2;
    b := 1
end.
