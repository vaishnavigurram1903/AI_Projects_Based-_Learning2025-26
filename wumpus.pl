% WUMPUS WORLD - Prolog Implementation
% Classic AI logic programming example (SWI-Prolog)

% ============================================================================
% CAVE STRUCTURE - Dodecahedron (20 rooms)
% ============================================================================

adjacent(0, 1). adjacent(0, 4). adjacent(0, 7).
adjacent(1, 0). adjacent(1, 2). adjacent(1, 9).
adjacent(2, 1). adjacent(2, 3). adjacent(2, 11).
adjacent(3, 2). adjacent(3, 4). adjacent(3, 13).
adjacent(4, 0). adjacent(4, 3). adjacent(4, 5).
adjacent(5, 4). adjacent(5, 6). adjacent(5, 14).
adjacent(6, 5). adjacent(6, 7). adjacent(6, 16).
adjacent(7, 0). adjacent(7, 6). adjacent(7, 8).
adjacent(8, 7). adjacent(8, 9). adjacent(8, 17).
adjacent(9, 1). adjacent(9, 8). adjacent(9, 10).
adjacent(10, 9). adjacent(10, 11). adjacent(10, 18).
adjacent(11, 2). adjacent(11, 10). adjacent(11, 12).
adjacent(12, 11). adjacent(12, 13). adjacent(12, 19).
adjacent(13, 3). adjacent(13, 12). adjacent(13, 14).
adjacent(14, 5). adjacent(14, 13). adjacent(14, 15).
adjacent(15, 14). adjacent(15, 16). adjacent(15, 19).
adjacent(16, 6). adjacent(16, 15). adjacent(16, 17).
adjacent(17, 8). adjacent(17, 16). adjacent(17, 18).
adjacent(18, 10). adjacent(18, 17). adjacent(18, 19).
adjacent(19, 12). adjacent(19, 15). adjacent(19, 18).

% ============================================================================
% GAME STATE PREDICATES
% ============================================================================

:- dynamic(player_location/1).
:- dynamic(wumpus_location/1).
:- dynamic(pit_location/1).
:- dynamic(bats_location/1).
:- dynamic(gold_location/1).
:- dynamic(visited/1).
:- dynamic(arrows/1).
:- dynamic(has_gold/0).
:- dynamic(game_over/0).
:- dynamic(wumpus_alive/0).

% ============================================================================
% INITIAL GAME STATE
% ============================================================================

init_game :-
    retractall(player_location(_)),
    retractall(wumpus_location(_)),
    retractall(pit_location(_)),
    retractall(bats_location(_)),
    retractall(gold_location(_)),
    retractall(visited(_)),
    retractall(arrows(_)),
    retractall(has_gold),
    retractall(game_over),
    retractall(wumpus_alive),

    assert(player_location(0)),
    assert(wumpus_location(15)),
    assert(pit_location(3)),
    assert(pit_location(12)),
    assert(bats_location(8)),
    assert(bats_location(16)),
    assert(gold_location(10)),
    assert(visited(0)),
    assert(arrows(3)),
    assert(wumpus_alive),
    write('Game initialized! You are in room 0.'), nl,
    status.

% ============================================================================
% SENSOR RULES - What the player perceives
% ============================================================================

stench(Room) :-
    wumpus_location(WumpusRoom),
    wumpus_alive,              % only if Wumpus alive
    adjacent(Room, WumpusRoom).

breeze(Room) :-
    pit_location(PitRoom),
    adjacent(Room, PitRoom).

rustling(Room) :-
    bats_location(BatRoom),
    adjacent(Room, BatRoom).

glitter(Room) :-
    gold_location(Room).

% ============================================================================
% MOVEMENT RULES (prevent actions if game over)
% ============================================================================

move(ToRoom) :-
    game_over,
    write('Game is over. Start a new game with init_game.'), nl,
    !, fail.

move(ToRoom) :-
    player_location(CurrentRoom),
    adjacent(CurrentRoom, ToRoom),
    retract(player_location(CurrentRoom)),
    assert(player_location(ToRoom)),
    ( visited(ToRoom) -> true ; assert(visited(ToRoom)) ),
    write('Moved to room '), write(ToRoom), nl,
    check_room_contents(ToRoom),
    % Only report perceptions for the player's current location (in case bats moved player)
    player_location(Actual), report_perceptions(Actual).

move(ToRoom) :-
    player_location(CurrentRoom),
    \+ adjacent(CurrentRoom, ToRoom),
    write('Cannot move to room '), write(ToRoom),
    write(' from room '), write(CurrentRoom), nl.

% ============================================================================
% ROOM CONTENT CHECKS
% ============================================================================

