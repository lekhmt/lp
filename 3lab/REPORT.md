# № Отчет по лабораторной работе №3

## по курсу "Логическое программирование"

## Решение задач методом поиска в пространстве состояний

### студент: Леухин М. В.

## Результат проверки

| Преподаватель     | Дата         |  Оценка       |
|-------------------|--------------|---------------|
| Сошников Д.В. |              |               |
| Левинская М.А.|              |               |

> *Комментарии проверяющих (обратите внимание, что более подробные комментарии возможны непосредственно в репозитории по тексту программы)*

## Введение

Можно выделить категорию логических задач, в которых заданы начальное состояние некой системы, её конечное состояние и
набор определённых правил, по которым осуществляются переходы между состояниями. Такие задачи решаются методом поиска в
пространстве состояний, а язык Prolog оказывается хорошим инструментом для этого, так как Prolog позволяет легко
генерировать нужные последовательности состояний и осуществлять поиск в пространстве состояний.

В целом решение таких задач сводится к поиску в графе, который и будет представлять собой пространство состояний.
Огромным преимуществом языка Prolog в таком случае будет являться то, что в нём можно осуществлять обработку
потенциально бесконечных графов.

Наконец, можно сказать о том, что язык Prolog фактически основан на графах, так как дерево решений представляет собой
граф, обход которого осуществляется с помощью обхода в глубину.

## Задание

Площадь разделена на шесть квадратов, пять из них заняты мебелью, шестой - свободен. Переставить мебель так, чтобы шкаф
и кресло поменялись местами, при этом никакие два предмета не могут стоять на одном квадрате.

|      |      |        |
|------|------|--------|
| Стол | Стул | Шкаф   |
| Стул |      | Кресло |

## Принцип решения

В программе можно выделить следующие части:

1. В самом начале содержатся факты и предикаты, используемые всеми алгоритмами поиска. Здесь можно выделить:
* База фактов - здесь представлены возможные способы обмена местами двух предметов мебели (`0` означает пустую комнату):

   ```prolog
   permutation([0,B,C,D,E,F],[B,0,C,D,E,F]).
   permutation([A,0,C,D,E,F],[A,C,0,D,E,F]).
   permutation([A,B,C,0,E,F],[A,B,C,E,0,F]).
   permutation([A,B,C,D,0,F],[A,B,C,D,F,0]).
   permutation([0,B,C,D,E,F],[D,B,C,0,E,F]).
   permutation([A,0,C,D,E,F],[A,E,C,D,0,F]).
   permutation([A,B,0,D,E,F],[A,B,F,D,E,0]).
   ```

   При такой интерпретации вершинами графа будут являться состояния системы. Каждое состояние представляет собой
 конкретную расстановку предметов мебели в комнате.


* На основе вышеописанных фактов реализован предикат `move(A,B)`, который означает то, что из состояния `A`
возможно перейти в состояние `B` (либо обратно, из состояния `B` в состояние `A`):
    
   ```prolog
   move(A,B) :- 
       permutation(A,B);
       permutation(B,A).
   ```
    Другими словами, данный предикат
показывает тот факт, можно ли переставить мебель так, чтобы получить из одного состояния другое.        


* Для работы всех алгоритмов поиска понадобиться предикат `prolong`, который продлевает путь:
  ```prolog
  prolong([X|T],[Y,X|T]) :-
      move(X,Y),
      not(member(Y,[X|T])).
  ```

    Данный предикат находит вершину `Y`, достижимую из вершины `X`, а далее смотрит, есть ли она уже в списке посещённых
вершин `[X|T]`. Если нет, то получаем новый путь `[Y,X|T]`.


* Предикат `show_answer` реализован для удобного вывода найденного решения:

    ```prolog
        show_answer([_]) :- !.
            show_answer([A,B|Tail]) :-
            show_answer([B|Tail]),
            nl, write(B), write(' -> '),
           write(A).
    ```

2. Поиск в глубину. Реализация:
  
    ```prolog
    depth([X|T],X,[X|T]).
    depth(P,Y,R) :-
        prolong(P,P1),
        depth(P1,Y,R).
    ```
   
    Принцип работы этого алгоритма довольно прост: до тех пор, пока последней посещённой вершиной в пути `P`
    не будет являться искомая вершина `Y` (то есть пока путь `P` не представлен в виде `[Y|T]`) находим единственное
    продление текущего пути `P1` и рекурсивно вызываем предикат для него. Таким образом, поиск в глубину будет
    идти по первом же найденному пути максимально глубоко, и начнёт рассматривать другие пути только тогда, когда 
    упрётся в тупик (а на самом деле не "когда", а "если").


