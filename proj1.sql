-- comp9311 19s1 Project 1
--
-- MyMyUNSW Solutions


-- Q1:
create or replace view Q1(unswid, longname)
as 
select distinct unswid, longname from rooms where rtype in (select id from room_types where description='Laboratory') and id in (select room from classes where course in (select id from courses where subject in (select id from subjects where code='COMP9311') and semester in (select id from semesters where year=2013 and term='S1')))
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q2:
create or replace view Q2(unswid,name)
as
select unswid,name from people where id in (select staff from course_staff where course in (select course from course_enrolments where student in (select id from people where name = 'Bich Rae')))
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q3:
create or replace view Q3_1(student,semester)
as
select a.id,c.semester from students a,course_enrolments b,courses c where a.id=b.student and a.stype='intl' and b.course=c.id and c.subject in (select id from subjects where code='COMP9311');

create or replace view Q3_2(student,semester)
as
select a.id,c.semester from students a,course_enrolments b,courses c where a.id=b.student and a.stype='intl' and b.course=c.id and c.subject in (select id from subjects where code='COMP9021');

create or replace view Q3_3(student)
as
select distinct a.student from Q3_1 a,Q3_2 b where a.student = b.student and  a.semester = b.semester;

create or replace view Q3_4(student)
as
select distinct a.student from Q3_3 a,students b where a.student=b.id and stype='intl';

create or replace view Q3(unswid, name)
as 
select a.unswid, a.name from people a,Q3_4 b where a.id=b.student;
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q4:
create or replace view Q4_1(program,allstudents)
as
select a.program,count(distinct student) from program_enrolments a,students b where a.student=b.id group by program;

create or replace view Q4_2(program,intlstudents)
as
select a.program,count(distinct student) from program_enrolments a,students b where a.student=b.id and b.stype='intl' group by program ;


create or replace view Q4_3(program)
as
select a.program from Q4_1 a,Q4_2 b where a.program=b.program and ((b.intlstudents::real)/a.allstudents between 0.3 and 0.7);


create or replace view Q4(code,name)
as
select a.code,a.name from programs a,Q4_3 b where a.id=b.program

--... SQL statements, possibly using other views/functions defined by you ...
;

--Q5:
create or replace view Q5_1(course,min1)
as
select course,min(mark) as min1 from course_enrolments where mark>=0 group by course 
having count(mark)>=20 ;

create or replace view Q5(code,name,semester)
as
select c.code,c.name,d.name from Q5_1 a,courses b,subjects c,semesters d where a.min1=(select max(min1) from Q5_1) and a.course=b.id and b.subject=c.id and b.semester=d.id

--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q6:
create or replace view Q6_1(num1)
as
select count(distinct d) from streams a,stream_enrolments b,program_enrolments c,students d,semesters e where a.name='Chemistry' and b.stream=a.id and b.partOf=c.id and c.student=d.id and c.semester=e.id and 
e.year=2010 and e.term='S1' and d.stype='local' ;

create or replace view Q6_2(num2)
as
select count(distinct a) from students a,program_enrolments b,programs c,
orgunits d,semesters e where b.student=a.id and a.stype='intl' and b.program=c.id and c.offeredBy=d.id and d.name='Faculty of Engineering' and b.semester=e.id and e.year=2010 and e.term='S1';

create or replace view Q6_3(num3)
as
select count(distinct b) from program_enrolments a,students b,semesters c,programs d where a.student=b.id and a.semester=c.id and c.year=2010 and  c.term='S1' and a.program=d.id and d.code='3978' and d.name='Computer Science';


create or replace view Q6(num1, num2, num3)
as
select a.num1, b.num2, c.num3 from Q6_1 a, Q6_2 b, Q6_3 c;
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q7:
create or replace view Q7_1(staff,starting,faculty)
as
select a.staff,a.starting,b.longname from Affiliations a,orgunits b,staff_roles c,orgunit_types d where a.orgUnit = b.id and a.role=c.id and c.name='Dean' and a.isprimary=True and b.utype=d.id and d.name='Faculty';

