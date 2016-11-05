(* GoTo inexistant label. *)
program p(input, output);
var a, b;
begin
    a := 2;
    b := 5;
    goto 100;
    write(a,b)
end.
