(* Simple GoTo test *)
program p(input, output);
label 100;
var a, b: integer;
begin
    a := 2;
    goto 100;
    b := 5;
    100: write(a,b)
end.