create or replace view Q7_2(staff,num_subjects,starting,faculty)
as
select a.staff,count(distinct d.code),a.starting,a.faculty from Q7_1 a,course_staff b,courses c,subjects d where a.staff=b.staff and b.course=c.id and c.subject=d.id group by a.staff,a.starting,a.faculty;

create or replace view Q7(name, school, email, starting, num_subjects)
as
select b.name, a.faculty, b.email, a.starting, a.num_subjects from Q7_2 a,people b where a.staff=b.id

--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q8: 
create or replace view Q8_1(course)
as
select course from course_enrolments group by course having count(distinct  student)>=20;

create or replace view Q8_2(subject)
as
select b.subject from Q8_1 a,courses b where a.course=b.id group by b.subject having count(distinct a.course)>=20;

create or replace view Q8(subject)
as
select concat(b.code,' ',b.name) from Q8_2 a,subjects b where a.subject=b.id
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q9:
create or replace view Q9_1(unit,year,num1)
as 
select d.longname,e.year,count(distinct a.student) from program_enrolments a,students b,programs c,orgunits d,semesters e where a.student=b.id and b.stype='intl' and a.program=c.id and c.offeredBy=d.id and a.semester=e.id group by d.longname,e.year;

create or replace view Q9_2(unit,max1)
as
select a.unit,max(a.num1) from Q9_1 a group by a.unit;


create or replace view Q9(year,num,unit)
as
select a.year,a.num1,a.unit from Q9_1 a,Q9_2 b where a.unit=b.unit and a.num1=b.max1
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q10:
create or replace view Q10_1(student)
as
select a.student from course_enrolments a,courses b,semesters c where a.course=b.id and b.semester=c.id and c.year=2011 and c.term='S1' and a.mark>=0 group by a.student having count(a.course)>=3;

create or replace view Q10_2(student,avgmark)
as
select b.student,avg(b.mark)::numeric(4,2) from Q10_1 a,course_enrolments b,courses c,semesters d where a.student=b.student and b.course=c.id and c.semester=d.id and d.year=2011 and d.term='S1' and b.mark>=0 group by b.student;

create or replace view Q10_3(rank,student,avgmark)
as
select rank() over (order by avgmark desc) ,a.* from (select * from Q10_2) a
 ;

create or replace view Q10_4(student,avgmark)
as
select a.student,a.avgmark from Q10_3 a where a.rank<=10;


create or replace view Q10(unswid,name,avg_mark)
as
select b.unswid,b.name,a.avgmark from Q10_4 a,people b where a.student=b.id

--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q11:
create or replace view Q11_1(student,num1)
as
select distinct a.student,count(distinct a.course) from course_enrolments a,courses b,semesters c where a.mark>=0 and a.course=b.id and b.semester=c.id and c.year='2011' and c.term='S1' group by a.student;

create or replace view Q11_2(student,num2)
as
select distinct a.student,count(distinct a.course) from course_enrolments a,courses b,semesters c where a.mark>=50 and a.course=b.id and b.semester=c.id and c.year='2011' and c.term='S1' group by a.student;

create or replace view Q11_3(student,num1,num2)
as
select distinct a.student,a.num1,b.num2 from Q11_1 a left join Q11_2 b on a.student=b.student;

create or replace view Q11_31(student,num1,num2)
as
select distinct student,num1,coalesce(num2, 0) from Q11_3;

create or replace view Q11_4(student,rate,num1)
as
select distinct a.student,a.num2::real/num1,a.num1 from Q11_31 a;

create or replace view Q11_41(unswid,name,rate,num1)
as
select a.unswid,a.name,b.rate,b.num1 from people a,Q11_4 b where a.id=b.student and a.unswid::text like '313%';


create or replace view Q11_5(unswid,name)
as
select unswid,name from Q11_41 where rate=0 and num1>1;

create or replace view Q11_6(unswid,name)
as
select unswid,name from Q11_41 where rate<=0.5 and num1>1;

create or replace view Q11_7(unswid,name)
as
select unswid,name from Q11_41 where rate>0.5 and num1>1;

create or replace view Q11_8(unswid,name)
as
select unswid,name from Q11_41 where rate=0 and num1=1;

create or replace view Q11_9(unswid,name)
as
select unswid,name from Q11_41 where rate=1 and num1=1;

