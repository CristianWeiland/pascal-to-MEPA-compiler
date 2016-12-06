(* GoTo de dentro de proc pra fora. *)
program p(input, output);
label 100;
var a, b: integer;
procedure pr(x: integer);
begin
    goto 100
end;

begin
    a := 2;
    pr(a);
    b := 5;
    100: write(a,b)
end.
