fun cook (inf) =
let
    val ins = BinIO.openIn inf
    val all = BinIO.inputAll ins
in
    all
end;
