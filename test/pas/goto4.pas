(* Label declaration and usage (but without gotos) test. *)
program p(input, output);
label 100,200,300;
var a, b: integer;
begin
    100: a := 2;
    200: b := 5;
    300: write(a,b)
end.
