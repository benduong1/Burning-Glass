drop database if exists bduong_bgt;

create database if not exists bduong_bgt;
use bduong_bgt;

drop table if exists burning_glass;

CREATE TABLE bduong_bgt.burning_glass (
    `JobID` varchar(9) DEFAULT NULL,
    `Stat_ID` VARCHAR(2) DEFAULT NULL,
    `State_Name` VARCHAR(2) DEFAULT NULL,
    `MSA_ID` VARCHAR(300) DEFAULT NULL,
    `MSA_Name` VARCHAR(300) DEFAULT NULL,
    `County` VARCHAR(300) DEFAULT NULL,
    `Occupation_Code` VARCHAR(300) DEFAULT NULL,
    `Occupation_Name` VARCHAR(300) DEFAULT NULL,
    `Occupation_Title` VARCHAR(300) DEFAULT NULL,
	`Degree_Level` VARCHAR(300) DEFAULT NULL,
    `Experience_Level` VARCHAR(300) DEFAULT NULL,
	`Edu_Major` VARCHAR(300) DEFAULT NULL,
    `Salary` INT(254) DEFAULT NULL,
    `Posting_Duration` INT(10) DEFAULT NULL,
    `Skill_ID` VARCHAR(300) DEFAULT NULL,
    `Skill_Name` VARCHAR(300) DEFAULT NULL,
    `Skill_Type` VARCHAR(300) DEFAULT NULL,
    `Cert_ID` INT(100) DEFAULT NULL,
    `Cert_Name` VARCHAR(300) DEFAULT NULL
);

TRUNCATE bduong_bgt.burning_glass;

load data local infile 'C://Users//bendu/Desktop//Burning_Glass//BGT.txt'

into table burning_glass
IGNORE 1 LINES;

SET SQL_SAFE_UPDATES=1;

### Will be creating tables from the Entity Relationship Diagram
### Starting with the tables that do not need bridges because these will be easier

create table Occupation
	select distinct Occupation_Code, Occupation_Name from burning_glass;
# Create table for Occupations and thier codes

   
create table `Exp_levels` (
	`Exp_id` INT(3) auto_increment,
    `Experience_level` VARCHAR(100),
    primary key (Exp_id)
);
insert Exp_levels(Experience_level) select distinct (Experience_level) from burning_glass;
# Create a table for Experience ID and its levels

drop table if exists States;
create table `States` (
	`State_id` Varchar(3),
    `State_name` VARCHAR(100),
    primary key (State_id)
);
# Create table for States

create table States
	select distinct Stat_id as state_id, state_name from burning_glass;
# Create table for States and their IDs    

drop table if exists Counties;
CREATE TABLE Counties (
    County_id INT Not NULL AUTO_INCREMENT,
    County_name varchar(255) NOT NULL,
    PRIMARY KEY (County_id)
);
# Create table for counties

insert Counties(County_name) select distinct County from burning_glass;
# Added county_names so that I can give them unique county_ids
# Could not give unique county_ids in burning_glass due to duplicates

drop table if exists MSA;
create table MSA 
select distinct MSA_ID, MSA_Name from burning_glass;
# Creates table for MSA


drop table if exists Titles;
CREATE TABLE Titles (
    Title_id INT Not NULL AUTO_INCREMENT,
    Title_name varchar(255) NOT NULL,
    PRIMARY KEY (Title_id)
);
insert Titles(Title_name) select distinct Occupation_Title from burning_glass;
# Create table and primary key ids for titles (occupation title)

## Now all of the parent tables are made

# Below will be working on the tables that require bridge tables


drop table if exists job_cert;
create table job_cert
select distinct Cert_id, jobid from burning_glass;
# Create bridge table job_cert

drop table if exists cert;
create table cert
select distinct cert_id, cert_name from burning_glass;
# Create table for certs and their names

drop table if exists Degree;
create table Degree (
	degree_id INT(2) auto_increment,
    degree_level Varchar(100),
    primary key (degree_id)
);
insert Degree(degree_level) select distinct degree_level from burning_glass;
# Create a brdige table for Jobs and Degree
select * from Degree;

drop table if exists Jobs_degrees;
create table Jobs_degrees
select distinct JobID, Degree_id from bduong_bgt.burning_glass as a
	inner join bduong_bgt.Degree as b on a.degree_level = b.degree_level;
# Create a bridge table for Jobs and degrees
    
create table Jobs_major (
	Major_id int(20),
    JobID varchar(200),
    edu_major varchar(200),
    Primary key (Major_id));
# Create bridge table for Jobs and Majors

drop table if exists Major;
CREATE TABLE Major (
    major_id INT Not NULL AUTO_INCREMENT,
    edu_major varchar(255) NOT NULL,
    PRIMARY KEY (major_id)
);
insert Major(edu_major) select distinct edu_major from burning_glass;
# Create table for Majors