create or replace view Q11(unswid,name,academic_standing)
as
select a.unswid,a.name,(case when a.unswid in (select unswid from Q11_5) then  'Probation' when a.unswid in (select unswid from Q11_6) then 'Referral' when a.unswid in (select unswid from Q11_8) then 'Referral' else 'Good' end) from people a,Q11_41 b where a.unswid=b.unswid order by a.unswid
--... SQL statements, possibly using other views/functions defined by you ...
;


-- Q12:
create or replace view Q12_1(subject)
as
select a.subject from courses a,subjects b,semesters c where a.subject=b.id and a.semester=c.id and b.code like 'COMP90%' and c.year between 2003 and 2012 and c.term='S1' group by a.subject having count(a.id)=10;

create or replace view Q12_2(subject)
as
select a.subject from courses a,subjects b,semesters c where a.subject=b.id and a.semester=c.id and b.code like 'COMP90%' and c.year between 2003 and 2012 and c.term='S2' group by a.subject having count(a.id)=10;


create or replace view Q12_3(subject)
as
select a.subject from Q12_1 a,Q12_2 b where a.subject=b.subject;


create or replace view Q12_4(code,name,year,num1)
as
select d.code,d.name,e.year,cast(sum(case when a.mark>=0 and e.term='S1' then 1 else 0 end)as numeric) as num1 from course_enrolments a,students b,courses c,subjects d,semesters e,Q12_3 f where a.student=b.id and a.course=c.id and c.subject=f.subject and c.subject=d.id and c.semester=e.id and e.year between 2003 and 2012 group by d.code,d.name,e.year;


create or replace view Q12_5(code,name,year,numpass1)
as
select d.code,d.name,e.year,cast(sum(case when a.mark>=50 and e.term='S1' then 1 else 0 end)as numeric) as numpass1 from course_enrolments a,students b,courses c,subjects d,semesters e,Q12_3 f where a.student=b.id and a.course=c.id and c.subject=f.subject and c.subject=d.id and c.semester=e.id and e.year between 2003 and 2012 group by d.code,d.name,e.year;


create or replace view Q12_6(code,name,year,num2)
as
select d.code,d.name,e.year,cast(sum(case when a.mark>=0 and e.term='S2' then 1 else 0 end)as numeric) as num2 from course_enrolments a,students b,courses c,subjects d,semesters e,Q12_3 f where a.student=b.id and a.course=c.id and c.subject=f.subject and c.subject=d.id and c.semester=e.id and e.year between 2003 and 2012 group by d.code,d.name,e.year;


create or replace view Q12_7(code,name,year,numpass2)
as
select d.code,d.name,e.year,cast(sum(case when a.mark>=50 and e.term='S2' then 1 else 0 end)as numeric) as numpass2 from course_enrolments a,students b,courses c,subjects d,semesters e,Q12_3 f where a.student=b.id and a.course=c.id and c.subject=f.subject and c.subject=d.id and c.semester=e.id and e.year between 2003 and 2012 group by d.code,d.name,e.year;


create or replace view Q12_8(code,name,year,rate1)
as
select a.code,a.name,a.year,(case when a.num1=0 then null else b.numpass1::real/a.num1 end) from Q12_4 a,Q12_5 b where a.code=b.code and a.name=b.name and a.year=b.year and a.num1>=0;

create or replace view Q12_9(code,name,year,rate2)
as
select a.code,a.name,a.year,(case when a.num2=0 then null else b.numpass2::real/a.num2 end) from Q12_6 a,Q12_7 b where a.code=b.code and a.name=b.name and a.year=b.year and a.num2>=0;

create or replace view Q12_10(code, name, year, s1_ps_rate, s2_ps_rate)
as
select a.code, a.name, right(a.year::text,2), a.rate1::numeric(4,2), b.rate2::numeric(4,2) from Q12_8 a left join Q12_9 b on a.code=b.code and a.name=b.name and a.year=b.year;


create or replace view Q12(code, name, year, s1_ps_rate, s2_ps_rate)
as
select code, name, year, s1_ps_rate, s2_ps_rate from Q12_10 


--... SQL statements, possibly using other views/functions defined by you ...
;
