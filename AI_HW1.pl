/*
defines arcs or edges between vertices
curCost -> cost involved at a particular vertex
curVal  ->integer value of the current vertex
nxCost  -> cost of going to the next vertex 
nxValue -> integer value of the next vertex 
*/
arc((curCost-curValue), (nxCost-nxValue), seed) :- nxValue is curtValue*seed, nxCost is curCost + 1.
arc((curCost-curValue), (nxCost-nxValue), seed) :- nxValue is curValue*seed + 1, nxCost is curCost + 2.


/*
search is just a wrapper for the real search. 
seed   -> see how seed is used in arc
target ->  goal predicate
result -> result.
*/
search(start, seed, target, result) :- frontierSearch([(0-start)], seed, target, result).

%If the value part of the cost-value part pair satisfies the goal in regards to the target, return value part of current vertex
frontierSearch([(_-value)|_], _, target, value)				:- goal(value, target).

frontierSearch([node|rest], seed, target, result)			:- findall(next, arc(node, next, seed), children),
									add2frontier(children,rest,new),
									heuristicize(new, target, Heuristicized),
									keysort(Heuristicized, sortNew),
									unheuristicize(sortNew, target, UnHeuristicized),
									frontierSearch(UnHeuristicized, seed, target, result).


add2frontier([],rest,rest).
add2frontier([H|T],rest,[H|new]) :- add2frontier(T,rest,new).


goal(node, target) 	:- 0 is node mod target.

%heuristic predicted cost added to the curcost for each pair-entry in list
heuristicize([], _, []).
heuristicize([(curCost-curValue)|T0], target, [(HCost-curValue)|T1]) 	:- heuristic(curValue, HValue, target),
												HCost is round(curCost + HValue),
												heuristicize(T0, target, T1).

%inverse heuristicize
unheuristicize([], _, []).
unheuristicize([(curCost-curValue)|T0], target, [(HCost-curValue)|T1]) 	:- heuristic(curValue, HValue, target),
													HCost is round(curCost - HValue),
													deheuristicize(T0, target, T1).
% heuristic value
heuristic(N,Hvalue,target) 	:- goal(N,target), !, Hvalue is 0
				;
				Hvalue is 1/N.