drop table if exists Jobs_major;
create table Jobs_major
select distinct JobID, Major_id from bduong_bgt.burning_glass as a
inner join bduong_bgt.Major as b on a.edu_major = b.edu_major;
# Create a bridge table for Jobs and Majors

create table Skills
select distinct Skill_ID, Skill_Name, Skill_Type from burning_glass;
# Create a table for Skills

create table Jobs_skills
select distinct JobID, Skill_ID from burning_glass;
# Create a bridge table for Jobs and skills

create table Jobs (
	ID INT NOT NULL auto_increment Primary Key)
	select distinct
    JobID, 
    a.Occupation_Code, 
    a.stat_ID,
    a.MSA_ID,
    a.Posting_Duration,
    a.Salary,
    b.Title_id,
    c.Exp_id,
    d.County_id
    from burning_glass as a
		left join root_bgt.Titles as b on a.Occupation_Title = b.Title_name
        left join root_bgt.exp_levels as c on a.Experience_level = c.Experience_level
        left join root_bgt.Counties as d on a.County = d.County_name;

### All tables have been created ###

select count(distinct Skill_Name) from burning_glass;
# There are 6221 distinct skill names

select count(distinct Cert_ID) from burning_glass;
# There are 1227 distinct Cert IDs

# It takes too long to create the main Jobs table so I will be using the BGT_Class.Jobs table for tableau

select count(distinct JobID) as count, Occupation_Name from Jobs as a
	inner join Occupations as b on a.Occupation_Code=b.Occupation_Code
		where MSA_ID = 234
		group by Occupation_Name
		order by count DESC;
# Outputs which Occupation_Names are posted the most. Will be looking at the top 11
# Retail Sales Associate, Registered Nurse, Software Developer, Sales Representative, Financial Manager,
# Cashier, Customer Service Representative, Retail Supervisor, Business / Managerment Analyst, 
# Teller, Office / Administrative Assistant

select count(distinct JobID) from Jobs
where Occupation_name = "Registered Nurse";

select count(distinct JobID) as count, Occupation_Name from Jobs as a
	inner join Occupations as b on a.Occupation_Code = b.Occupation_Code
    where MSA_ID = 234
    group by Occupation_Name
    order by count DESC;
# The most number 12 JobIDs by Occupation Title are
# Sales Associate, Registered Nurse, Personal Banker, Assistant Store Manager, Teller
# Assistant Manager, Cashier, Software Development Engineer, Store Manager, Business Analyst
# Sales Trainee, Store Cashier

# Certified Public Accountant(CPA) is the second most in demand certification
# So I will be analyzing the details of it
# How much experience does it require?
# What jobs titles need it?
# Degree level it requires?
# It's salary distribution?
select Cert_ID from Certs
where Cert_name = "Certified Public Accountant";
# The Cert_IDs are 95, 4681, and 4682

select avg(posting_duration), Cert_Name from Jobs as a
	inner join Jobs_Certs as b on a.JobID = b.JobID
    inner join Certs as c on b.Cert_ID = c.Cert_ID
    where MSA_ID = 234
    and Cert_Name = "Certified Public Accountant"
    group by Cert_Name;
# The average posting duration for jobs with Certified Public Accountants is 39
# There are many jobs that ask for CPA, but they are filled quickly Therefore there is not
# A skills gap
# Will not look into CPA further

# The next most in demand certification is Programming Certification with 23,398 distint IDs
select Cert_ID from Certs
where Cert_name = "Programming Certification (E.G. Java Programming Cert)";
# The Cert_IDs for Programming Certifications are 896 and 957

select avg(posting_duration), Cert_Name from Jobs as a
	inner join Jobs_Certs as b on a.JobID = b.JobID
    inner join Certs as c on b.Cert_ID = c.Cert_ID
    where MSA_ID = 234
    and Cert_Name = "PROGRAMMING CERTIFICATION (E.G. JAVA PROGRAMMING CERT)"
    group by Cert_Name;
# The average posting duration is 125
# That is a high average posting duration. Perhaps there is a skill gap here

select count(ID) from Jobs as a
	inner join Jobs_Certs as b on a.JobID = b.JobID
    inner join Certs as c on b.Cert_ID = c.Cert_ID
    where MSA_ID = 234
    and Cert_Name = "PROGRAMMING CERTIFICATION (E.G. JAVA PROGRAMMING CERT)";
# Only 269 distinct IDs are asking for Programming Certifications so this is not in-demand

### Here we will focus on Registered Nurses and Software Developers
### Those occupations are in the most demand and we will see what kind of skills they are looking for

select a.Occupation_Code, Occupation_Name from Jobs as a
	inner join Occupations as b on a.Occupation_Code = b.Occupation_Code;

