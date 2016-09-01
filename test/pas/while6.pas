(* Whiles aninhados *)
program p(input, output);
var a, b: integer;
begin
    a := 0;
    while(a < 2) do
    begin
        b := 0;
        while(b < 1) do
        begin
            b := b + 1;
            a := a + 1
        end
    end
end.
