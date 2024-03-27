PRAGMA foreign_keys=OFF;
DROP TABLE IF EXISTS FLIGHT_CREW_MEMBER;
DROP TABLE IF EXISTS CREW_MEMBER;
DROP TABLE IF EXISTS AIRLINE;
DROP TABLE IF EXISTS FLIGHT;
DROP TABLE IF EXISTS ROUTE;
DROP TABLE IF EXISTS RENT_CONTRACT;
DROP TABLE IF EXISTS OWN_CONTRACT;
DROP TABLE IF EXISTS CONTRACT;
DROP TABLE IF EXISTS PLANE;
DROP TABLE IF EXISTS PLANE_MODEL;
DROP TABLE IF EXISTS AIRPORT;
DROP TABLE IF EXISTS COUNTRY;
BEGIN TRANSACTION;
CREATE TABLE COUNTRY(
ISO_CODE CHAR(2) CONSTRAINT ONLY_2_UPPER_LETTERS CHECK (ISO_CODE GLOB '[A-Z][A-Z]'),
NAME VARCHAR(50) NOT NULL,
PRIMARY KEY (ISO_CODE)
);
CREATE TABLE AIRPORT(
ID BIGINT,
NAME VARCHAR(50) NOT NULL,
IATA CHAR(3) CONSTRAINT ONLY_3_ALPHANUMERIC CHECK (IATA GLOB '[A-Za-z0-9][A-Za-z0-9][A-Za-z0-9]'),
ICAO CHAR(4) CONSTRAINT ONLY_4_UPPER_LETTERS CHECK (ICAO GLOB '[A-Z][A-Z][A-Z][A-Z]'),
LATITUDE DOUBLE NOT NULL,
LONGITUDE DOUBLE NOT NULL,
ISO_CODE CHAR(2) NOT NULL,
PRIMARY KEY (ID),
FOREIGN KEY (ISO_CODE) REFERENCES COUNTRY(ISO_CODE) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE PLANE_MODEL(
IATA CHAR(3) CONSTRAINT ONLY_3_ALPHANUMERIC CHECK (IATA GLOB '[A-Za-z0-9][A-Za-z0-9][A-Za-z0-9]'),
NAME VARCHAR(50),
ICAO CHAR(4) CONSTRAINT ONLY_4_ALPHANUMERIC CHECK (ICAO GLOB '[A-Za-z0-9][A-Za-z0-9][A-Za-z0-9][A-Za-z0-9]'),
PRIMARY KEY(IATA)
);
CREATE TABLE PLANE(
ID BIGINT,
CONDITION TINYINT NOT NULL DEFAULT 1, 
TRACKING_CODE VARCHAR(30),
IATA CHAR(3) NOT NULL,
PRIMARY KEY(ID),
FOREIGN KEY(IATA) REFERENCES PLANE_MODEL(IATA) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE CONTRACT(
ID BIGINT,
AIRLINE_ID BIGINT NOT NULL,
PLANE_ID BIGINT NOT NULL,
START_DATE DATETIME NOT NULL,
END_DATE DATETIME CONSTRAINT END_LATER_THAN_START CHECK (NULL OR (START_DATE < END_DATE)),          
PRIMARY KEY(ID),
FOREIGN KEY(AIRLINE_ID) REFERENCES AIRLINE(ID) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(PLANE_ID) REFERENCES PLANE(ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE OWN_CONTRACT(
CONTRACT_ID BIGINT,
PURCHASE_PRICE DECIMAL(19,4) NOT NULL,
CURRENCY CHAR(3) NOT NULL CONSTRAINT ONLY_3_UPPER_LETTERS CHECK (CURRENCY GLOB '[A-Z][A-Z][A-Z]'),
PRIMARY KEY(CONTRACT_ID),
FOREIGN KEY(CONTRACT_ID) REFERENCES CONTRACT(ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE RENT_CONTRACT(
CONTRACT_ID BIGINT,
RENT_PER_DAY DECIMAL(19,4) NOT NULL,
CURRENCY CHAR(3) NOT NULL CONSTRAINT ONLY_3_UPPER_LETTERS CHECK (CURRENCY GLOB '[A-Z][A-Z][A-Z]'),
PRIMARY KEY(CONTRACT_ID),
FOREIGN KEY(CONTRACT_ID) REFERENCES CONTRACT(ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE ROUTE(
ID BIGINT,
CODESHARE BOOLEAN NOT NULL DEFAULT FALSE,
STOPS TINYINT NOT NULL,
SOURCE_ID BIGINT NOT NULL,
DESTINATION_ID BIGINT NOT NULL,
AIRLINE_ID BIGINT NOT NULL,
PRIMARY KEY(ID),
FOREIGN KEY(SOURCE_ID) REFERENCES AIRPORT(ID) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(DESTINATION_ID) REFERENCES AIRPORT(ID) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(AIRLINE_ID) REFERENCES AIRLINE(ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE FLIGHT(
ID BIGINT,
DEPARTURE_TIME DATETIME NOT NULL,
ARRIVAL_TIME DATETIME NOT NULL CONSTRAINT ARRIVAL_LATER_THAN_DEPARTURE CHECK (DEPARTURE_TIME < ARRIVAL_TIME),
SOURCE_ID BIGINT NOT NULL,
DESTINATION_ID BIGINT NOT NULL,
PLANE_ID BIGINT,
AIRLINE_ID BIGINT NOT NULL,
ROUTE_ID BIGINT NOT NULL,
PRIMARY KEY(ID),
FOREIGN KEY(SOURCE_ID) REFERENCES AIRPORT(ID) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(DESTINATION_ID) REFERENCES AIRPORT(ID) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(PLANE_ID) REFERENCES PLANE(ID) ON DELETE SET NULL ON UPDATE SET NULL,
FOREIGN KEY(AIRLINE_ID) REFERENCES AIRLINE(ID) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(ROUTE_ID) REFERENCES ROUTE(ID) ON DELETE CASCADE ON UPDATE CASCADE,
UNIQUE(SOURCE_ID, ROUTE_ID, DEPARTURE_TIME)
);
CREATE TABLE AIRLINE(
ID BIGINT,
NAME VARCHAR(50) NOT NULL,
ALIAS VARCHAR(50),
IATA CHAR(2) CONSTRAINT ONLY_2_ALPHANUMERIC CHECK (IATA GLOB '[A-Za-z0-9][A-Za-z0-9]'),
ICAO CHAR(3) CONSTRAINT ONLY_3_UPPER_LETTERS CHECK (ICAO GLOB '[A-Z][A-Z][A-Z]'),
PARENT_ID BIGINT,
ISO_CODE CHAR(2) NOT NULL,
PRIMARY KEY(ID),
FOREIGN KEY(PARENT_ID) REFERENCES AIRLINE(ID) ON DELETE SET NULL ON UPDATE SET NULL,
FOREIGN KEY(ISO_CODE) REFERENCES COUNTRY(ISO_CODE) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE CREW_MEMBER(
ID BIGINT,
NAME VARCHAR(50) NOT NULL,
FUNCTION TINYINT NOT NULL,
PRIMARY KEY(ID)
);
CREATE TABLE FLIGHT_CREW_MEMBER(
FLIGHT_ID BIGINT NOT NULL,
CREW_MEMBER_ID BIGINT NOT NULL,
PRIMARY KEY(FLIGHT_ID, CREW_MEMBER_ID),
FOREIGN KEY(FLIGHT_ID) REFERENCES FLIGHT(ID) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY(CREW_MEMBER_ID) REFERENCES CREW_MEMBER(ID) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMIT;