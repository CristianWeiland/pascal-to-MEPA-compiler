(* Funcao com recursao e atribuicao do retorno a uma variavel. *)
program p(input, output);
var a, b: integer;
function f(c: integer): integer;
    begin
        c := c-1;
        if(c > 0) then
            a := f(c);
        c := 2;
        f := 5
    end;
begin
    a := 2;
    b := 1;
    f(a)
end.
