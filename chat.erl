%%
%% Chat program using Unix sockets
%%
-module(chat).
-export([start_server/1, start_client/2]).

-define(PORT, 8888).

%% ====================================================================
%% SERVER API & LOOP
%% ====================================================================

%% Starts the server. Usage: chat:start_server(Port).
start_server(Port) ->
    io:format("Server starting on port ~p...~n", [Port]),
    case gen_tcp:listen(Port, [list, {packet, 0}, {active, false}, {reuseaddr, true}]) of
        {ok, ListenSocket} ->
            io:format("Waiting for client connection...~n"),
            %% FIXED: Changed '->' to 'of'
            case gen_tcp:accept(ListenSocket) of
                {ok, Socket} ->
                    io:format("Client connected! Start chatting.~n"),
                    gen_tcp:close(ListenSocket), % Close listen socket since we only need 1 client
                    spawn_loops(Socket);
                {error, Reason} ->
                    io:format("Accept failed: ~p~n", [Reason])
            end;
        {error, Reason} ->
            io:format("Could not listen: ~p~n", [Reason])
    end.

%% ====================================================================
%% CLIENT API
%% ====================================================================

%% Starts the client. Usage: chat:start_client("hostname", Port).
start_client(Host, Port) ->
    io:format("Connecting to ~s:~p...~n", [Host, Port]),
    case gen_tcp:connect(Host, Port, [list, {packet, 0}, {active, false}]) of
        {ok, Socket} ->
            io:format("Connected! Start chatting.~n"),
            spawn_loops(Socket);
        {error, Reason} ->
            io:format("Could not connect: ~p~n", [Reason])
    end.

%% ====================================================================
%% INNER HELPERS
%% ====================================================================

%% Spawns concurrent loops to handle sending and receiving simultaneously
spawn_loops(Socket) ->
    Self = self(),
    % Spawn socket reader
    spawn_link(fun() -> socket_reader_loop(Socket, Self) end),
    % Run user input loop in the main process
    user_input_loop(Socket).

%% Loop for reading from the keyboard (stdin) and sending to socket
user_input_loop(Socket) ->
    Prompt = "You > ",
    Input = io:get_line(Prompt),
    % Strip the trailing newline to check if it's empty
    CleanInput = string:trim(Input, trailing, "\n"),
    case CleanInput of
        "" -> 
            io:format("Closing session...~n"),
            gen_tcp:close(Socket),
            init:stop();
        _ ->
            gen_tcp:send(Socket, Input),
            user_input_loop(Socket)
    end.

%% Loop for reading incoming data from the socket
socket_reader_loop(Socket, ParentPid) ->
    case gen_tcp:recv(Socket, 0) of
        {ok, Data} ->
            % Check if the received data is just a newline (meaning empty string session close)
            case Data of
                "\n" ->
                    io:format("~nFriend disconnected. Exiting...~n"),
                    gen_tcp:close(Socket),
                    init:stop();
                _ ->
                    % Print friend's message and reprint the prompt nicely
                    io:format("~nFriend > ~sYou > ", [Data]),
                    socket_reader_loop(Socket, ParentPid)
            end;
        {error, closed} ->
            io:format("~nConnection closed by remote peer.~n"),
            init:stop();
        {error, Reason} ->
            io:format("~nSocket error: ~p~n", [Reason]),
            init:stop()
    end.