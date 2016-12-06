(* Funcao simples com chamada de funcao, com expressão como parametro*)
program p(input, output);
var a, b: integer;
function f(c: integer): integer;
    begin
        a := 1;
        c := 2;
        f := 5
    end;
begin
    a := 2;
    b := 1;
    f(a - b)
end.
