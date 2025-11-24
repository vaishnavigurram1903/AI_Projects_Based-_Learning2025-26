# AI_Projects_Based-_Learning2025-26
Task given based case studies in prolog
Wumpus World – Prolog AI Practical (2025–26)

This project is an implementation of the classic Wumpus World — a knowledge-based agent problem from Artificial Intelligence — using Prolog.
It demonstrates logical reasoning, rule-based inference, and environment interaction inside a 20-room cave.

🔹 Features

20-room dodecahedral cave

Wumpus, pits, bats, gold, and player

Sensory perceptions: stench, breeze, rustling, glitter

Player actions: move, shoot, check status

Rule-based reasoning using Prolog

AI predicates for safe room inference

🔹 Files Included
File	Description
wumpus_world.pl	Complete Prolog implementation
requirements.txt	Software requirement (SWI-Prolog)
OUTPUT.txt	Sample program output
writeup.pdf	Two-page writeup for AI practical
🔹 How to Run
1. Install SWI-Prolog

Download from: https://www.swi-prolog.org/

2. Load the Program

Open terminal:

swipl
?- [wumpus_world].

3. Start the Game
?- init_game.

4. Use Commands
move(RoomNumber).
shoot(RoomNumber).
status.
visited_rooms.
safe_moves.
help.

🔹 Sample Gameplay
?- init_game.
Game initialized! You are in room 0.
In room 0:
You smell a stench.
You feel a breeze.
You hear rustling.

🔹 Conclusion

This project demonstrates how logical reasoning, knowledge representation, and rule-based agents work in Artificial Intelligence.
Prolog makes it easy to model constraints and deduce safe or dangerous rooms using inference rules.
