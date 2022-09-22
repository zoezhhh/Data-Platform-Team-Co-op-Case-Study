DROP DATABASE IF EXISTS snapcommerce;
CREATE DATABASE snapcommerce;
USE snapcommerce;
DROP TABLE IF EXISTS Flight;
CREATE TABLE Flight (
  `Airline Code` TEXT,
  `DelayTimes` TEXT,
  `FlightCodes` Integer PRIMARY KEY,
  `To` TEXT,
  `From` TEXT
);

DROP FUNCTION IF EXISTS capitalize;
DELIMITER $$
CREATE FUNCTION capitalize(t TEXT) RETURNS TEXT DETERMINISTIC
BEGIN
  RETURN CONCAT(UPPER(LEFT(t,1)),LOWER(SUBSTRING(t,2)));
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS readData;
DELIMITER $$
CREATE PROCEDURE readData(data TEXT)
BEGIN
  DECLARE pos INT;
  DECLARE line TEXT;
  DECLARE airline_code TEXT;
  DECLARE delay_time TEXT;
  DECLARE flight_code TEXT;
  DECLARE to_from TEXT;
  DECLARE int_code INT;
  -- ignore the header
  SET line = SUBSTRING_INDEX(data, "\n", 1);
  SET data = SUBSTRING(data, LENGTH(line)+2);
  -- read each line
  WHILE LENGTH(data) > 0 DO 
    SET line = SUBSTRING_INDEX(data, "\n", 1);
    SET data = SUBSTRING(data, LENGTH(line)+2);
    -- extract each column
    SET airline_code = SUBSTRING_INDEX(line, ";", 1);
    SET line = SUBSTRING(line, LOCATE(";", line)+1);
    SET delay_time = SUBSTRING_INDEX(line, ";", 1);
    SET line = SUBSTRING(line, LOCATE(";", line)+1);
    SET flight_code = SUBSTRING_INDEX(line, ";", 1);
    SET line = SUBSTRING(line, LOCATE(";", line)+1);
    SET to_from = SUBSTRING_INDEX(line, ";", 1);
    -- process extracted data
    SET int_code = IF(flight_code <> "",CAST(flight_code AS DECIMAL) , int_code + 10);
    -- add to table
    INSERT INTO Flight
    VALUES (
        TRIM(REGEXP_REPLACE(airline_code, '[^a-zA-Z ]*', '')),
        delay_time,
        int_code,
        capitalize(SUBSTRING_INDEX(to_from, "_", 1)),
        capitalize(SUBSTRING_INDEX(to_from, "_", -1))
    );
  END WHILE;
END $$
DELIMITER ;

SET @flightData = 'Airline Code;DelayTimes;FlightCodes;To_From\nAir Canada (!);[21, 40];20015.0;WAterLoo_NEWYork\n<Air France> (12);[];;Montreal_TORONTO\n(Porter Airways. );[60, 22, 87];20035.0;CALgary_Ottawa\n12. Air France;[78, 66];;Ottawa_VANcouvER\n""".\\.Lufthansa.\\.""";[12, 33];20055.0;london_MONTreal\n';

CALL readData(@flightData);

SELECT * FROM Flight

