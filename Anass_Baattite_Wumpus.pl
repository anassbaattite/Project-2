% start([1,1], [3,3], [2,3], [[1,2], [3,2], [5,1], [5,5], [2,5]], [5,5], [], 1, 1).
/* a. Room(X,Y) the room in position (x,y). You can also use a list [x,y] 
b. Breeze(R(X,Y)) there is a breeze in room R(X,Y). Can also be Breeze([x,y]) 
c. Pit((R(X,Y)) there is a pit in room R(X,Y) 
d. Wumpus(R(X,Y) the Wumpus in room R(X,Y) 
e. Stench(R(X,Y)) room R(X,Y) stenches 
f. Gold(R(X,Y)) there is gold in room R(X,Y) 
g. AdjacentTo (R(X,Y), R(ZT)) room R(T,Z) is adjacent to room R(X,Y) 
h. Safe(R(X,Y))  room R(X,Y) is safe 
i. MoveFromTo(R(X,Y), R(Z,W), t) move from room R(X,Y) to room  R(Z,W) at time t  
j. GrabGold (R(X,Y))  grab the gold in room R(X,Y) 
k. ShootWumpus(R(X,Y))  shoot the Wumpus in room R(X,Y) only from adjacent rooms  */

%the first arameter represents the location fo the agent while the second will represent (gold, pit, wumpus, or breeze). 
%the aim is to let the agent know about the adjacent rooms. 
adjacent([X, Y], [X1, Y1]) :- 
    X2 is X1 + 1,
    [X, Y] = [X2, Y1]; 
    X3 is X1 - 1,
    [X, Y] = [X3, Y1]; 
    Y2 is Y1 + 1,
    [X, Y] = [X1, Y2]; 
    Y3 is Y1 - 1,
    [X, Y] = [X1, Y3]. 

%the first paramater is a list refereing to the agent curent posiion or room, and the second represents the gold position.
gold([X, Y], [X1, Y1]) :-
    X = X1,
    Y = Y1.

% the stench means that the wumpus is near the agent, so the agent get to know about the condition of the adjacent rooms
stench(S, [X1, Y1]) :-
    adjacent(S, [X1, Y1]).


% check wumpus if is in that room [X, Y]
wumpus([X, Y], [X1, Y1]) :-
    X = X1,
    Y = Y1.

% breeze is in that room S, and the agent preceives the adjacent rooms
breeze(S, [X1, Y1]) :-
    adjacent(S, [X1, Y1]).

% the member function checks if S is in the list of pits that is already given. 
pit(S, Pits) :-
    member(S, Pits).

% this is dimentions of the map, that is a matrix of dimention M x N. is stops the agent from getting out of the map
boundry([X, Y], [M, N]) :-
    X1 is M + 1,
    X = X1;
    X = 0;
    Y1 is N + 1,
    Y = Y1;
    Y = 0.

% when wumpus location is found shot. 
shootwumpus([X, Y], WumpusRoom) :-
    WumpusRoom = [X, Y1],	% shot up
    Y1 > Y;
    WumpusRoom = [X, Y1],	% shot down
    Y1 < Y;    
    WumpusRoom = [X1, Y],	% shot right
    X1 > X;
    WumpusRoom = [X1, Y],	% shot left
	X1 < X.


% do not make actions on the boundries
makeAction(S, _, _, _, MapSize, _, _, _, _) :-
    boundry(S, MapSize),
    !.


% grab gold when founs
makeAction(S, Gold, _, _, _, Path, _, _, _) :-
    gold(S, Gold),
    append(Path, [S], GoldPath),
    write('Gold found and grabed following this path: '),
    writeln(GoldPath),
    writeln(' '),
    !.

% skips the already visited rooms by using the CUT "!" if the room 'S' is a memeber of the path
makeAction(S, _, _, _, _, Path, _, _, _) :-
    member(S, Path),
    !.

% wumpus is there
makeAction(S, _, WumpusRoom, _, _, _, AliveWumpus, _, _) :-
    AliveWumpus = 1,
    wumpus(S, WumpusRoom),
    !.

% pits is there
makeAction(S, _, _, Pits, _, _, _, _, _) :-
    pit(S, Pits),
    !.


