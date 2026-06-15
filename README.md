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
- Run: `$ mathStuff:perimeter("circle",1)` would return 3.14159. 

*Note that Erlang treats as different datatypes "<x>" and '<x>'.*

## Simple recursive programs
Program 'lists1' that can find out the minimum and maximum elements of a list:
- Compile: `$ c:c(lists1).`
- Run: `$ lists1:min_max([4,1,33,-2,77,-1,0]).` would return {-2, 77}.

Program 'my_time'  which returns a string containing the date in Swedish format YYMMDD:
- Compile: `$ c:c(my_time).`
- Run: `$ my_time:swedish_date()

Note that it isn't recommended to call this program 'time' since it is a system reserved keyword.

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
