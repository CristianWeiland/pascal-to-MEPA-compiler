(* Tem que conferir no MEPA - ENRT, DSVR, CHPR e RTPR. *)
program p(input, output);
var a, b: integer;
label 100;
    procedure pr(x: integer);
    label 200;
        procedure pr2(y: integer);
        begin
            goto 200
        end;
    begin
        pr2(1);
        200: goto 100
    end;
begin
    a := 2;
    pr(a);
    b := 5;
    100: write(a,b)
end.
