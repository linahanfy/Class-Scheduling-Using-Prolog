:- consult('publicKB').
study_days(Slots, DayCount) :-
    findall(Day,member(slot(Day,_,_), Slots), Days),
	sort(Days,S),
    length(S, L),
    L =< DayCount.
	
no_clashes(Slots):-
	no_clasheshelp(Slots,[]).	
no_clasheshelp([],_).
no_clasheshelp([slot(Day1,Num1,_),slot(Day2,Num2,_)|T],Acc):-
	(Day1\=Day2),
	no_clasheshelp([slot(Day1,Num1,_)|T],[slot(Day2,Num2,_)|T1]).
no_clasheshelp([slot(Day1,Num1,_),slot(Day2,Num2,_)|T],Acc):-
	(Day1==Day2,Num1\=Num2),
	no_clasheshelp([slot(Day1,Num1,_)|T],[slot(Day2,Num2,_)|T1]).
no_clasheshelp([H],Acc):-
	no_clasheshelp(Acc,[]).	

university_schedule(S):-
	findall(Student_id,(studies(Student_id,_)),Schedule),
	sort(Schedule,Students),
	all_schedules(Students, S),!.

all_schedules([], []).
all_schedules([Student|T],[sched(Student,Slots)|T1]) :-
    student_schedule(Student,Slots),  
    all_schedules(T,T1).

student_schedule(Student_id, Slots) :-
    findall(Course, studies(Student_id, Course), Temp), 
	sort(Temp,Courses),
    assign_courses(Courses,Slots),  
    no_clashes(Slots),
    study_days(Slots, 5).
	
assign_courses([], []).
assign_courses([Course | T1], [slot(Day, SlotNum, Course) | T2]) :-
    day_schedule(Day, Slots), 
    nth1(SlotNum, Slots, CourseList),
    member(Course, CourseList),
    assign_courses(T1, T2).
	
assembly_hours(Schedules, AH):-
	common_days(Schedules,Commondays),
	all_slots(Schedules,Commondays,AH),!.

all_slots([],[],_).
all_slots(Schedule,Commondays,AH):-
	getting_unwanted(Schedule,Commondays,[saturday,sunday,monday,tuesday,wednesday,thursday,friday],SN),
	remove_rep(SN,SL),
	append_all(SL, S),
	all(Commondays,[1,2,3,4,5],SLots),!,
	member2(SLots,S,AH).
	
getting_unwanted(_,_,[],[]).	
getting_unwanted(Schedule,Commondays,[Day|T],[SN|T1]):-
	member(Day,Commondays),
	member_schedule(Day,Schedule,SN),
	getting_unwanted(Schedule,Commondays,T,T1).
getting_unwanted(Schedule,Commondays,[Day|T],T1):-
	\+member(Day,Commondays),
	getting_unwanted(Schedule,Commondays,T,T1).

append_all([],[]).
append_all([L|T],R) :-
    append_all(T,T1),
    append(L,T1,R).
	
member2([],_,[]).
member2([H|T],S,[H|AH]) :-
    \+ member(H,S),
    member2(T,S,AH),!.
member2([H|T],S,AH) :-
    member(H,S),
    member2(T,S,AH).
	
all([], _, []).
all([Day|T], Numbers, R) :-
    slots_for_day(Day,Numbers,DaySlots),
    all(T,Numbers,Rest),
    append(DaySlots,Rest,R).

slots_for_day(_, [], []).
slots_for_day(Day, [Num | T1], [slot(Day, Num) | T2]) :-
    slots_for_day(Day, T1, T2).
	
member_schedule(_,[],Acc).
member_schedule(Day,[sched(_, [slot(Day, SN, _)|T1])|T],[slot(Day,SN)|S]) :-
    member_schedule(Day,[sched(_, T1)|T],S).
member_schedule(Day,[sched(_,[slot(Day1, SN, _)|T1])|T],S) :-
	Day\=Day1,
    member_schedule(Day,[sched(_, T1)|T],S).
member_schedule(Day,[sched(_, [] )|T],S) :-
    member_schedule(Day,T,S).
	
common_days(Schedules,Commondays):-
	days(Schedules,[],Cdays),
	sort_days(Cdays,[saturday,sunday,monday,tuesday,wednesday,thursday,friday],Commondays),!.
		
days([],Acc,Acc).
days([sched(Student_id,Slots)|T],[],Commondays):-
	help1(Slots,[],Temp),!,
	remove_rep(Temp,Days),
	days(T,Days,Commondays).
days([sched(Student_id,Slots)|T],Acc,Commondays):-
	help1(Slots,[],Temp),
	remove_rep(Temp,Days),
	member1(Days,Acc,Listt),
	days(T,Listt,Commondays).
		
member1([],Listt,[]).
member1([H|T],Acc,[H|T1]):-
	member(H,Acc),
	member1(T,Acc,T1).
member1([H|T],Acc,Listt):-
	\+member(H,Acc),
	 member1(T,Acc,Listt).
	
help1([],Acc,Acc).
help1([slot(Day,_,_)|T],Acc,Days):-
	append(Acc,[Day],R),
	help1(T,R,Days).
	
remove_rep([],[]).	
remove_rep([H|T],Commondays):-
	member(H,T),!,
	remove_rep(T,Commondays).
remove_rep([H|T],[H|T1]):-
	\+member(H,T),
	remove_rep(T,T1).
	
remove_repetitions([], []).
remove_repetitions([H|T],[H1|T1]) :-
    remove_rep(H,H1),
    remove_repetitions(T,T1).

sort_days([],_,[]).
sort_days([H1|T],[H1|T2],[H1|T1]):-
	sort_days(T,T2,T1).
sort_days([H1|T],[H2|T2],R):-
	H1\=H2,
	member(H2,T),
	append(T,[H1],Res),
	sort_days(Res,[H2|T2],R).
sort_days([H1|T],[H2|T2],R):-
	H1\=H2,
	\+member(H2,T),
	sort_days([H1|T],T2,R).
	
	



	