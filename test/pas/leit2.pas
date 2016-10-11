(* Imprime duas variaveis simples em um mesmo write *)
program p (input, output);
var x, y, z, o , p : integer;
    coisa : integer;
begin
    read(x,y,coisa);
    x := 100;
    y := y;
    y := x;
    coisa := 5;
    z := p;
    write(x,y,coisa)
end.
