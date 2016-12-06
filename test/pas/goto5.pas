(* GoTo variable that is not an label. *)
program p(input, output);
var a, b: integer;
begin
    a := 2;
    b := 5;
    goto a;
    write(a,b)
end.
