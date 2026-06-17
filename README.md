# README

The Erl language files located in this path, are the result of following the official Erlang website's tutorial at `https://erlang.org/course/exercises.html`

Note that every Erlang program must be compiled from the Erlang terminal, which you can open by typing `$ erl` in your terminal.
The compiled programs can be run from the Erlang terminal as well, by typing the compiled '.beam' file name followed by colon and the name of the exported function plus any needed parameters and a '.' at the end to indicate the instruction is complete: `$ <compiled-program-name>.beam:<exported-function-name>(..<parameters>).`.
The number of parameters to be passed is inidcated in the *export* instruction after the exported function name: `-export(<function-name>/<No-parameters)`.

## Entering a program
**To compile and run the program:**
- Compile: `$ c:c(demo).`
- Run: `$ demo:double(<N>).`

## Simple sequential programs
**To compile and run the program:**
Program 'temp' to convert temperature from Celsius to Fahrenheit and viceversa:
- Compile: `$ c:c(temp).`
- Run: `$ temp:convert("f",100).` would return 37.777, and `$ temp:convert("c",37.777).` would return 100.0.

Program 'mathStuff' with functions to calculate the perimiter of geometric forms:
- Compile: `$ c:c(mathStuff).`
- Run: `$ mathStuff:perimeter("circle",1).` would return 3.14159. 

*Note that Erlang treats as different datatypes "<x>" and '<x>'.*

## Simple recursive programs
Program 'lists1' that can find out the minimum and maximum elements of a list:
- Compile: `$ c:c(lists1).`
- Run: `$ lists1:min_max([4,1,33,-2,77,-1,0]).` would return {-2, 77}.

Program 'my_time'  which returns a string containing the date in Swedish format YYMMDD:
- Compile: `$ c:c(my_time).`
- Run: `$ my_time:swedish_date().`

Note that it isn't recommended to call this program 'time' since it is a system reserved keyword.

## Interaction between processes, concurrency
### 1. Two processes communicating
A function which starts 2 processes, and sends a message M times forwards and backwards between them. After the messages have been sent the processes should terminate gracefully.
File: `concurrency1.erl`
A function which starts 2 processes, and sends a message M times forewards and backwards between them. After the messages have been sent the processes should terminate gracefully.

To pass messages back and forth between two concurrent processes \(M\) times, you create a "ping-pong" loop.You spawn two processes: a Leader and a Follower. The Leader kicks off the exchange by sending the first message to the Follower, and they pass it back and forth while decrementing the counter `M`.

**Key Concepts to Study**
- spawn/3: Spawns a new concurrent process running a specific module, function, and list of arguments.
- The ! Operator: This is Erlang's message-passing operator (Pid ! Message). It is asynchronous and never blocks.
- {ping, self()}: Sending a tuple containing self() (the current process's ID) allows the receiving process to know exactly who to reply to.
- Graceful Termination: Processes in Erlang terminate naturally when their function loops finish executing without calling themselves recursively again.

### 2. A ring of processes sending a message around
A function which starts N processes in a ring, and sends a message M times around all the processes in the ring. After the messages have been sent the processes should terminate gracefully.
- Compile: `$ c:c(concurrency_1_ring).`
- Run: `$ concurrency_1_ring:start(2).` would return:
`
Leader sending message. Remaining rounds: 2
ok
Follower received ping. Bouncing it back.
Leader sending message. Remaining rounds: 1
Follower received ping. Bouncing it back.
Leader: Limit reached. Telling Follower to stop.
Leader terminating gracefully.
Follower terminating gracefully.
`

### 3. The central node in a star sends M messages to every other node
A function which starts N processes in a star, and sends a message to each of them M times. After the messages have been sent the processes should terminate gracefully.
- Compile: `$ c:c(concurrency_2_star).`
- Run: `$ concurrency_2_star:start(2).` would return:
`
concurrency_2_star:start(3,2).
Starting star topology with 3 workers...
Sending 2 messages to each worker...
Stopping workers gracefully...
Worker <0.100.0> received: "Hello"
Worker <0.101.0> received: "Hello"
Worker <0.102.0> received: "Hello"
Worker <0.100.0> received: "Hello"
Worker <0.101.0> received: "Hello"
Worker <0.102.0> received: "Hello"
ok
Worker <0.100.0> terminating gracefully.
Worker <0.101.0> terminating gracefully.
Worker <0.102.0> terminating gracefully.
`
