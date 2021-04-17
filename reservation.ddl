-- Q1 (a) ---
-- age, sName, rating could be redundant
/*
Reservation
sID age length  sName   day                 cName  rating  cID
---------------------------------------------------------------
s1  45  17      sName1  2021-04-15 8:00:00  cName1  3       c1
s1  45  15      sName1  2021-04-15 9:00:00  cName2  3       c2

*/

/*
Overview of the solution design for Q1
1.  The relation Reservation has been split into three tables according to 
    DB design theory and normalization: two entity tables (SKIPPER, CRAFT) and 
    one relationship table (RESERVATIONS). This achieves the requiremenet of having 
	as few redundancies as possible.
2.  Added constraint "NOT NULL" for each column in a table which contains important
    information according to our real life experience 
3.  Added validation of some columns' value in a table, such as for
    - SKIPPER.age: make sure that a value is more than 0
    - SKIPPER.rating: make sure that a value is between 0 and 5 (inclusive)
4.  Added comments for some columns to make sure that a valid value is inserted/updated
    such as:
    - CRAFT.length: a comment 'in feet' describes what a number represents
*/

drop schema if exists reservation cascade;
create schema reservation;
set search_path to reservation;

--create table SKIPPER to hold FD: sID -> sName, rating, age
DROP TABLE IF EXISTS SKIPPER CASCADE;
CREATE TABLE SKIPPER (
    sID integer NOT NULL,
    sName VARCHAR(30) NOT NULL,
    rating INT CHECK(rating >= 0 AND rating <= 5) NOT NULL,
    age INT CHECK(age > 0) NOT NULL,
    CONSTRAINT skipper_pkey PRIMARY KEY (sID)
);

--create table CRAFT to hold FD: cID -> cName, length
DROP TABLE IF EXISTS CRAFT CASCADE;
CREATE TABLE CRAFT (
    cID integer NOT NULL,
    cName VARCHAR(30) NOT NULL,
    length INT NOT NULL,
    CONSTRAINT craft_pkey PRIMARY KEY (cID)
);
COMMENT ON COLUMN CRAFT.length IS 'in feet';
--create table RESERVATIONS to bind sID, cID and reserved day (date + time)

DROP TABLE IF EXISTS RESERVATIONS CASCADE;
CREATE TABLE RESERVATIONS (
    sID integer NOT NULL,
    cID integer NOT NULL,
    day timestamp without time zone NOT NULL,
    CONSTRAINT reservations_skipper_fkey FOREIGN KEY (sID)
        REFERENCES SKIPPER (sID),
    CONSTRAINT reservations_craft_fkey FOREIGN KEY (cID)
        REFERENCES CRAFT (cID),
	CONSTRAINT one_skipper_per_day UNIQUE (sID, day),
	CONSTRAINT one_craft_reservation_per_day UNIQUE (cID, day),
    CONSTRAINT reservations_pkey PRIMARY KEY (sID, cID, day)
);
