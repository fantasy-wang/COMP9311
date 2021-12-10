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