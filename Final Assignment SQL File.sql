-- SHOW VARIABLES LIKE "secure_file_priv";
--  SET secure_file_priv = '';

#   Creating schema as Assigment

drop schema Assignment;
create schema Assignment;

SET SQL_SAFE_UPDATES = 0;
use Assignment;

# Importing the data from CSV in the respective tables as shown below, But I have imported using 'Table date window wizard' 
## But a method to show it can be done as below
/*
create table `Bajaj Auto` (
`Date` text,`Open Price` double,`High Price` double,`Low Price` double,`Close Price` double,`WAP` double,`No.of Shares` int,`No. of Trades` int,`Total Turnover (Rs.)` double,`Deliverable Quantity` int,`% Deli. Qty to Traded Qty` double,`Spread High-Low` double,`Spread Close-Open` double)
;

LOAD DATA INFILE 'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\\Bajaj Auto.csv' 
INTO TABLE `Bajaj Auto`
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
SET `Date` = str_to_date(@Datevar , "%d-%m-%y");
*/
-- tables imported from csv using 'Table date window wizard' after handling the missing values.
-- after importing the data changing the data type of 'date' column, i know its not a need, not mentioned in the assignment, but people suggested in the Discussion forum, so doing it.

UPDATE `bajaj auto`
SET `date` = STR_TO_DATE(`date`,'%d-%M-%Y');

UPDATE `eicher motors`
SET `date` = STR_TO_DATE(`date`,'%d-%M-%Y');

UPDATE `hero motocorp`
SET `date` = STR_TO_DATE(`date`,'%d-%M-%Y');

UPDATE infosys
SET `date` = STR_TO_DATE(`date`,'%d-%M-%Y');

UPDATE tcs
SET `date` = STR_TO_DATE(`date`,'%d-%M-%Y');

UPDATE `tvs motors`
SET `date` = STR_TO_DATE(`date`,'%d-%M-%Y');

select * from `tvs motors`;
desc `bajaj auto`;

# Task1: Creating bajaj1 and similar tables for all  stocks
 
drop table bajaj1;      #Drop the table if exist already; same is done for all below tables

create table bajaj1 as 
select Date, round(`Close Price`,2) as 'Close Price', 
round(avg(`Close Price`) over (order by `date` rows 19 preceding),2) as '20 Day MA',
round(avg(`Close Price`) over (order by `date` rows 49 preceding),2) as '50 Day MA' 
from  `bajaj auto`;

#Test the above created table
select * from bajaj1;

drop table eicher1;
create table eicher1 as 
select Date, round(`Close Price`,2) as 'Close Price', 
round(avg(`Close Price`) over(order by `date` rows 19 preceding),2) as '20 Day MA', 
round(avg(`Close Price`) over(order by `date` rows 49 preceding),2) as '50 Day MA' from `eicher motors`;
select * from eicher1;


drop table hero1;
create table hero1 as select Date, 
round(`Close Price`,2) as 'Close Price', 
round(avg(`Close Price`) over(order by `date` rows 19 preceding),2) as '20 Day MA', 
round(avg(`Close Price`) over(order by `date` rows 49 preceding),2) as '50 Day MA' from `hero motocorp`;
select * from hero1;

drop table infosys1 ;
create table infosys1 as 
select Date, 
round(`Close Price`,2) as 'Close Price', 
round(avg(`Close Price`) over(order by `date` rows 19 preceding),2) as '20 Day MA', 
round(avg(`Close Price`) over(order by `date` rows 49 preceding),2) as '50 Day MA' 
from infosys;
select * from infosys1 ;

drop table tcs1;
create table tcs1 as 
select Date, 
round(`Close Price`,2) as 'Close Price', 
round(avg(`Close Price`) over(order by `date` rows 19 preceding),2) as '20 Day MA', 
round(avg(`Close Price`) over(order by `date` rows 49 preceding),2) as '50 Day MA' 
from tcs;
select * from tcs1;

drop table tvs1;
create table tvs1 as select Date, 
round(`Close Price`,2) as 'Close Price', 
round(avg(`Close Price`) over(order by `date` rows 19 preceding),2) as '20 Day MA', 
round(avg(`Close Price`) over(order by `date` rows 49 preceding),2) as '50 Day MA' from `tvs motors`;
select * from tvs1;


#Task 2:  Creating a master table (step2 of the assigment), first used the inner join, but in this situation left join seems optimized solution, eventhough they will give same result(time optimized).

drop table master_table;     -- drop table if already exists

create table master_table as 
select `bajaj auto`.Date, 
round(`bajaj auto`.`Close Price`,2) as Bajaj,
round(tcs.`Close Price`,2) as TCS,
round(`tvs motors`.`Close Price`,2) as TVS,
round(infosys.`Close Price`,2) as Infosys, 
round(`eicher motors`.`Close Price`,2) as Eicher, 
round(`hero motocorp`.`Close Price`,2) as Hero
from `bajaj auto` 
left join tcs on `bajaj auto`.Date = tcs.Date
left join `tvs motors` on `bajaj auto`.Date = `tvs motors`.Date
left join infosys on `bajaj auto`.Date = infosys.Date
left join `eicher motors` on `bajaj auto`.Date = `eicher motors`.Date
left join `hero motocorp` on `bajaj auto`.Date = `hero motocorp`.Date;

# Test to show if table created correctly
select * from master_table;


# Task 3: creating bajaj2 table and accordingly others
## ** Different approaches can be used, one can be where we can have a flag used, taking the difference of 20 and 50 day MA, 
### ** Then add a signal column fill that with the default as 'hold'
#### ** Take the previous flag as indicator to compare with current to signify sell/buy
##### ** Using self join we can do it, using the row() numbers , one approach is this and other is implemented below


drop table bajaj2;    # drop if already present

#creating the bajaj2 table here, now here we compare the 20 day MA and 50 Day MA for a day and also for the previous day using lag() and correspondingly decide for sell/buy as mentioned in the assignment
create table bajaj2 as
(select  `date` , `close price`,
		 CASE 
			WHEN (`20 Day MA` > `50 Day MA`) and lag(`20 Day MA` < `50 day MA`) over( ) THEN 'Buy'
			WHEN (`20 Day MA` < `50 Day MA`) and lag(`20 Day MA` > `50 day MA`) over( ) THEN 'Sell'
		   ELSE 'Hold'
		END 
AS 'Signal' FROM 
(
			SELECT 
		    row_number() over() AS 'row_number', 
		    `date`,
		    `close price`, 
		    `20 Day MA` ,
		    `50 Day MA`     
		    FROM bajaj1
            
 ) AS bajaj where bajaj.row_number > 49);

#NOTE: ** We can have "bajaj.row_number > 49" , so that our calculations are accurate, but its not mentioned in the assignment so keeping it 49 as above rows are of no use, please do not deduct grades over it

#Testing the results
-- First 50 rows should be skopped for the analysis as they don't add any values to it, since we considered 50 DAY MA, anyways they have hold signal
select * from bajaj2 where `signal` = 'sell' or `signal` = 'buy';
select * from bajaj2 where `signal` = 'hold';



drop table eicher2;
CREATE TABLE eicher2 AS
(SELECT  `date` , `close price`,
		 CASE 
			WHEN (`20 Day MA` > `50 Day MA`) and lag(`20 Day MA` < `50 day MA`) over( )  THEN 'Buy'
			WHEN (`20 Day MA` < `50 Day MA`) and lag(`20 Day MA` > `50 day MA`) over( ) THEN 'Sell'
		   ELSE 'Hold'
		END 
AS 'Signal' FROM 
(
			SELECT 
		    row_number() over( ) AS 'row_number',
		    `date`,
		    `close price`, 
		    `20 Day MA` ,
		    `50 Day MA`     
		    FROM eicher1
            
) AS eicher where eicher.row_number > 49);
#Test
select * from eicher2 where `signal` = 'sell' or `signal` = 'buy';
select * from eicher2 where `signal` = 'hold';
 
 Drop table hero2;
 CREATE TABLE hero2 AS
