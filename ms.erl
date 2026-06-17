%% ============================================================
%% Module declaration - must match filename (ms.erl)
%% ============================================================
-module(ms).

%% ============================================================
%% Exports - functions callable from outside this module
%% ============================================================
%% start/1: Public API to start the supervision system
%% to_slave/2: Public API to send messages to slaves
-export([start/1, to_slave/2, get_slaves/0]).

%% ============================================================
%% Internal functions - still exported because spawn needs them
%% (We could avoid this by using fun() instead of function refs)
%% ============================================================
-export([master/1, slave/0]).

%% ============================================================
%% PUBLIC API FUNCTIONS
%% ============================================================

%% @doc Start the master with N slave processes
%% @spec start(N::integer()) -> true
start(N) ->
    %% Create the master process using an anonymous function
    %% The fun() is a closure - it captures N from this scope
    MasterPid = spawn(fun() -> 
        %% CRITICAL: Set trap_exit BEFORE creating links
        %% Without this, master would die when any slave dies
        process_flag(trap_exit, true),
        
        %% Start the master loop with N slaves
        %% This function is defined below
        master(N)
    end),
    
    %% Give the master process a global name
    %% Now we can send messages to 'master' atom instead of PID
    register(master, MasterPid),
    
    %% Return atom 'true' as required by exercise spec
    true.

%% @doc Send a message to slave number N via the master
%% @spec to_slave(Message::any(), N::integer()) -> {Message, N}
to_slave(Message, N) ->
    %% Send a tuple to the registered process 'master'
    %% The pattern {to_slave, Message, N} will be matched in master_loop
    master ! {to_slave, Message, N},
    
    %% Return tuple as required by exercise spec
    {Message, N}.

%% ============================================================
%% MASTER IMPLEMENTATION
%% ============================================================

%% @doc Master initialization - creates all slaves
%% @spec master(N::integer()) -> no_return() (infinite loop)
master(N) ->
    %% Create N slave processes and link to each one
    %% Returns a list of {Number, Pid} tuples
    Slaves = create_slaves(N, []),
    
    %% Start the main supervision loop
    master_loop(Slaves).

%% @doc Create N slave processes with links
%% @spec create_slaves(N::integer(), Acc::list()) -> [{integer(), pid()}]
create_slaves(0, Acc) ->
    %% Base case: no more slaves to create, return accumulator
    Acc;
create_slaves(N, Acc) ->
    %% spawn_link = spawn + link in one atomic operation
    %% Links establish bidirectional monitoring between master and slave
    SlavePid = spawn_link(fun slave/0),
    
    %% Store as {SlaveNumber, Pid} for easy lookup by number
    %% N is decremented each recursion (4,3,2,1)
    create_slaves(N - 1, [{N, SlavePid} | Acc]).

%% @doc Main supervision loop
%% @spec master_loop(Slaves::[{integer(), pid()}]) -> no_return()
master_loop(Slaves) ->
    %% Wait for messages indefinitely
    receive
        %% =====================================================
        %% Message from to_slave/2 - relay to specific slave
        %% =====================================================
        {to_slave, Message, N} ->
            %% Search the Slaves list for a tuple with first element = N
            %% lists:keyfind(Key, Position, List) 
            %% Position 1 = first element of tuple
            case lists:keyfind(N, 1, Slaves) of
                %% Found the slave
                {N, SlavePid} ->
                    %% Send message to slave with master's PID for reply
                    %% Format: {MasterPid, Message}
                    SlavePid ! {self(), Message},
                    
                    %% Continue loop with same slave list
                    master_loop(Slaves);
                    
                %% Slave not found - shouldn't happen
                false ->
                    io:format("Slave ~p does not exist~n", [N]),
                    master_loop(Slaves)
            end;
        
        %% =====================================================
        %% Exit signal from a dead slave (requires trap_exit)
        %% =====================================================
        %% `Reason` would generate a compiler warning 'variable unused'
        %% whereas `_` or `_Reason` suppresses the warning.
        {'EXIT', DeadPid, _Reason} ->
            io:format("master restarting dead slave~n"),
            
            %% Find the dead slave's number and restart it
            %% Returns updated slave list with new process
            NewSlaves = restart_slave(DeadPid, Slaves),
            
            %% Continue loop with new slave list
            master_loop(NewSlaves);

        %% =====================================================
        %% Function to get all slaves' PID
        %% =====================================================
        {get_slaves, From} ->
            From ! {slaves, Slaves},
            master_loop(Slaves);

        %% =====================================================
        %% Catch-all for unexpected messages
        %% =====================================================
        Other ->
            io:format("Master received unexpected: ~p~n", [Other]),
            master_loop(Slaves)

    end.

%% @doc Restart a dead slave process
%% @spec restart_slave(DeadPid::pid(), Slaves::[{integer(), pid()}]) -> [{integer(), pid()}]
restart_slave(DeadPid, Slaves) ->
    %% Search for the dead slave by PID (position 2 in tuple)
    %% lists:keyfind(PID, 2, List) searches second element
    case lists:keyfind(DeadPid, 2, Slaves) of
        %% Found the dead slave with number N
        {N, DeadPid} ->
            %% Remove dead slave from list
            %% lists:delete(Element, List) removes first occurrence
            Remaining = lists:delete({N, DeadPid}, Slaves),
            
            %% Create a new slave process
            %% spawn_link ensures we monitor the new one too
            NewPid = spawn_link(fun slave/0),
            
            %% Log the restart
            io:format("Restarted slave ~p with new PID ~p~n", [N, NewPid]),
            
            %% Return updated list with new process at front
            [{N, NewPid} | Remaining];
            
        %% Should never happen - slave not found
        false ->
            Slaves
    end.

%% ============================================================
%% SLAVE IMPLEMENTATION
%% ============================================================

%% @doc Slave process - receives messages from master
%% @spec slave() -> no_return() (unless it dies)
slave() ->
    receive
        %% =====================================================
        %% Message from master: {MasterPid, Message}
        %% Guard checks that first element is actually a PID
        %% =====================================================
        {MasterPid, Message} when is_pid(MasterPid) ->
            %% Pattern match on the message content
            case Message of
                %% Special message: die - terminate immediately
                die ->
                    io:format("Slave ~p dying~n", [self()]),
                    
                    %% exit(Reason) terminates the process
                    %% This sends {'EXIT', SelfPid, die} to linked master
                    exit(die);
                    
                %% Any other message: print it and continue
                _ ->
                    io:format("Slave ~p got message ~p~n", [self(), Message]),
                    
                    %% Recursive call - wait for next message
                    slave()
            end;
        
        %% =====================================================
        %% Catch-all for unexpected messages
        %% =====================================================
        Other ->
            io:format("Slave received unexpected: ~p~n", [Other]),
            slave()
    end.


%% ============================================================
%% 
%% ============================================================
get_slaves() ->
    master ! {get_slaves, self()},
    receive
        {slaves, Slaves} -> Slaves
    after 1000 -> timeout
    end.
