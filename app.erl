-module(app).
-author("Teodor").
-import(counter, [new/0, up/1, down/1, reset/1, read/1]). 
-export([start_game/0, print_game_rools/0, play_round/2, count_bulls/2, count_cows/3, 
generate_random_number/0, check_for_duplucates/1]).

play_round(Counter, RandomNumber) ->
    C = counter:read(Counter),
    if C == 10 -> 
        io:format("Ти загуби!~n");
    true -> 
        Answer = io:get_line("Въведете 4-цифрено число: "),
        {AnswerToInt, _} = string:to_integer(Answer),
        case AnswerToInt of
            error -> 
                io:format("Моля, въведете число!~n"),
                play_round(Counter, RandomNumber);
            _Else -> Length = length([list_to_integer([Char]) || Char <- integer_to_list(AnswerToInt)]),
            if Length == 4 ->
                case (check_for_duplucates(AnswerToInt)) of 
                    true -> counter:up(Counter),
                    Count = counter:read(Counter),
                    Bulls = count_bulls(integer_to_list(RandomNumber),integer_to_list(AnswerToInt)),
                    Cows = count_cows(integer_to_list(RandomNumber),integer_to_list(AnswerToInt), Bulls),
                    io:format("~p. число - ~p - познати бикове ~p, познати крави ~p~n", [Count, AnswerToInt, Bulls, Cows]),
                        if Bulls == 4 ->
                            io:format("Ти спечели!~n");
                        true ->
                            play_round(Counter, RandomNumber)
                        end;
                    false ->  io:format("Моля, въвеждайте числа без повтарящи се цифри!~n"),
                    play_round(Counter, RandomNumber)
                end;
                true -> 
                    io:format("Моля, въвеждайте 4-цифрени числа!~n"),
                    play_round(Counter, RandomNumber)
            end
        end    
    end.

start_game() ->
    print_game_rools(),
    Counter = counter:new(),
    RandomNumber = generate_random_number(),
    % io:format("Generated Number: ~p~n",[RandomNumber]),
    play_round(Counter, RandomNumber).

generate_random_number() ->
    RandomNumber = rand:uniform(10000),
    case length(integer_to_list(RandomNumber)) of 
        4 -> IsDuplicated = check_for_duplucates(RandomNumber),
            case IsDuplicated of
                true -> RandomNumber;
                false -> generate_random_number()
            end;
        _Else -> 
             generate_random_number()
    end.

check_for_duplucates(Number) ->
    List = integer_to_list(Number),
    erlang:length(List) == sets:size(sets:from_list(List)).

count_bulls(GeneratedNumber, InputNumber) ->
    length(lists:filter(fun(I) -> lists:nth(I,GeneratedNumber) == lists:nth(I,InputNumber) end,
                    lists:seq(1, length(GeneratedNumber)))).

count_cows(GeneratedNumber, InputNumber, Bulls) ->
    length(lists:filter(fun(I) -> lists:member(I, InputNumber) end, GeneratedNumber)) - Bulls.
   
print_game_rools() ->
    io:format("
                                    „Бикове и крави“.
    Правилата са следните:
    -Генерира се 4-цифрено число, което не съдържа повтарящи се цифри
    -Играчът се опитва да познае числото, като въвежда произволно 4-цифрено число
    -Ако има съвпадения на цифри и те са на правилните места, те са бикове
    -Ако има съвпадения на цифри, но те не са на правилните места, те са крави
    -При всеки опит за отгатване, се изписва колко бикове и крави съдържа предположението на играча
    -Ако играчът не познае числото с максимум 10 опита той губи играта\n\n").