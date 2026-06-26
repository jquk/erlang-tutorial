# README

The Erl language files located in this path, are the result of following the official Erlang website's tutorial at `https://erlang.org/course/exercises.html`

Note that every Erlang program must be compiled from the Erlang terminal, which you can open by typing `$ erl` in your terminal.
The compiled programs can be run from the Erlang terminal as well, by typing the compiled '.beam' file name followed by colon and the name of the exported function plus any needed parameters and a '.' at the end to indicate the instruction is complete: `$ <compiled-program-name>.beam:<exported-function-name>(..<parameters>).`.
The number of parameters to be passed is inidcated in the *export* instruction after the exported function name: `-export(<function-name>/<No-parameters)`.

## ENTERING A PROGRAM
**To compile and run the program:**
- Compile: `$ c:c(demo).`
- Run: `$ demo:double(<N>).`

## SIMPLE SEQUENTIAL PROGRAMS
**To compile and run the program:**
Program 'temp' to convert temperature from Celsius to Fahrenheit and viceversa:
- Compile: `$ c:c(temp).`
- Run: `$ temp:convert("f",100).` would return 37.777, and `$ temp:convert("c",37.777).` would return 100.0.

Program 'mathStuff' with functions to calculate the perimiter of geometric forms:
- Compile: `$ c:c(mathStuff).`
- Run: `$ mathStuff:perimeter("circle",1).` would return 3.14159. 

*Note that Erlang treats as different datatypes "<x>" and '<x>'.*

## SIMPLE RECURSIVE PROGRAMS
Program 'lists1' that can find out the minimum and maximum elements of a list:
- Compile: `$ c:c(lists1).`
- Run: `$ lists1:min_max([4,1,33,-2,77,-1,0]).` would return {-2, 77}.

Program 'my_time'  which returns a string containing the date in Swedish format YYMMDD:
- Compile: `$ c:c(my_time).`
- Run: `$ my_time:swedish_date().`

Note that it isn't recommended to call this program 'time' since it is a system reserved keyword.

## INTERACTION BETWEEN PROCESSES, CONCURRENCY
### 1. TWO PROCESSES COMMUNICATING
A function which starts 2 processes, and sends a message M times forwards and backwards between them. After the messages have been sent the processes should terminate gracefully.
File: `concurrency1.erl`
A function which starts 2 processes, and sends a message M times forewards and backwards between them. After the messages have been sent the processes should terminate gracefully.

To pass messages back and forth between two concurrent processes \(M\) times, you create a "ping-pong" loop.You spawn two processes: a Leader and a Follower. The Leader kicks off the exchange by sending the first message to the Follower, and they pass it back and forth while decrementing the counter `M`.