check_room_contents(Room) :-
    ( wumpus_location(Room), wumpus_alive ->
        write('You were eaten by the Wumpus! Game Over.'), nl,
        assert(game_over)
    ; pit_location(Room) ->
        write('You fell into a pit! Game Over.'), nl,
        assert(game_over)
    ; bats_location(Room) ->
        write('Bats carried you to another room!'), nl,
        % pick a random room among all rooms except current to avoid immediate loop
        findall(R, between(0,19,R), AllRooms),
        random_member(NewRoom, AllRooms),
        retract(player_location(Room)),
        assert(player_location(NewRoom)),
        ( visited(NewRoom) -> true ; assert(visited(NewRoom)) ),
        write('You are now in room '), write(NewRoom), nl,
        true
    ; gold_location(Room) ->
        write('You found the gold!'), nl,
        ( has_gold -> true ; assert(has_gold) )
    ; true
    ).

% ============================================================================
% PERCEPTION REPORTING
% ============================================================================

report_perceptions(Room) :-
    write('In room '), write(Room), write(': '),
    ( stench(Room) -> write('You smell a stench. ') ; true ),
    ( breeze(Room) -> write('You feel a breeze. ') ; true ),
    ( rustling(Room) -> write('You hear rustling. ') ; true ),
    ( glitter(Room) -> write('You see a glitter! ') ; true ),
    nl.

% ============================================================================
% SHOOTING RULES
% ============================================================================

shoot(_) :-
    game_over,
    write('Game is over. Start a new game with init_game.'), nl,
    !, fail.

shoot(TargetRoom) :-
    arrows(N),
    N > 0,
    player_location(CurrentRoom),
    adjacent(CurrentRoom, TargetRoom),
    NewArrows is N - 1,
    retract(arrows(N)),
    assert(arrows(NewArrows)),
    ( wumpus_location(TargetRoom), wumpus_alive ->
        write('You killed the Wumpus! Victory!'), nl,
        % remove wumpus_alive fact
        retractall(wumpus_alive),
        assert(game_over)
    ; 
        write('You missed! '), nl,
        ( NewArrows > 0 ->
            write('You have '), write(NewArrows), write(' arrows left.'), nl
        ;
            write('You are out of arrows! The Wumpus ate you.'), nl,
            assert(game_over)
        )
    ).

shoot(_) :-
    arrows(0),
    write('You have no arrows left!'), nl.

shoot(TargetRoom) :-
    arrows(N),
    N > 0,
    player_location(CurrentRoom),
    \+ adjacent(CurrentRoom, TargetRoom),
    write('Cannot shoot into room '), write(TargetRoom),
    write(' from room '), write(CurrentRoom), nl.

% ============================================================================
% GAME QUERIES AND UTILITIES
% ============================================================================

status :-
    player_location(Room),
    arrows(A),
    write('Player in room: '), write(Room), nl,
    write('Arrows remaining: '), write(A), nl,
    ( has_gold -> write('You have the gold!'), nl ; true ),
    ( game_over -> write('Game is over.'), nl ; write('Game is active.'), nl ),
    report_perceptions(Room).

visited_rooms :-
    write('Visited rooms: '),
    findall(R, visited(R), Rooms),
    write(Rooms), nl.

safe(Room) :-
    \+ wumpus_location(Room),
    \+ pit_location(Room).

safe_moves :-
    player_location(Current),
    write('Safe adjacent rooms: '),
    findall(R, (adjacent(Current, R), safe(R)), SafeRooms),
    write(SafeRooms), nl.

% ============================================================================
% AI REASONING PREDICATES
% ============================================================================

possible_wumpus_location(Room) :-
    visited(VisitedRoom),
    stench(VisitedRoom),
    adjacent(VisitedRoom, Room),
    \+ visited(Room),
    \+ wumpus_location(Room).  % don't suggest if it's already known

possible_pit_location(Room) :-
    visited(VisitedRoom),
    breeze(VisitedRoom),
    adjacent(VisitedRoom, Room),
    \+ visited(Room),
    \+ pit_location(Room).

definitely_safe(Room) :-
    visited(AdjacentRoom),
    adjacent(AdjacentRoom, Room),
    \+ stench(AdjacentRoom),
    \+ breeze(AdjacentRoom),
    \+ visited(Room).

% ============================================================================
% GAME COMMANDS
% ============================================================================

help :-
    nl,
    write('=== WUMPUS WORLD COMMANDS ==='), nl,
    write('init_game.           - Start a new game'), nl,
    write('move(N).             - Move to room N'), nl,
    write('shoot(N).            - Shoot arrow into room N'), nl,
    write('status.              - Show current status'), nl,
    write('visited_rooms.       - Show visited rooms'), nl,
    write('safe_moves.          - Show safe adjacent moves'), nl,
    write('possible_wumpus_location(X). - Suggestions'), nl,
    write('possible_pit_location(X).   - Suggestions'), nl,
    write('help.                - Show this help'), nl,
    nl.

% Auto-start message
:- write('Welcome to Wumpus World in Prolog!'), nl,
   write('Type help. to see available commands.'), nl,
   write('Type init_game. to start playing.'), nl, nl.
