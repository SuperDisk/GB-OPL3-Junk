:- use_module(library(clpfd)).
%% :- use_module(library(clpr)).
:- use_module(library(pure_input)).

skipB(N) --> {length(Ls, N)}, Ls.
u16(N) --> [B1, B2],
           {N in 0..65535,
            [B1, B2] ins 0..255,
            N #= (B2 << 8) + B1}.
u32(N) --> [B1, B2, B3, B4],
           {N in 0..4294967295,
            [B1, B2, B3, B4] ins 0..255,
            N #= (B4 << 24) + (B3 << 16) + (B2 << 8) + B1}.

vgm_header -->
    skipB(0x34), u16(DataOffset), {Off #= DataOffset - 2}, skipB(Off).

commands([Cmd|Cmds]) --> command(Cmd), commands(Cmds).
commands([]) --> [].

command(port0Write(Reg, Val)) --> [0x5E, Reg, Val].
command(port1Write(Reg, Val)) --> [0x5F, Reg, Val].
command(wait(Samples)) --> [0x61], u16(Samples).
command(wait(735)) --> [0x62].
command(wait(882)) --> [0x63].
command(end) --> [0x66].

vgm(Cmds) -->
    vgm_header, commands(Cmds).

%% cook(wait(Samps), wait(Ticks0)) :-
    %% {(1 / (4096 / (255 - Ticks0))) = (Samps / 44100)}. %, Ticks is truncate(Ticks0).

cook(wait(Samps), Waits) :-
    Ms0 is (Samps/44100)*1000,
    Ms is truncate(Ms0), % impurity
    cook_ms(Ms, Waits).
cook(port0Write(Reg, Val), [port0Write(Reg, Val)]).
cook(port1Write(Reg, Val), [port1Write(Reg, Val)]).
cook(end, [end]).

cook_ms(Ms, [wait(Div)]) :-
    Ms #=< 62,
    ms_div(Ms, Div).

cook_ms(Ms, [wait(Div) | Rest]) :-
    Ms #> 62,
    ms_div(62, Div),
    Ms1 #= Ms - 62,
    cook_ms(Ms1, Rest).

dumpb(X) :-
    open('output2.vgm',write,Out,[type(binary)]),
    maplist(put_byte(Out), X),
    close(Out).

load(X) :- phrase_from_file(vgm(X), "output.vgm", [type(binary)]).

dostuf :-
    load(X),
    maplist(cook, X, Y),
    append(Y, Z),
    phrase(commands(Z), Bytes),
    dumpb(Bytes).

ms_div(62, 3).
ms_div(61, 7).
ms_div(60, 11).
ms_div(59, 15).
ms_div(58, 19).
ms_div(57, 23).
ms_div(56, 27).
ms_div(55, 31).
ms_div(54, 35).
ms_div(53, 39).
ms_div(52, 44).
ms_div(51, 48).
ms_div(50, 52).
ms_div(49, 56).
ms_div(48, 60).
ms_div(47, 64).
ms_div(46, 68).
ms_div(45, 72).
ms_div(44, 76).
ms_div(43, 80).
ms_div(42, 85).
ms_div(41, 89).
ms_div(40, 93).
ms_div(39, 97).
ms_div(38, 101).
ms_div(37, 105).
ms_div(36, 109).
ms_div(35, 113).
ms_div(34, 117).
ms_div(33, 121).
ms_div(32, 125).
ms_div(31, 130).
ms_div(30, 134).
ms_div(29, 138).
ms_div(28, 142).
ms_div(27, 146).
ms_div(26, 150).
ms_div(25, 154).
ms_div(24, 158).
ms_div(23, 162).
ms_div(22, 166).
ms_div(21, 171).
ms_div(20, 175).
ms_div(19, 179).
ms_div(18, 183).
ms_div(17, 187).
ms_div(16, 191).
ms_div(15, 195).
ms_div(14, 199).
ms_div(13, 203).
ms_div(12, 207).
ms_div(11, 211).
ms_div(10, 216).
ms_div(9, 220).
ms_div(8, 224).
ms_div(7, 228).
ms_div(6, 232).
ms_div(5, 236).
ms_div(4, 240).
ms_div(3, 244).
ms_div(2, 248).
ms_div(1, 252).
ms_div(0, 254).
