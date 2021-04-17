-- Q4. Plane Capacity Histogram

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4 (
	airline CHAR(2),
	tail_number CHAR(5),
	very_low INT,
	low INT,
	fair INT,
	normal INT,
	high INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:
DROP VIEW IF EXISTS bookingsPerFlight;
CREATE VIEW bookingsPerFlight as 
SELECT b.flight_id, count(b.id) as numBookings, f.airline,f.plane
FROM booking b
	LEFT JOIN flight f
	ON b.flight_id = f.id 
	LEFT JOIN departure d
	ON b.flight_id = d.flight_id 
WHERE d.flight_id IS NOT NULL 
GROUP BY b.flight_id,f.airline,f.plane;

DROP VIEW IF EXISTS planeCapacity;
CREATE VIEW planeCapacity as
SELECT 
	p.airline, 
	p.tail_number,
	p.capacity_economy+p.capacity_business+p.capacity_first as denominator 
FROM plane p;


DROP VIEW IF EXISTS percentageType;
CREATE VIEW percentageType as 
SELECT p.airline, p.tail_number,numBookings,denominator,
	CASE 
	WHEN (numBookings*1.0/denominator)<.2
		THEN 1
	ELSE 0
	END as very_low,
	
	CASE
	WHEN
	 (numBookings*1.0/denominator)>=.2 AND (numBookings*1.0/denominator)<.4
		THEN 1
	ELSE 0
	END as low,
	
	CASE
	WHEN (numBookings*1.0/denominator)>=.4 AND (numBookings*1.0/denominator)<.6
		THEN 1
	ELSE 0
	END as fair,
	
	CASE
	WHEN (numBookings*1.0/denominator)>=.6 AND (numBookings*1.0/denominator)<.8
		THEN 1
	ELSE 0
	END as normal,

	CASE
	WHEN (numBookings*1.0/denominator)>=.8 
		THEN 1
	ELSE 0
	END as high

FROM planeCapacity p 
	LEFT JOIN bookingsPerFlight bpf
	ON bpf.airline = p.airline AND bpf.plane = p.tail_number;



-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q4
SELECT 
	airline, 
	tail_number, 
	sum(very_low) as very_low,
	sum(low) as low,
	sum(fair) as fair,
	sum(normal) as normal,
	sum(high) as high
FROM percentageType
GROUP BY airline, tail_number;


