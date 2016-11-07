(* Label declaration and usage (but without gotos) test. *)
program p(input, output);
var a, b: integer;
label 100,200;
label 300;
begin
    100: a := 2;
    200: b := 5;
    300: write(a,b)
end.
