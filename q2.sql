-- Q2. Refunds!

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2 (
    airline CHAR(2),
    name VARCHAR(50),
    year CHAR(4),
    seat_class seat_class,
    refund REAL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:

CREATE VIEW refundType as
Select 
    air.code as airline,
    air.name as name, 
    date_part('year', d.datetime) as year,
    f.id,
    CASE 
    WHEN (d.datetime - f.s_dep) >= '10:00' AND (a.datetime - f.s_arv) > '05:00'
        AND A_outbound.country = A_inbound.country   
        THEN '50_refund'
    WHEN (d.datetime - f.s_dep) >= '05:00' AND (a.datetime - f.s_arv) > '02:30' 
        AND A_outbound.country = A_inbound.country         
        THEN '35_refund'
    WHEN (d.datetime - f.s_dep) >= '12:00' AND (a.datetime - f.s_arv) > '06:00' 
        AND A_outbound.country != A_inbound.country   
        THEN '50_refund'
    WHEN (d.datetime - f.s_dep) >= '08:00' AND (a.datetime - f.s_arv) > '04:00'
        AND A_outbound.country != A_inbound.country        
        THEN '35_refund'
    ELSE 'No_refund'
END AS Refund_type

FROM flight f 
    LEFT JOIN departure d 
        ON d.flight_id = f.id
    LEFT JOIN arrival a 
        ON f.id = a.flight_id
    LEFT JOIN airline air
        ON air.code = f.airline
    LEFT JOIN Airport A_inbound
        ON f.inbound = A_inbound.code
    LEFT JOIN Airport A_outbound
        ON f.outbound = A_outbound.code;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2

SELECT 
    airline,
    name, 
    year,
    seat_class,
    sum(CASE
    WHEN Refund_type = '50_refund' 
        THEN (.5*b.price) 
    WHEN Refund_type = '35_refund' 
        THEN (.35*b.price) 
    ELSE 0
    END) AS refund    
FROM refundType rt LEFT JOIN booking b
    ON rt.id = b.flight_id
WHERE Refund_type != 'No_refund'
GROUP BY
    airline,
    name, 
    year,
    seat_class;

--CONSIDER NULL VALUES, RUN TESTS
--SHOULD WE CONSIDER REFUNDS FOR FLIGHTS THAT NEVER DEPARTED - YES 100%?