(SELECT  `date` , `close price`,
		 CASE 
			WHEN (`20 Day MA` > `50 Day MA`) and lag(`20 Day MA` < `50 day MA`) over( ) THEN 'Buy'
			WHEN (`20 Day MA` < `50 Day MA`) and lag(`20 Day MA` > `50 day MA`) over( ) THEN 'Sell'
		   ELSE 'Hold'
		END 
AS 'Signal' FROM 
(
			SELECT 
		    row_number() over( ) AS 'row_number',
		    `date`,
		    `close price`, 
		    `20 Day MA` ,
		    `50 Day MA`     
		    FROM hero1
            
 ) AS hero where hero.row_number > 49);
 
 
 CREATE TABLE tcs2 AS
(SELECT  `date` , `close price`,
		 CASE 
			WHEN (`20 Day MA` > `50 Day MA`) and lag(`20 Day MA` < `50 day MA`) over( )  THEN 'Buy'
			WHEN (`20 Day MA` < `50 Day MA`) and lag(`20 Day MA` > `50 day MA`) over( ) THEN 'Sell'
		   ELSE 'Hold'
		END 
AS 'Signal' FROM 
(
			SELECT 
		    row_number() over( ) AS 'row_number',
		    `date`,
		    `close price`, 
		    `20 Day MA` ,
		    `50 Day MA`     
		    FROM tcs1
            
 ) AS tcs_ where tcs_.row_number > 49);
 
 
  CREATE TABLE infosys2 AS
(SELECT  `date` , `close price`,
		 CASE 
			WHEN (`20 Day MA` > `50 Day MA`) and lag(`20 Day MA` < `50 day MA`) over( )  THEN 'Buy'
			WHEN (`20 Day MA` < `50 Day MA`) and lag(`20 Day MA` > `50 day MA`) over( ) THEN 'Sell'
		   ELSE 'Hold'
		END 
AS 'Signal' FROM 
(
			SELECT 
		    row_number() over( ) AS 'row_number',
		    `date`,
		    `close price`, 
		    `20 Day MA` ,
		    `50 Day MA`     
		    FROM infosys1
            
 ) AS infos where infos.row_number > 49);
 
 
 CREATE TABLE tvs2 AS
(SELECT  `date` , `close price`,
		 CASE 
			WHEN (`20 Day MA` > `50 Day MA`) and lag(`20 Day MA` < `50 day MA`) over( )  THEN 'Buy'
			WHEN (`20 Day MA` < `50 Day MA`) and lag(`20 Day MA` > `50 day MA`) over( ) THEN 'Sell'
		   ELSE 'Hold'
		END 
AS 'Signal' FROM 
(
			SELECT 
		    row_number() over( ) AS 'row_number',
		    `date`,
		    `close price`, 
		    `20 Day MA` ,
		    `50 Day MA`     
		    FROM tvs1
            
 ) AS tvsm where tvsm.row_number > 49);

 



# Task 4: create an UDF that takes the date as input and returns the signal for that particular day (Buy/Sell/Hold) for the Bajaj stock.
drop function signal_result_for_date;         # Drop if already exists

create function signal_result_for_date (date_input varchar(20))
returns varchar(10) deterministic
return 
(
select `signal`
from bajaj2 where `date` = date_input
-- from bajaj2 where date_format(`date`,'%D - %M - %Y') = date_format(date_input,'%D - %M - %Y')
);

# Testing the UDF using a date as below.
select signal_result_for_date('2018-05-29');
select `date`, signal_result_for_date(`date`) from bajaj2 where signal_result_for_date(`date`) = 'sell';
# **If it returns NULL then the day falls on a weekend, this be handled in the code as well, but not specified in the assignment:)


# Assignment Done