3. Поиск в ширину. Реализация:
    
    ```prolog
    breadth([[X|T]|_],X,[X|T]).
    breadth([P|QI],X,R) :-
        findall(Z,prolong(P, Z), T),
        append(QI,T,QO), !,
        breadth(QO,X,R).
    breadth([_|T],Y,L) :- breadth(T,Y,L).
    ```
   
    Алгоритм поиска в ширину отличается тем, что мы в каждый момент времени мы рассматриваем не один конкретный путь,
    а все возможные пути определённой длины. В приведённой реализации список `[P|QI]` на самом деле представляет собой
    очередь, которая содержит все рассматриваемые в данный момент пути. Предикат находит все возможные продления 
    рассматриваемых путей и записывает их в "очередь". Важно отметить, что очередной путь может оказаться финальным,
    то есть не иметь продления. В таком случае его необходимо полностью удалить из очереди.


4. Поиск в глубину с итеративным заглублением. Реализация:
    ```prolog
    int(1).
    int(M) :-
        int(N),
        M is N+1.

    search_id(Start,Finish,Path) :-
        int(Limit),
        search_id(Start,Finish,Path,Limit).

    search_id(Start,Finish,Path,DepthLimit) :-
        depth_id([Start],Finish,Path,DepthLimit).

    depth_id([Finish|T],Finish,[Finish|T],0).
    depth_id(Path,Finish,R,N) :-
        N>0,
        prolong(Path,NewPath),
        N1 is N-1,
        depth_id(NewPath,Finish,R,N1).
    ```

    Алгоритм поиска в глубину с итеративным заглублением является компромиссом, который сочетает в себе одновременно 
достоинства как поиска в глубину, так и поиска в ширину. На каждом этапе мы ограничиваем максимально возможную 
длину пути, из-за чего алгоритм поиска в глубину не будет идти максимально глубоко по первому же пути, а 
лишь до определённой глубины, после чего начнёт рассматривать другой путь. Таким образом мы получаем лучшее
использование памяти (так как алгоритм поиска в глубину хранит только текущий путь) и возможность найти кратчайший путь.


## Результаты

Теперь рассмотрим примеры работы каждого из алгоритмов. Начнём с алгоритма поиска в глубину:

```prolog
?- depth_first(["стол", "стул", "шкаф", "стул", 0, "кресло"], ["стол", "стул", "кресло", "стул", 0, "шкаф"]).
[стол,стул,шкаф,стул,0,кресло] -> [стол,стул,шкаф,стул,кресло,0]
[стол,стул,шкаф,стул,кресло,0] -> [стол,стул,0,стул,кресло,шкаф]
[стол,стул,0,стул,кресло,шкаф] -> [стол,0,стул,стул,кресло,шкаф]
...
[стол,0,стул,стул,шкаф,кресло] -> [стол,стул,0,стул,шкаф,кресло]
[стол,стул,0,стул,шкаф,кресло] -> [стол,стул,кресло,стул,шкаф,0]
[стол,стул,кресло,стул,шкаф,0] -> [стол,стул,кресло,стул,0,шкаф]
``` 

Алгоритм поиска в глубину нашел первым путь, состоящий из 246 шагов. 
Алгоритмы поиска в ширину и в глубину с итеративным заглублением позволили найти кратчайший путь, состоящий из 18 перестановок:

