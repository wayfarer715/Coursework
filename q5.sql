-- Q5. Flight Hopping

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5 (
	destination CHAR(3),
	num_flights INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS day CASCADE;
DROP VIEW IF EXISTS n CASCADE;


CREATE VIEW n AS
SELECT n FROM q5_parameters;


CREATE VIEW day AS
SELECT day::date as day FROM q5_parameters;

DROP VIEW IF EXISTS recursive;
CREATE VIEW recursive AS 
WITH RECURSIVE numbers AS (
	(SELECT id, outbound, inbound, 1 AS n, s_dep, s_arv
	FROM flight   
	WHERE cast(s_dep as date) = (SELECT day from day) 
	) 
	 UNION ALL
    (SELECT f.id,f.outbound,f.inbound, n+1, f.s_dep, f.s_arv
	 FROM flight f, numbers num
	 WHERE f.inbound = num.outbound AND n<(SELECT n FROM n) AND (f.s_dep-num.s_arv)<'24:00:00'
	)
	)
	SELECT outbound,inbound,s_dep,s_arv --count(outbound) as count_Out,count(inbound) as count_in, count(n),max(n),min(n)
	FROM numbers
	GROUP BY outbound,inbound,s_dep,s_arv;
	



CREATE VIEW test as 
SELECT outbound as destination, count(*) as num_flights
FROM recursive
GROUP BY outbound
UNION ALL
SELECT inbound as destination, count(*) as num_flights
FROM recursive
GROUP BY inbound;



-- f.s_-num.s_dep
-- can get the given date using: (SELECT day from day)
-- can get the given number of flights using: (SELECT n from n)

-- HINT: You can answer the question by writing one recursive query below, without any more views.
-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q5
SELECT destination, num_flights
FROM test
GROUP BY destination,num_flights; 












