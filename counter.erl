-module(counter).
-export([new/0, read/1, up/1, down/1, reset/1]).
 
new() ->
    {counter,spawn(fun () -> loop(0) end)}.
    
loop(N) ->
    receive {Msg,Sender} ->
        Sender ! {self(), N},
        loop(case Msg
	       of read -> N
	        ; up   -> N + 1
	        ; down -> N - 1
	        ; reset-> 0
	     end)
    end.
 read(Counter) ->
    ipc(Counter, read).

 up(Counter) ->
    ipc(Counter, up).

 down(Counter) ->
    ipc(Counter, down).

 reset(Counter) ->
    ipc(Counter, reset).
    
 ipc({counter,Pid}, Msg) when is_pid(Pid) ->
    Pid ! {Msg,self()},
    receive {Pid,Result} -> Result end.