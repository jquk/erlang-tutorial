# README

The Erl language files located in this path, are the result of following these tutorials:
1. `https://erlang.org/course/exercises.html`

## Entering a program
**To compile and run the program:**
Enter the Erlang terminal: `$ erl`
Compile: `$ c:c(demo).`
Run: `$ demo:double(<N>).`

## Simple sequential programs
**To compile and run the program:**
Enter the Erlang terminal: `$ erl`
Compile: `$ c:c(temp).`
Run: `$ temp:convert("f",100).` would return 37.777, and `$ temp:convert("c",37.777).` would return 100.0.

*Note that Erlang treats as different datatypes "<x>" and '<x>'.*

## Simple recursive programs


## Interaction between processes, concurrency
### 1.
File: `concurrency1.erl`
A function which starts 2 processes, and sends a message M times forewards and backwards between them. After the messages have been sent the processes should terminate gracefully.

To pass messages back and forth between two concurrent processes \(M\) times, you create a "ping-pong" loop.You spawn two processes: a Leader and a Follower. The Leader kicks off the exchange by sending the first message to the Follower, and they pass it back and forth while decrementing the counter `M`.

### Key Concepts to Study
- spawn/3: Spawns a new concurrent process running a specific module, function, and list of arguments.
- The ! Operator: This is Erlang's message-passing operator (Pid ! Message). It is asynchronous and never blocks.
- {ping, self()}: Sending a tuple containing self() (the current process's ID) allows the receiving process to know exactly who to reply to.
- Graceful Termination: Processes in Erlang terminate naturally when their function loops finish executing without calling themselves recursively again.