select count(Skill_Name) as count, Skill_Name from Skills as a
	inner join Jobs_Skills as b on b.Skill_ID = a.Skill_ID
    inner join Jobs as c on b.JobID = c.JobID
    inner join Occupations as d on c.Occupation_Code = d.Occupation_Code
    where Occupation_Name = "Registered Nurse"
    group by Skill_Name
    order by count DESC;
# Provides the list of Skills needed for registered nurses
# List of top 4 that I feel can we trained for
# Discharge Planning, Treatment Planning, Patient/Family Education and Instruction, Advanced Cardias Life Support (ACLS)

select count(Skill_Name) as count, Skill_Name from Skills as a
	inner join Jobs_Skills as b on b.Skill_ID = a.Skill_ID
    inner join Jobs as c on b.JobID = c.JobID
    inner join Occupations as d on c.Occupation_Code = d.Occupation_Code
    where Occupation_Name = "Software Developer / Engineer"
    group by Skill_Name
    order by count DESC;
# The list of top 5 needed skills for Software Developers are
# Java, Communication Skills, Software Engineering, Writing, SOL, Problem Solving, and Linux

select count(Cert_Name) as count, Cert_Name from Certs as a
	inner join Jobs_Certs as b on b.Cert_ID = a.Cert_ID
    inner join Jobs as c on b.JobID = c.JobID
    inner join Occupations as d on c.Occupation_Code = d.Occupation_Code
    where Occupation_Name = "Registered Nurse"
    group by Cert_Name
    order by count DESC;
# List of top 5 Certs for Registered Nurses #(count)
# Registered Nurse #5437, Advance Cardiac Life Support (ACLS) Certification #1227, First Aid CPR WED #806,
# Basic Cardiac Life Support Certification #710, American Heart Association Certificate #341
# Those above 5 are what NYC should invest money in training its population

select count(Cert_Name) as count, Cert_Name from Certs as a
	inner join Jobs_Certs as b on b.Cert_ID = a.Cert_ID
    inner join Jobs as c on b.JobID = c.JobID
    inner join Occupations as d on c.Occupation_Code = d.Occupation_Code
    where Occupation_Name = "Software Developer / Engineer"
    group by Cert_Name
    order by count DESC;
# The above code creates a list and count of the Certifications in the most demand for 
# Software Developers
# The certifications in demand are (>50)
# Capability Model Maturity Integration (Cmmi) Certification, 
# Certified Information Systems Security Professional (CISSP), Microsoft Certified Application Developer
# Those 3 certifications NYC should invest money in


select count(a.Exp_ID) as count, a.Experience_Level from Exp_Levels as a
	inner join Jobs as b on b.Exp_ID = a.Exp_ID
    inner join Occupations as d on b.Occupation_Code = d.Occupation_Code
    where Occupation_Name = "Registered Nurse"
    group by Experience_Level
    order by count DESC;
# Provides count of Experience Levels needed

select count(a.Exp_ID) as count, a.Experience_Level from Exp_Levels as a
	inner join Jobs as b on b.Exp_ID = a.Exp_ID
    inner join Occupations as d on b.Occupation_Code = d.Occupation_Code
    where Occupation_Name = "Software Developer / Engineer"
    group by Experience_Level
    order by count DESC;
# Provides count of Experience Levels needed

select count(a.Degree_level) as count, a.Degree_Level from Degrees as a
	inner join Jobs_Degrees as b on b.Degree_ID = a.Degree_ID
    inner join Jobs as d on b.JobID = d.JobID
    inner join Occupations as e on d.Occupation_Code = e.Occupation_Code
    where Occupation_Name = "Software Developer / Engineer"
    group by Degree_Level
    order by count DESC;
# Provides count for Degree Level for software

select count(a.Degree_level) as count, a.Degree_Level from Degrees as a
	inner join Jobs_Degrees as b on b.Degree_ID = a.Degree_ID
    inner join Jobs as d on b.JobID = d.JobID
    inner join Occupations as e on d.Occupation_Code = e.Occupation_Code
    where Occupation_Name = "Registered Nurse"
    group by Degree_Level
    order by count DESC;
# Provides the degree level needed for Registered Nurses

# For Financial Analyst there is a small avg posting duration in Maine and Vermont 5.2 and 3 respectively
# Lets see why that is

select count(distinct JobID), State_Name from Jobs as a
	inner join Occupations as b on a.Occupation_Code = b.Occupation_Code
    inner join States as c on a.State_ID = c.State_ID
    where Occupation_Name = "Software Developer / Engineer"
    and State_Name = "MA"
    or State_Name = "NY"
    group by State_Name;
# Seeing how many distinct Jobs for "Software Developer / Engineer" there are for NY and MA
# There is not enough to pouch workers from MA to NY

create table bduong.SOCLevel(
	`SOCLevel` INT(3) Default Null,
    `Occupation_Name` Varchar(200) Default NUll
    );

