(* Procedures aninhadas com parametro de mesmo nome. *)
program p(input, output);
var a, b: integer;
procedure p(c: integer);
    procedure q(c: integer);
        var x: integer;
        begin
            c := 1;
            x := 2
        end;
    begin
        c := 2
    end;
begin
    a := 2;
    b := 1
end.
