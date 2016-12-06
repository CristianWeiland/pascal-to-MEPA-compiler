(* GoTo inexistant label. *)
program p(input, output);
var a, b: integer;
begin
    a := 2;
    b := 5;
    goto 100;
    write(a,b)
end.
