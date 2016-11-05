(* Simple GoTo test *)
program p(input, output);
var a, b;
label 100;
begin
    a := 2;
    goto 100;
    b := 5;
    100: write(a,b)
end.