makeAction([X, Y], Gold, WumpusRoom, Pits, MapSize, Path, AliveWumpus, Arrow, _) :-
    AliveWumpus = 1, 
    Arrow = 1,
    stench([X, Y], WumpusRoom),
    shootwumpus([X, Y], WumpusRoom),
    append(Path, [[X, Y]], WumpusPAth),
    X1 is X + 1,
    Y1 is Y + 1,
    X2 is X - 1,
    Y2 is Y - 1,
    makeAction([X1, Y], Gold, WumpusRoom, Pits, MapSize, WumpusPAth, 0, 0, _),
    makeAction([X, Y1], Gold, WumpusRoom, Pits, MapSize, WumpusPAth, 0, 0, _),
    makeAction([X2, Y], Gold, WumpusRoom, Pits, MapSize, WumpusPAth, 0, 0, _),
    makeAction([X, Y2], Gold, WumpusRoom, Pits, MapSize, WumpusPAth, 0, 0, _),
    write('Wumpus is dead at '),
    writeln(WumpusRoom),
    write('The Wumpus was killed from room'),
    writeln([X,Y]),
    write('Taking this path: '),
    writeln(WumpusPAth),
    writeln(' ').

% missed shot
makeAction([X, Y], G, WumpusRoom, Pits, MapSize, Path, AliveWumpus, Arrow, _) :-
	AliveWumpus = 1, 
    Arrow = 1,
    stench([X, Y], WumpusRoom),
    not(shootwumpus([X, Y], WumpusRoom)),
    append(Path, [[X, Y]], WumpusPath),
    X1 is X + 1,
    Y1 is Y + 1,
    X2 is X - 1,
    Y2 is Y - 1,
    makeAction([X1, Y], G, WumpusRoom, Pits, MapSize, WumpusPath, 1, 0, _),
    makeAction([X, Y1], G, WumpusRoom, Pits, MapSize, WumpusPath, 1, 0, _),
    makeAction([X2, Y], G, WumpusRoom, Pits, MapSize, WumpusPath, 1, 0, _),
    makeAction([X, Y2], G, WumpusRoom, Pits, MapSize, WumpusPath, 1, 0, _),
    writeln('Missed shoot! RUN'),
    write('Missed shoot from path: '),
    writeln(WumpusPath),
    writeln(' ').

% traversing
makeAction([X, Y], Gold, WumpusRoom, Pits, MapSize, Path, AliveWumpus, Arrow, GrabGold) :-
    append(Path, [[X, Y]], WumpusPath),
    X1 is X + 1,
    Y1 is Y + 1,
    X2 is X - 1,
    Y2 is Y - 1,
    makeAction([X1, Y], Gold, WumpusRoom, Pits, MapSize, WumpusPath, AliveWumpus, Arrow, GrabGold),
    makeAction([X, Y1], Gold, WumpusRoom, Pits, MapSize, WumpusPath, AliveWumpus, Arrow, GrabGold),
    makeAction([X2, Y], Gold, WumpusRoom, Pits, MapSize, WumpusPath, AliveWumpus, Arrow, GrabGold),
    makeAction([X, Y2], Gold, WumpusRoom, Pits, MapSize, WumpusPath, AliveWumpus, Arrow, GrabGold).


main :-     
    writeln('to run the game, enter start(
            the start location of the agent [X, Y], Gold room [X,Y], Wumpus room [X,Y], list of pits [[X,Y],[X1,Y1],[X2,Y2]...], Map dimentions [M, N], empty list fot the path [],Wumpus is alive: 1 or 0, Agent has Arrow: 1 or 0, 0
    ).'),
    writeln('Example: start(Start, Gold, WumpusRoom, Pits, MapSize, Path, AliveWumpus, Arrow, GrabGold).'),
    writeln('start([1,1], [2,4], [2,3], [[2,2], [3,2], [4,1], [4,4], [2,1]], [4,4], [], 1, 1, 0).').
:- main.
start(Start, Gold, WumpusRoom, Pits, MapSize, Path, AliveWumpus, Arrow, GrabGold) :-
    makeAction(Start, Gold, WumpusRoom, Pits, MapSize, Path, AliveWumpus, Arrow, GrabGold).
