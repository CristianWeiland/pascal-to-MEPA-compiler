(* Imprime um parametro por copia e outro por referencia *)
program p(input, output);
var a, b: integer;
procedure p(var a: integer; c: integer);
    begin
        a := a;
        c := 2;
        write(a,c)
    end;
begin
    a := 2;
    b := 1;
    p(a, b)
end.
