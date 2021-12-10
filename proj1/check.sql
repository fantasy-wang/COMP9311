-- COMP9311 19s1 Project 1 Check
--
-- MyMyUNSW Check

create or replace function
	proj1_table_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='r';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	proj1_view_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='v';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	proj1_function_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_proc
	where proname=tname;
	return (_check > 0);
end;
$$ language plpgsql;

-- proj1_check_result:
-- * determines appropriate message, based on count of
--   excess and missing tuples in user output vs expected output

create or replace function
	proj1_check_result(nexcess integer, nmissing integer) returns text
as $$
begin
	if (nexcess = 0 and nmissing = 0) then
		return 'correct';
	elsif (nexcess > 0 and nmissing = 0) then
		return 'too many result tuples';
	elsif (nexcess = 0 and nmissing > 0) then
		return 'missing result tuples';
	elsif (nexcess > 0 and nmissing > 0) then
		return 'incorrect result tuples';
	end if;
end;
$$ language plpgsql;

-- proj1_check:
-- * compares output of user view/function against expected output
-- * returns string (text message) containing analysis of results

create or replace function
	proj1_check(_type text, _name text, _res text, _query text) returns text
as $$
declare
	nexcess integer;
	nmissing integer;
	excessQ text;
	missingQ text;
begin
	if (_type = 'view' and not proj1_view_exists(_name)) then
		return 'No '||_name||' view; did it load correctly?';
	elsif (_type = 'function' and not proj1_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (not proj1_table_exists(_res)) then
		return _res||': No expected results!';
	else
		excessQ := 'select count(*) '||
			   'from (('||_query||') except '||
			   '(select * from '||_res||')) as X';
		-- raise notice 'Q: %',excessQ;
		execute excessQ into nexcess;
		missingQ := 'select count(*) '||
			    'from ((select * from '||_res||') '||
			    'except ('||_query||')) as X';
		-- raise notice 'Q: %',missingQ;
		execute missingQ into nmissing;
		return proj1_check_result(nexcess,nmissing);
	end if;
	return '???';
end;
$$ language plpgsql;

-- proj1_rescheck:
-- * compares output of user function against expected result
-- * returns string (text message) containing analysis of results

create or replace function
	proj1_rescheck(_type text, _name text, _res text, _query text) returns text
as $$
declare
	_sql text;
	_chk boolean;
begin
	if (_type = 'function' and not proj1_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (_res is null) then
		_sql := 'select ('||_query||') is null';
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	else
		_sql := 'select ('||_query||') = '||quote_literal(_res);
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	end if;
	if (_chk) then
		return 'correct';
	else
		return 'incorrect result';
	end if;
end;
$$ language plpgsql;

-- check_all:
-- * run all of the checks and return a table of results

drop type if exists TestingResult cascade;
create type TestingResult as (test text, result text);

create or replace function
	check_all() returns setof TestingResult
as $$
declare
	i int;
	testQ text;
	result text;
	out TestingResult;
	tests text[] := array['q1', 'q2', 'q3', 'q4', 'q5','q6','q7','q8','q9','q10','q11','q12'];
begin
	for i in array_lower(tests,1) .. array_upper(tests,1)
	loop
		testQ := 'select check_'||tests[i]||'()';
		execute testQ into result;
		out := (tests[i],result);
		return next out;
	end loop;
	return;
end;
$$ language plpgsql;


--
-- Check functions for specific test-cases in Project 1
--

create or replace function check_q1() returns text
as $chk$
select proj1_check('view','q1','q1_expected',
                   $$select * from q1$$)
$chk$ language sql;

create or replace function check_q2() returns text
as $chk$
select proj1_check('view','q2','q2_expected',
                   $$select * from q2$$)
$chk$ language sql;

create or replace function check_q3() returns text
as $chk$
select proj1_check('view','q3','q3_expected',
                   $$select * from q3$$)
$chk$ language sql;

create or replace function check_q4() returns text
as $chk$
select proj1_check('view','q4','q4_expected',
                   $$select * from q4$$)
$chk$ language sql;

create or replace function check_q5() returns text
as $chk$
select proj1_check('view','q5','q5_expected',
                   $$select * from q5$$)
$chk$ language sql;

create or replace function check_q6() returns text
as $chk$
select proj1_check('view','q6','q6_expected',
                   $$select * from q6$$)
$chk$ language sql;

create or replace function check_q7() returns text
as $chk$
select proj1_check('view','q7','q7_expected',
                   $$select * from q7$$)
$chk$ language sql;

create or replace function check_q8() returns text
as $chk$
select proj1_check('view','q8','q8_expected',
                   $$select * from q8$$)
$chk$ language sql;

create or replace function check_q9() returns text
as $chk$
select proj1_check('view','q9','q9_expected',
                   $$select * from q9$$)
$chk$ language sql;

create or replace function check_q10() returns text
as $chk$
select proj1_check('view','q10','q10_expected',
                   $$select * from q10$$)
$chk$ language sql;

create or replace function check_q11() returns text
as $chk$
select proj1_check('view','q11','q11_expected',
                   $$select * from q11$$)
$chk$ language sql;

create or replace function check_q12() returns text
as $chk$
select proj1_check('view','q12','q12_expected',
                   $$select * from q12$$)
$chk$ language sql;
--
-- Tables of expected results for test cases
--

drop table if exists q1_expected;
create table q1_expected (
     unswid ShortString,
     longname LongName
);

drop table if exists q2_expected;
create table q2_expected (
	unswid integer,
	name LongName
);

drop table if exists q3_expected;
create table q3_expected (
	unswid integer,
	name LongName
);

drop table if exists q4_expected;
create table q4_expected (
	code character(4),
	name LongName
);

drop table if exists q5_expected;
create table q5_expected (
    code char(8),
	name MediumName,
	semester ShortName
);

drop table if exists q6_expected;
create table q6_expected (
    num1 bigint,
    num2 bigint,
    num3 bigint
);

drop table if exists q7_expected;
create table q7_expected (
    name LongName,
    faculty LongString,
    email text,
    starting date,
    num_subjects bigint
);

drop table if exists q8_expected;
create table q8_expected (
    subject text
);

drop table if exists q9_expected;
create table q9_expected (
	year courseyeartype,
    num bigint,
    unit longstring
);

drop table if exists q10_expected;
create table q10_expected (
    unswid integer,
    name longname,
    avg_mark numeric(4,2)
);

drop table if exists q11_expected;
create table q11_expected (
    unswid integer,
    name longname,
    academic_standing text
);

drop table if exists q12_expected;
create table q12_expected (
    code text,
    name LongName,
    year text,
    s1_ps_rate numeric(4,2),
    s2_ps_rate numeric(4,2)
);



COPY q1_expected (unswid, longname) FROM stdin;
K-J17-G15	Pipe J17
\.

COPY q2_expected (unswid, name) FROM stdin;
9118081	Berman Kayis
3283511	Ian Benton
3053436	William Morrissey
3163095	Andrea North-Samardzic
9992268	Kenneth Stevens
7493176	Kenneth Trotman
7495067	Toan Pham
3154023	Juergen Oschadleus
3037797	Craig Tapper
3106099	Marcus Walsh
3269981	Francene Symonds
\.

COPY q3_expected (unswid, name) FROM stdin;
3253334	Sarah Sridharan
3329420	Amanda Hollis
3306349	Ben Thieu
3395509	Huimin Kung
3327406	Sara Seberry
3199764	Ricky Lavery
3217612	Manh Luong
3307127	Harinder Nettheim
3337102	Scott Hoza
3397374	Ronald Stanford
3166499	Emiliano Ciampi
3265523	Dai Lan
3352307	Michael Gell
3358442	Yanti Irwanto
3208038	Andrew Murdoch
3204724	Gregory Uminski
3292214	May Bow
3295479	Logan Branch
3359873	Pierre Rubsov
3285605	Suping Nan
3382572	Jessica Zlatevska
3302011	Maeda Farahbakhsh
3378940	Shao-Ting Hsia
3320346	Michael Sopchak
3360103	Venkata Hebbal Eswara
3362034	James Flink
3044434	Robin Vucic
3353549	Karen Hendrata
3276221	Maria Loty
3399019	Michael Taatjes
3182805	Kon Badgery
3235326	Jaime Hengrasme
3258202	Ming Gunasegaram
3387130	Harry Taperell
3232261	Di Yang Ruihong
3323717	Greta Tsong
3391061	Gregory Henricks
3182608	Eng Lew
3206547	An Bizimis
3240135	Kenneth Fan
3142120	Davina Ridhalgh
3235175	Xiao Liu Kunsheng
3270552	An Tait Lees
3344935	Muhummud Tin Kin Wang
3144894	Julian Jackson
3296376	Hong-Sheng She
3208457	Muriel Wood
3333480	Joanna Carenza
3284258	Mabel Lok
3370563	Adrean Abibadra
3395758	Margaret Cirone
3300972	Kimberly Nordman
3269015	Lillian Macarthur
3397295	Yunhua Xian
3351511	Nadja Kronick
3331317	Amitesh Chung
3345095	Lily Adair
3328381	Adam Tresidder
3315523	Trudy Farrah-Germaine
3361899	Jing Zhen
3214688	Priya Rogers
3354047	Jacqueline Pring
3326556	Ngoc Tan
3379068	Shane O Hainin
3218103	Elaine Hon
3296225	Peter Southern
3232340	Tracey Davison
3295126	Adrian Luzar
3242481	Steven Boland
3387180	Emma Aldrich
3276451	Pasquale McFarland
3349515	Daniel Sealey
3266024	Lennard Ali Akbar
3366130	Joseph Ayoubi
3236178	Emily Lucock
3241696	Xiaochao Huang Li
3305841	Leroy Kaye
3213375	Kenrick Tonge
3265896	Patric Zemowski
3267447	Supalak Khwannimit
3290621	Tadeusz Mylka
3261808	Elizabeth McGann
3232407	Aliz Balogh
3243616	Virginia Glanz
3185901	Joanne Snyder
3210782	Peter Dibianco
3182608	Eng Lew
3229912	Seung Stenberg
3311013	Shaoni Yinnu
3367418	Noel Stahl
3252755	Ahmed Rahim
3205105	Lachlan Tatarchuk
3213642	Evan Assimakopoulos
3311618	Caroline Matousek
3279568	Ben Cloherty
3355660	Viviane Sjolyst
3321666	Jason Gopal
3201328	Alannah Adams-Hamilton
3182805	Kon Badgery
3349178	Eric Chik
3234233	Patrick Soeswanto
3205033	Eric Du
3240121	Mohammed McCarthy
3259296	Chen-Lei Mai Jun-Yu
3350584	Audrey Smith
3127601	Edmund Kuffer
3244150	Litsa Coote
3377650	Hugo Gainsbury
3049611	Xianfeng Ma Xue Mei
3107309	Katie Nand
3210864	David Dalley
3138136	Huan Cai
3216037	Humberto Albis
3278144	Robert McElroy
3343459	Winy Kusmana
3255367	Wei Bai
3462391	Lindie Ju
3245175	Maurice Titmuss
3334942	Supot Wattanasukchai
3277828	Koon Routley
3261550	Allen Hards
3499418	Portia Suen
3263012	Jeanette Greve
3236640	Zulfikar Gandhi
3357920	Edward McMurtrie
3237617	Nigel Mcbaron
3372020	Mark Kelleher
3219456	Ching Moy
3136176	Ka Liu
3206547	An Bizimis
3355536	Ashley Steadson
3341542	Duncan Annis
3395931	Sau Davis
3356955	Karen Kerr
3384565	Yuzhi Si
3120329	Nitu Bodduluri
3295914	Thien Nguyen Hoang
3487942	Thi Ledinh
3252967	Daniel Chae
3258202	Ming Gunasegaram
3366514	Kevin Qiang
3182603	Ophelia Fedeles
3235175	Xiao Liu Kunsheng
3282152	Eleanor Molloy
3248995	Raouf Idziak
3350253	Irene Islam
3209996	Leyi Fan Peilin
3280643	Janssen Cellini
3314734	Peter Hu
3395304	Irwin Yun
3353976	Katrecia Ledger
3269690	Yong Zhuo
3343326	Melinda Brodsky
3240449	Pat Santiwong
3387344	Constantinos Mateou
3383562	Samuel Cross
3297902	Merric Kunde
3315523	Trudy Farrah-Germaine
3332509	Tu-Phuong Murty
3253193	Mark Frazi
3285086	James Colclough
3209861	Khanh Thorp
3326517	Wesley Butfield
3333010	Lily Onggo
3224951	Sean Behrendt
3319767	Lloyd Copeland
3057164	Desmond Do
3208147	Elena Sit
3301134	Joanne Argent
3215496	Evelyn Rangel
3347713	Tsz Lynn
3268179	Leanne Dee
3247372	James Jayawardena
3382936	Mark Ebneter
3261661	Jannie Chiun
3355764	Carl Spuhl
3330190	Anneli Eliasson
3394232	Patricia Strang
3375805	Dimitrius Crissani
3156293	Farhan Javaid
3234675	Tomas Beer
3348531	Roberto Dunne
3399749	Beth Paton
3119509	Wai-Ping Eletz
3279183	Tua Cooke
3168465	Vivien Cruikshank-Sgouras
3236178	Emily Lucock
3397282	William Badcock
3372176	Leonardi Hendrik
3248592	Navin Irizarry
3315967	Karthigan Weeratunga
3128353	Paul Janes
3319286	Felicity O'Leary
3306199	Hee-Jo Ku
3324456	Emma Elsom
3378861	Christopher Falconer
3276797	Mohd Ariffin
3308019	Jaclyn Wang
3334016	Elizabeth Haereroa-Yerkovich
3226063	Todd Kiraly
3363270	Wadih Polon
3248225	Camilla McNeillage Greene
3220904	Carly-Maree Toumazou
3201561	Kheng Mat Hassan
3380439	Seoh Ho
3394854	Christopher Pong
3206362	Lisa Yan
3255939	Rosanna Hogarth
3353235	Brooke Ing
3335050	Derek Carson
3156293	Farhan Javaid
3263012	Jeanette Greve
3246462	Jocelyn Barrera
3261808	Elizabeth McGann
3270472	Pak Tung
3376501	Carl Tsai
3291560	Becky Harrison
3204752	Angie Harbon
3313033	Dony Yogasara
3269015	Lillian Macarthur
3202553	Xian Chen Gan-Lai
3404958	Umaporn Kinney
3308107	Nicole Szoboszlay
3344923	Naveen Varatharajan
3134570	Edward Van Oyen
3240694	Choi Guan
3324677	Wilson Nagel
3213613	Khuong Hong
3247892	Roksana Filatov
3355705	Yi Zhuge
3345967	Larry Wollen
3305661	Victor Beat
3260955	Myall Kozelj
3290708	Pamela Brassel
3340263	Jan Naughtin
3366222	Waseem Alston
3316121	Jeng-Yiing Yao
3233387	Naomi Van Schaick
3354857	Brendan Manrique
3328599	Kevin Gambrill
3335584	Elaine Fuentes
3382457	Stephen Verhoeven
3269260	Einat Rosenberg
3381041	Prithvi Chaugule
3391549	Bo Joo
3350159	Benjamin Colpani
3201219	Jolly Duorina
3322246	Oliver Cupper
3199879	Nonna Ballantyne
3264478	Nicolas Turville
3328231	Eleanor Muller
3308889	Emma Alessi
3388597	Gavin Fewster
3237202	Sik Manho
3361202	Loganathan Trotter
3326650	Gareth Monthule-McIntosh
3172791	Emma Ghonim
3309123	Sophia Gabagat
3371058	Belinda Wysel
3276652	Damian Darragh
3255143	Allison Rubinfeld
3345795	Kim Hennessey
3387535	Jennifer Post
3208272	Faizullah Farid
3282128	James Stephens
3242363	Dac Quynh
3305858	Ke Shi Xiaomeng
3271204	Jaime Li Jun
3275638	Claire Lesmana
3348681	Eleanor Caton
3223491	Kendra Sing
3354606	Xixiong Tran
3234743	Yunita Jethnani
3350036	Kwang-Won Eun
3364916	Barry Papamanuel
3371876	Jiun-Der Ye
3328432	Kimmi Chung
3268773	Yong Yang Ruihong
3296132	Huizhao Yee
3255939	Rosanna Hogarth
3391993	Corey Rofael
3224850	Chenyi Zhou
3284555	Keval Bullock
\.

COPY q4_expected (code, name) FROM stdin;
8404	Commerce
8760	Graduate Optometry
3260	Architecture
8685	Computer Science & Engineering
8226	Music
3502	Commerce
8225	Arts
8619	Environmental Management
3620	Civil Engineering
8007	Technology & Innovation Mgmt
3710	Mechanical & Manufacturing Eng
3978	Computer Science
9304	Design
1640	Electrical Engineering
3801	Medicine
3643	Telecommunications
3625	Environmental Engineering
3052	Biotechnology
3640	Electrical Engineering
3040	Chemical Engineering
1010	Chemical Engineering
1650	Computer Science and Eng
8612	Civil Engineering
5453	Information Science
3135	Materials Science and Eng
3060	Food Science and Technology
5445	Engineering (Biomedical Eng)
3981	Aviation (Management)
8607	Engineering
8750	Statistics
8710	Mechanical & Manufacturing Eng
8016	Process Engineering
8735	Environmental Science
1970	Education
8722	Optoelectronics and Photonics
3642	Photovoltaics & Solar Energy
6030	NAWD UGRD (Business)
8655	Petroleum Engineering
8132	Sustainable Development
8048	Biotechnology
5020	Food Technology
8049	Biopharmaceuticals
9303	Art Education
8708	Chemical Analysis & Lab Mngt
8671	Safety Science
8728	Risk Management
3644	Photonic Engineering
3617	Nanotechnology
8350	Business Administration
5132	Sustainable Development
3624	Engineering (Civil Eng w Arch)
3634	Photonic Engineering/Science
3657	Renewable Energy Engineering
4465	Aeronautical Engineering (CDF)
5355	Microbiology and Immunology
5432	Computing and Information Tech
5459	Civil Engineering
5668	Risk Management
5740	Law
7303	Design
7308	Digital Media
7341	Petroleum Engineering
8124	Const Project Mgt in Prof Prac
8127	Property and Development
8133	Architecture/Built Environment
8147	Planning
8161	Financial Mathematics
8406	Finance
8407	Information Systems
8411	Actuarial Studies
8413	Financial Analysis
8718	Mathematics
8751	Biostatistics
9308	Digital Media
9920	Information Technology
0380	Obstetrics and Gynaecology
1016	Industrial Chemistry
1017	Petroleum Engineering
1031	Food Science and Technology
1036	Biotechnology
1120	Built Environment
1211	Environmental Policy and Mgmt
1228	Indonesian Studies
1270	Politics & Internat'l Relation
1297	Criminology
1410	Biochem & Molecular Genetics
1435	Biological Science
1440	Microbiology and Immunology
1521	Accounting
1540	Economics
1545	Actuarial Studies
1630	Civil & Environmental Eng
1662	Mechanical & Manufacturing Eng
1681	Surveying & Spatial Info Sys
1710	Biomedical Engineering
1740	Juridical Science
1750	Anatomy
1771	Medicine (SWS Clinical School)
1772	Medicine (St George Clin Schl)
1780	Pathology
1790	Physiology and Pharmacology
1810	Surgery (POW Clinical School)
1820	Obstetrics and Gynaecology
1900	Aviation
2000	Applied Geology
2040	Geography
2055	Materials Sc and Engineering
2175	Materials Sc and Engineering
2180	Mining Engineering
2354	Education
2475	Science
2485	Biological Science
2515	Medicine
2660	Electrical Engineering
2665	Computer Science and Eng
2675	Biomedical Engineering
2691	Mechanical Engineering
2692	Mechanical & Manufacturing Eng
2693	Aerospace Engineering
2810	Community Medicine
2821	Medicine (SWS Clinical School)
2822	Medicine (St George Clin Schl)
2880	Psychiatry
2900	Optometry
2910	Chemistry
2920	Mathematics
1321	Politics
6021	Exchange Program
1663	Aerospace Engineering
1541	Economics and Management
1081	Geography
1350	Management
1892	Physics
1745	Taxation
3261	Architectural Studies
8538	Engineering Science
8143	Architecture
5338	Engineering Science
1881	Mathematics & Statistics
5543	Information Technology
8222	Journalism and Communication
8129	Building Construction Mgt Prog
5265	Applied Intellectual Property
5945	Management - HK
6048	X-Instit UGRD (Med)
8291	Public Relations & Advertising
8345	Business Administration - HK
9044	Int Pub Hlth/Hlth Mgmt
9231	Business Law
9273	Financial Planning
8418	Risk Management
3502	Commerce
3543	Economics
3617	Nanotechnology
8718	Mathematics
8750	Statistics
3710	Mechanical & Manufacturing Eng
3620	Civil Engineering
3640	Electrical Engineering
3644	Photonic Engineering
3045	Petroleum Engineering
3642	Photovoltaics & Solar Energy
3657	Renewable Energy Engineering
3135	Materials Science and Eng
3625	Environmental Engineering
8404	Commerce
3657	Renewable Energy Engineering
3981	Aviation (Management)
3052	Biotechnology
3261	Architectural Studies
8425	Accounting/Business Info Tech
\.


COPY q5_expected (
	code,
	name,
	semester
) FROM stdin;
PHYS2030	Laboratory A	Sem1 2011
\.

COPY q6_expected (
    num1,
    num2,
    num3
) FROM stdin;
72	328	82
\.

COPY q7_expected (
    name,
    faculty,
    email,
    starting,
    num_subjects
) FROM stdin;
Ross Harley	College of Fine Arts (COFA)	ross@unsw.edu.au	2013-04-01	11
David Dixon	Faculty of Law	d.dixon@unsw.edu.au	2010-03-05	9
James Donald	Faculty of Arts and Social Sciences	j.donald@unsw.edu.au	2001-01-01	3
\.

COPY q8_expected (
    subject
) FROM stdin;
ACCT1501 Accounting & Financial Mgt 1A
ECON1101 Microeconomics 1
MATH1131 Mathematics 1A
\.

COPY q9_expected (year, num, unit) FROM stdin;
2013	6	Department of Anatomy
2011	28	School of Biotechnology and Biomolecular Sciences
2011	45	School of Art - COFA
2011	23	School of Art History & Art Education - COFA
2011	348	Faculty of Arts and Social Sciences
2009	4	UNSW Canberra at ADFA
2010	4	UNSW Canberra at ADFA
2011	4	UNSW Canberra at ADFA
2011	249	Faculty of Science
2012	16	School of Biological, Earth and Environmental Sciences
2011	477	Faculty of Built Environment
2011	238	School of Chemical Engineering
2012	34	School of Chemistry
2012	263	School of Civil and Environmental Engineering
2012	7	Clinical School - Prince of Wales Hospital
2011	2	Clinical School - South Western Sydney
2012	2	Clinical School - South Western Sydney
2012	6	Clinical School - St George Hospital
2012	8	Clinical School - St Vincent's Hospital
2011	4	College of Fine Arts (COFA)
2011	281	School of Computer Science and Engineering
2010	104	School of Design Studies - COFA
2012	11	School of Education
2012	209	School of Electrical Engineering & Telecommunications
2011	504	Faculty of Engineering
2011	58	School of the Arts and Media
2009	30	Institute of Environmental Studies
2012	15	School of Surveying and Spatial Information Systems
2011	37	Graduate School of Biomedical Engineering
2013	2	School of Management
2013	11	School of Information Systems, Technology and Management
2011	26	Faculty of Law
2012	114	School of Law
2012	15	School of Materials Science & Engineering
2011	11	School of Mathematics & Statistics
2012	318	School of Mechanical and Manufacturing Engineering
2012	200	Faculty of Medicine
2010	27	School of Mining Engineering
2010	34	School of Optometry and Vision Science
2012	8	Department of Pathology
2012	87	School of Petroleum Engineering
2012	4	School of Physics
2013	4	School of Physics
2011	5	School of Psychiatry
2012	19	School of Psychology
2010	39	School of Risk & Safety Science
2012	3	School of Social Sciences
2012	161	School of Photovoltaic and Renewable Engineering
2013	74	School of Aviation
2011	16	School of Actuarial Studies
2011	296	UNSW Foundation Studies
2012	52	School of Public Health & Community Medicine
2011	10	School of Medical Sciences
2012	10	School of Medical Sciences
2011	5	School of Women's and Children's Health
2012	5	School of Women's and Children's Health
2011	60	School of Media Arts
2011	17	School of Business (ADFA)
2012	17	School of Business (ADFA)
2013	7	School of Humanities and Social Sciences (ADFA)
2010	18	School of Physical, Environmental and Mathematical Sciences (ADFA)
2012	922	Australian School of Business
2010	131	AGSM MBA Programs
2010	1	Nura Gili Indigenous Programs
2012	1	Nura Gili Indigenous Programs
2012	9	Graduate Programs in Business and Technology
2009	1	School of Obstetrics and Gynaecology
2010	1	School of Obstetrics and Gynaecology
2011	1	School of Obstetrics and Gynaecology
2010	5	School of Paediatrics
2011	5	School of Paediatrics
2012	5	School of Paediatrics
2012	3	School of Biochemistry and Molecular Genetics
2013	6	Department of Biotechnology
2007	3	School of Microbiology and Immunology
2012	44	UC Information Technology and Electrical Eng
2011	33	UC School of Aerospace, Civil and Mechanical Eng
2011	16	UC School of Humanities and Social Science
2010	4	School of Physiology and Pharmacology
2010	11	Division of Registrar and Deputy Principal
2004	1	Building Construction Management Program
2005	1	Building Construction Management Program
2012	1	School of Engineering and Information Technology (ADFA)
2013	1	School of Engineering and Information Technology (ADFA)
2010	11	Australian School of Taxation and Business Law
\.


COPY q10_expected (unswid, name, avg_mark) FROM stdin;
3239177	Mithril Abdul Razak	99.00
3353787	Erin Gati	98.67
3267525	Michael Mohamed Anuar	97.33
3363572	Alicia Almasi	96.25
3230032	Matthew Gonsalves	96.25
3392655	Alexander Shahpoor	96.25
3375583	Margustin Chauw	95.75
3354505	Ching Bau	95.33
3376647	Yanmin Qian	95.00
3302603	Darren Haffner	94.75
3395322	Simon Perri	94.75
\.

COPY q11_expected (unswid, name, academic_standing) FROM stdin;
3130081	Michael Freudenberg	Good
3135602	Shirley Caws	Good
3138484	Sean Turle	Good
3134989	Lana Glendenning	Good
3138391	Damchu Tenzin	Good
3136192	Blake Croll	Good
3137680	Benny Mok	Probation
3131454	Anne Tian	Good
3134238	Donna Soszyn	Good
3137261	Kabbara Reda	Good
3134817	William Grzanka	Referral
3135986	Hui Goh	Referral
3133614	Olivia Tyng	Good
3132714	Ling Zhang Yingli	Good
3139391	Hoi-Ho Kiong	Good
3139955	Margarita Kaplinovsky	Good
3134917	Pricila Komara	Good
3133520	Jonathan Szabo	Good
3131271	Jakree Aram-Arbhakul	Good
3132688	Cherri Haddock	Good
3138180	Nathan Baker	Good
3132349	Lucky Samuel	Good
3132152	Kwok Low	Good
3133527	Frederik Murtada	Good
3130459	Christopher Shim	Good
3138713	Selby Wilheim	Good
3139982	Janet Zulayati	Good
3133650	Jen Paramananthakarasu	Good
3135047	Jo-Anne Robin	Good
3130533	Eleanor Kersting-Neverly	Good
3139617	Jiong Irving	Good
3138174	Kaylin Doughty	Good
3130976	Edward Pon	Good
3134788	Michelle Flower	Good
3137489	Biswas Morcom	Good
3132545	Gordon Carmody	Good
3134506	Senthil Liew Jing Fa	Good
3138315	Peng Maher	Good
3130445	Corey O'Loughlan	Good
3137581	Mery Nimpuna	Referral
3136092	Brad Lyneham	Good
3139327	Greg Forman	Probation
3137927	Torunn Kotze	Good
3132827	Byoung-Sun Kang	Good
3132007	Suk Ham	Good
3139856	Fangnan Di	Good
3135592	Mohd Mohammad YuSup	Good
3136774	Mollie London	Good
3134072	Hamish Flick	Good
3132540	Jin-Oh Paick	Good
3139751	Celia English	Good
3132483	Shannelle Sijabat	Good
3133285	Lian Ogilvie	Good
\.

COPY q12_expected (code,name,year,s1_ps_rate,s2_ps_rate) FROM stdin;
COMP9020	Foundations of Comp. Science	03	1.00	\N
COMP9020	Foundations of Comp. Science	04	1.00	\N
COMP9020	Foundations of Comp. Science	06	1.00	0.50
COMP9020	Foundations of Comp. Science	07	1.00	1.00
COMP9020	Foundations of Comp. Science	08	1.00	0.89
COMP9020	Foundations of Comp. Science	09	0.91	1.00
COMP9020	Foundations of Comp. Science	10	1.00	1.00
COMP9020	Foundations of Comp. Science	11	0.88	0.97
COMP9020	Foundations of Comp. Science	12	0.97	0.57
COMP9021	Principles of Programming	03	0.80	0.67
COMP9021	Principles of Programming	04	0.88	0.50
COMP9021	Principles of Programming	05	1.00	\N
COMP9021	Principles of Programming	06	1.00	0.50
COMP9021	Principles of Programming	07	0.80	1.00
COMP9021	Principles of Programming	08	0.80	0.93
COMP9021	Principles of Programming	09	0.94	1.00
COMP9021	Principles of Programming	10	1.00	0.83
COMP9021	Principles of Programming	11	0.88	0.90
COMP9021	Principles of Programming	12	0.97	1.00
COMP9024	Data Structures & Algorithms	03	\N	1.00
COMP9024	Data Structures & Algorithms	04	1.00	0.83
COMP9024	Data Structures & Algorithms	05	1.00	0.00
COMP9024	Data Structures & Algorithms	06	\N	1.00
COMP9024	Data Structures & Algorithms	07	0.67	1.00
COMP9024	Data Structures & Algorithms	08	1.00	1.00
COMP9024	Data Structures & Algorithms	09	1.00	0.84
COMP9024	Data Structures & Algorithms	10	1.00	0.76
COMP9024	Data Structures & Algorithms	11	1.00	0.97
COMP9024	Data Structures & Algorithms	12	0.91	1.00
\.