```prolog
?- breadth_search(["стол", "стул", "шкаф", "стул", 0, "кресло"], ["стол", "стул", "кресло", "стул", 0, "шкаф"]).
[стол,стул,шкаф,стул,0,кресло] -> [стол,стул,шкаф,стул,кресло,0]
[стол,стул,шкаф,стул,кресло,0] -> [стол,стул,0,стул,кресло,шкаф]
[стол,стул,0,стул,кресло,шкаф] -> [стол,0,стул,стул,кресло,шкаф]
[стол,0,стул,стул,кресло,шкаф] -> [стол,кресло,стул,стул,0,шкаф]
[стол,кресло,стул,стул,0,шкаф] -> [стол,кресло,стул,0,стул,шкаф]
[стол,кресло,стул,0,стул,шкаф] -> [0,кресло,стул,стол,стул,шкаф]
[0,кресло,стул,стол,стул,шкаф] -> [кресло,0,стул,стол,стул,шкаф]
[кресло,0,стул,стол,стул,шкаф] -> [кресло,стул,0,стол,стул,шкаф]
[кресло,стул,0,стол,стул,шкаф] -> [кресло,стул,шкаф,стол,стул,0]
[кресло,стул,шкаф,стол,стул,0] -> [кресло,стул,шкаф,стол,0,стул]
[кресло,стул,шкаф,стол,0,стул] -> [кресло,0,шкаф,стол,стул,стул]
[кресло,0,шкаф,стол,стул,стул] -> [0,кресло,шкаф,стол,стул,стул]
[0,кресло,шкаф,стол,стул,стул] -> [стол,кресло,шкаф,0,стул,стул]
[стол,кресло,шкаф,0,стул,стул] -> [стол,кресло,шкаф,стул,0,стул]
[стол,кресло,шкаф,стул,0,стул] -> [стол,кресло,шкаф,стул,стул,0]
[стол,кресло,шкаф,стул,стул,0] -> [стол,кресло,0,стул,стул,шкаф]
[стол,кресло,0,стул,стул,шкаф] -> [стол,0,кресло,стул,стул,шкаф]
[стол,0,кресло,стул,стул,шкаф] -> [стол,стул,кресло,стул,0,шкаф]

?- iteration_depth_search(["стол", "стул", "шкаф", "стул", 0, "кресло"], ["стол", "стул", "кресло", "стул", 0, "шкаф"]).
[стол,стул,шкаф,стул,0,кресло] -> [стол,стул,шкаф,стул,кресло,0]
[стол,стул,шкаф,стул,кресло,0] -> [стол,стул,0,стул,кресло,шкаф]
[стол,стул,0,стул,кресло,шкаф] -> [стол,0,стул,стул,кресло,шкаф]
[стол,0,стул,стул,кресло,шкаф] -> [стол,кресло,стул,стул,0,шкаф]
[стол,кресло,стул,стул,0,шкаф] -> [стол,кресло,стул,0,стул,шкаф]
[стол,кресло,стул,0,стул,шкаф] -> [0,кресло,стул,стол,стул,шкаф]
[0,кресло,стул,стол,стул,шкаф] -> [кресло,0,стул,стол,стул,шкаф]
[кресло,0,стул,стол,стул,шкаф] -> [кресло,стул,0,стол,стул,шкаф]
[кресло,стул,0,стол,стул,шкаф] -> [кресло,стул,шкаф,стол,стул,0]
[кресло,стул,шкаф,стол,стул,0] -> [кресло,стул,шкаф,стол,0,стул]
[кресло,стул,шкаф,стол,0,стул] -> [кресло,0,шкаф,стол,стул,стул]
[кресло,0,шкаф,стол,стул,стул] -> [0,кресло,шкаф,стол,стул,стул]
[0,кресло,шкаф,стол,стул,стул] -> [стол,кресло,шкаф,0,стул,стул]
[стол,кресло,шкаф,0,стул,стул] -> [стол,кресло,шкаф,стул,0,стул]
[стол,кресло,шкаф,стул,0,стул] -> [стол,кресло,шкаф,стул,стул,0]
[стол,кресло,шкаф,стул,стул,0] -> [стол,кресло,0,стул,стул,шкаф]
[стол,кресло,0,стул,стул,шкаф] -> [стол,0,кресло,стул,стул,шкаф]
[стол,0,кресло,стул,стул,шкаф] -> [стол,стул,кресло,стул,0,шкаф]
```

## Выводы

В ходе лабораторной работы мною был изучен ещё один способ решения логических задач, а именно метод поиска в пространстве состояний.
Для этого я дополнительно изучил различные алгоритмы поиска в графах и научился их реализовывать средствами языка Prolog.

Важным выводом из этой работы для меня стало то, что алгоритмы поиска в глубину и ширину имеют свои достоинства и недостатки 
и выбор лучшего алгоритма целиком зависит от задачи. Поиск в глубину менее требователен к памяти, однако находит 
первый попавшийся путь. Поиск в ширину позволяет найти кратчайший путь, но значительно более требователен по памяти.

Однако что мешает взять лучшее от вышеописанных алгоритмов? С поиском в глубину и ширину я был знаком ещё с 1 курса, а вот
поиск в глубину с итеративным заглублением для меня стал гениальным, хоть и простым открытием. Достаточно просто
ограничивать максимальную длину пути, из-за чего поиск в глубину будет находить все кратчайшие пути заданной длины, то есть вести себя
как поиск в ширину, но расходуя меньше памяти. Что же делать, если таких путей не нашлось? Всё просто - увеличить максимальную длину пути.