**Key Concepts to Study**
- spawn/3: Spawns a new concurrent process running a specific module, function, and list of arguments.
- The ! Operator: This is Erlang's message-passing operator (Pid ! Message). It is asynchronous and never blocks.
- {ping, self()}: Sending a tuple containing self() (the current process's ID) allows the receiving process to know exactly who to reply to.
- Graceful Termination: Processes in Erlang terminate naturally when their function loops finish executing without calling themselves recursively again.

### 2. A RING OF PROCESSES SENDING A MESSAGE AROUND
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

### 3. CENTRAL NODE IN A STAR SENDS M MESSAGES TO EVERY OTHER NODE
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

## MASTER AND SLAVES, ERROR HANDLING
### 4. MASTER AND SLAVES, ERROR HANDLING
**Compile and run:**
- Compile: `$ c:(ms).`
- Run:
  - `$ ms:start(4).` to create four slaves.
  - `$ ms:to_slave('hi', 1).` to send 'hi' to slave No 1.
  - `$ ms:to_slave('die', 1).` to kill the slave No 1; It'll be restarted.

**Manually terminate the master in the terminal:**
- `MasterPid = whereis(master),`
- `unregister(master),`  % Optional - unregister AFTER getting PID
- `exit(MasterPid, kill).`
or
- `exit(whereis(master), kill).`

**Manually terminate a slave in the terminal:**
- `ms:start(4).`
- `Slaves = ms:get_slaves().`
- `{_, PidToKill} = lists:nth(2, Slaves).`  to get slave 2.
- `exit(PidToKill, kill).`  to force kill without die message.

Master should restart it.
Note: exit(Pid, kill) sends an untrappable exit signal - the slave dies immediately without executing any cleanup.

### 5. ROBUSTNESS AND USE OF A GRAPHICS PACKAGE
A robust system makes it possible to survive partial failure, i.e if some parts of the system crashes, it should be possible to recover instead of having a total system crash. In this exercise we will build a tree-like hierachy of processes that can recover if any of the tree-branches should crash.
To illustrate this we are going to use the Interviews interface and having each process represented by a window on the screen.

**Excercise:**
Create a window containing three buttons: Quit , Spawn , Error.
The Spawn button shall create a child process which displays an identical window.

The Quit button should kill the window and its child windows.

The Error button should cause a runtime error that kills the window (and its children), this window shall then be restarted by its parent.

**Key Concepts Explained:**
| Concept |	Purpose	| Code |
| ------- | ------- | ---- |
| trap_exit	| Parent can detect child death	| process_flag(trap_exit, true) |
| spawn_link	| Bidirectional monitoring	| spawn_link(fun() -> ... end) |
| {'EXIT',Pid,Reason}	| Exit signal message	| receive {'EXIT', Dead, Reason} -> ... end |
| Restart	| Recreate dead child	| spawn_link(fun() -> init() end) |
| Process Tree	| Each window = node in tree	| Children spawn grandchildren |
| wxErlang	| GUI library	| wxFrame:new/3, wxButton:new/2 |
| Event Binding	| Button → Process message	| wxButton:connect/3 |

**The Correct Way:** Use Event Messages (No Callbacks)
In Erlang, the cleanest and most idiomatic way to handle wx events is to avoid callbacks entirely. Instead, configure wx to send standard Erlang messages directly to your process mailbox.

**How to test it:**
```
1> c(robust_tree).
{ok,robust_tree}
2> robust_tree:start().
ok
% Window appears
% Click "Spawn" to create children (each opens new window)
% Click "Error" on any window → window crashes, parent restarts it
% Click "Quit" → window closes, children also close
```

**Critical Insight:**
- Error on child → child dies → parent receives {'EXIT', Child, _} → parent spawns new child
- Error on root → root dies → children die (linked) → entire tree dies (no parent to restart)



### 6. Erlang using UNIX sockets
Do you want to talk with a friend on another machine? Shouldn't it be nice to have a shell connected to your friend and transfer messages in between?
This can be implemented using the client/server concept with a process on each side listening to a socket for messages.


Write a distributed (client/server) message passing system. The system shall be built upon the Erlang interface to the BSD unix sockets.
The server host name will be given as input argument in order to start the client.
A prompt shall be displayed both on the server and the client side. The user shall give a string followed by a RETURN as a message. The message will be transfered and displayed to the user on the other side.
An empty input string (on either side) will end the session.
(Hints: read the man-page for the socket interface, also in order to read the command line, use io:get_line/1)

---

Here is a clean, robust implementation of the distributed message-passing system using Erlang's modern gen_tcp interface (which sits on top of BSD sockets).

To make this interactive and handle simultaneous reading from the user (stdin) and the socket, both the client and server spawn a dedicated listener loop and a sender loop.

---

**How to Run and Test It**
You can test this easily on your local machine using two separate terminal windows.

**1. Compile the module**
`
1> c(chat).
{ok, chat}
`

**2. Start the Server**
In your first terminal shell, start the server listening on a port (e.g., 8888):
`
2> chat:start_server(8888).
Server starting on port 8888...
Waiting for client connection...
`

**3. Start the Client**
Open a second terminal window, start erl, compile the code, and connect to the server using "localhost" (or your friend's IP/hostname):
`
2> chat:start_client("localhost", 8888).
Connecting to localhost:8888...
Connected! Start chatting.
You >
`

**4. Chat**
Both windows will now show You > .
- Type a message in the Client terminal and hit Return. It will show up on the Server terminal.
- Type a message in the Server terminal and hit Return. It will show up on the Client terminal.
- Pressing Return on an empty line in either terminal will close the socket and gracefully exit the Erlang environment on both ends.

**5. Chat over a public network**
The Roadblock: NAT and Firewalls
When you are at home, your computer doesn't usually have a public IP address that the whole internet can see. Instead, your router has the Public IP, and it assigns a Private IP (like 192.168.1.5) to your computer.
`
[ Friend's PC ] ---> ( Internet ) ---> [ Your Router ] --X--> [ Your PC ]
                                      (Public IP)            (Private IP: 192.168.1.5)
                                    "Where do I send 
                                     port 8888?"
`
When your friend tries to connect to your Public IP on port 8888, your router receives the request but doesn't know which device inside your house it belongs to, so it drops the connection.

**How to Make It Work**
To successfully chat over the Internet, you need to complete three steps:

**1. Find your actual Public IP**
Don't use the IP found in your computer's system settings (that's your local network IP). Instead, search "What is my IP" on Google or use a terminal command like curl ifconfig.me. Give that public IP to your friend.

**2. Set up Port Forwarding (On your router)**
You need to log into your home router's admin panel and configure Port Forwarding:
- External Port: 8888
- Internal Port: 8888
- Protocol: TCP
- Internal IP: Your computer's private local IP address (e.g., 192.168.1.X).

This tells your router: "Whenever a connection comes in from the Internet on port 8888, send it straight to my Erlang application."

**3. Allow it through your OS Firewall**
Ensure that your computer's software firewall (Windows Defender Firewall or macOS Packet Filter) isn't blocking incoming connections to the Erlang executable or port 8888.

**Easier Alternative: Ngrok / Localtunnel**
If you don't want to mess with your router settings, you can use a free tool like Ngrok to create a secure tunnel to your local machine.
1. Download Ngrok and run: ngrok tcp 8888
2. Ngrok will give you a public address like tcp://0.tcp.ngrok.io:12345
3. Your friend can then connect using that host and port:
`chat:start_client("0.tcp.ngrok.io", 12345).`