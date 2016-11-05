(* GoTo variable that is not an label. *)
program p(input, output);
var a, b;
begin
    a := 2;
    b := 5;
    goto a;
    write(a,b)
end.
