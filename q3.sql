-- Q3. North and South Connections

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3 (
    outbound VARCHAR(30),
    inbound VARCHAR(30),
    direct INT,
    one_con INT,
    two_con INT,
    earliest timestamp
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:

CREATE VIEW NorthAmericaDirect as 
SELECT 
    a_outbound.city as Outbound_City,
    a_inbound.city as Inbound_City,
    f.s_dep,
    f.s_arv,
    f.id as flightID,
    a_outbound.country as outboundCountry,
    a_inbound.country as inboundCountry,
    a_outbound.code as outboundCode,
    a_inbound.code as inboundCode,
    CASE 
        WHEN (a_outbound.country = 'Canada' AND a_inbound.country = 'USA')
            OR (a_outbound.country = 'USA' AND a_inbound.country = 'Canada')
            THEN 'North_America_International'
        ELSE 'North_America_Domestic'
    END AS Flight_Type

FROM flight f 
    LEFT JOIN airport a_outbound 
        ON f.outbound = a_outbound.code
    LEFT JOIN airport a_inbound
        ON f.inbound = a_inbound.code    
WHERE cast(f.s_dep as date)  = '2021-04-30' AND 
    cast(f.s_arv as date) = '2021-04-30';


CREATE VIEW OneConnectingFlight as 
SELECT 
    n2.Outbound_City,
    n1.Inbound_City,
    n2.s_dep,
    n1.s_arv,
    n2.outboundCountry,
    n1.inboundCountry
FROM NorthAmericaDirect n1
    INNER JOIN NorthAmericaDirect n2
        ON n1.Outbound_City = n2.Inbound_City AND n1.outboundCode = n2.inboundCode

WHERE n1.s_dep >= n2.s_arv + INTERVAL '0.5 hour'; --AND (n1.outboundCountry = 'Canada' AND n2.inboundCountry = 'USA')
            --OR (n1.outboundCountry = 'USA' AND n2.inboundCountry = 'Canada');


CREATE VIEW TwoConnectingFlight as 
SELECT 
    n3.Outbound_City,
    n1.Inbound_City,
    n3.s_dep as departure,
    n1.s_arv as arrival,
    n3.outboundCountry,
    n1.inboundCountry
FROM NorthAmericaDirect n1
    INNER JOIN NorthAmericaDirect n2
        ON n1.Outbound_City = n2.Inbound_City AND n1.outboundCode = n2.inboundCode
    INNER JOIN NorthAmericaDirect n3
        ON n2.Outbound_City = n3.Inbound_City AND n2.outboundCode = n3.inboundCode

WHERE n2.s_dep >= n3.s_arv + INTERVAL '0.5 hour' 
    AND n1.s_dep >= n2.s_arv + INTERVAL '0.5 hour';



CREATE VIEW Combined as 
Select Outbound_City,Inbound_City, count(*) as direct, 0 as one_con,  0 as two_con, min(s_arv) as earliest
from NorthAmericaDirect 
where Flight_Type = 'North_America_International'
group by Outbound_City,Inbound_City
Union ALL
Select Outbound_City,Inbound_City, 0 as direct, count(*) one_con, 0 as two_con, min(s_arv) as earliest
from OneConnectingFlight 
WHERE (outboundCountry = 'Canada' AND inboundCountry = 'USA')
            OR (outboundCountry = 'USA' AND inboundCountry = 'Canada')
group by Outbound_City,Inbound_City
Union ALL
Select Outbound_City,Inbound_City, 0 as direct, 0 as one_con, count(*) as two_con, min(arrival) as earliest
from TwoConnectingFlight
WHERE (outboundCountry = 'Canada' AND inboundCountry = 'USA')
            OR (outboundCountry = 'USA' AND inboundCountry = 'Canada')
group by Outbound_City,Inbound_City;



-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3
SELECT Outbound_City as outbound,Inbound_City as inbound, sum(direct) as direct, sum(one_con) as one_con, 
        sum(two_con) as two_con, min(earliest) as earliest
FROM Combined
group by Outbound_City,Inbound_City;


--CANADA TO USA
--Direct
    --Toronto-NewYork
--One Connecting Flight (Double Inner Join)
    --Toronto-Chicago-NewYork
    --Toronto-Vancouver-NewYork
    --Toronto->Paris->New York would be an acceptable path.   
--Two Connecting Flights (Triple Inner Join) 
    --Toronto n2 Chicago n1 Atlanta n3 NewYork
    --Toronto-Vancouver-Edmonton-NewYork
    --Toronto-Vancouver-Chicago-NewYork

--USA TO CANADA
--Opposite of above cases


--INSert into flight table extra example 
--in where clause put same airports

--Consider Toronto-London-Buffalo, is this possible? 
/*
insert into flight(id, airline, flight_num,plane,
                outbound,inbound,s_dep,s_arv)
values(15,'AC', 100, 'ABCDE','YYZ','ORD', '2021-04-30 10:30:00', 
    '2021-04-30 13:00:00');
    insert into flight(id, airline, flight_num,plane,
                outbound,inbound,s_dep,s_arv)
values(16,'AC', 102, 'ABCDE','ORD','BUF', '2021-04-30 13:50:00', 
    '2021-04-30 17:00:00');
    insert into flight(id, airline, flight_num,plane,
                outbound,inbound,s_dep,s_arv)
values(17,'AC', 103, 'ABCDE','BUF','JFK', '2021-04-30 18:20:00', 
    '2021-04-30 19:00:00');
insert into flight(id, airline, flight_num,plane,
                outbound,inbound,s_dep,s_arv)
values(19,'AC', 100, 'ABCDE','JFK','ORD', '2021-04-30 10:30:00', 
    '2021-04-30 13:00:00');
    insert into flight(id, airline, flight_num,plane,
                outbound,inbound,s_dep,s_arv)
values(20,'AC', 103, 'ABCDE','ORD','YVR', '2021-04-30 18:20:00', 
    '2021-04-30 19:00:00');
    insert into flight(id, airline, flight_num,plane,
                outbound,inbound,s_dep,s_arv)
values(21,'AC', 103, 'ABCDE','YVR','YYZ', '2021-04-30 20:20:00', 
    '2021-04-30 21:00:00');
*/

