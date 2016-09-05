(* Testa while com mais de 1 operacao *)
program p(input, output);
var a, b: integer;
begin
    a := 0;
    b := 5;
    while(a <= b) do
    begin
        a := a + b;
        a := a - 3
    end
end.
