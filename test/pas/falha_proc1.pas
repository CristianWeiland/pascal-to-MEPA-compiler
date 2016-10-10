(* Procedure declara variavel local, ela tenta ser acessada no main. Erro. *)
program p(input, output);
var a: integer;
procedure p(c: integer);
    var b: integer;
    begin
        a := 1;
        c := 2
    end;
begin
    a := 2;
    b := 1
end.
