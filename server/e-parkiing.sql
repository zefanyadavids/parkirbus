CREATE TABLE parking_area
(
  id serial PRIMARY KEY,
  parking_code character varying,
  parking_name character varying,
  parking_capacity integer,
  parking_filled integer,
  "createdAt" timestamp with time zone,
  "updatedAt" timestamp with time zone
);

CREATE TABLE parking_record
(
  id serial PRIMARY KEY,
  parking_area_id integer,
  parking_entrance boolean,
  parking_exit boolean,
  bus_type integer,
  "createdAt" timestamp with time zone,
  "updatedAt" timestamp with time zone
);

CREATE TABLE project_prototype
(
  id serial PRIMARY KEY,
  prototype character varying,
  "createdAt" timestamp with time zone,
  "updatedAt" timestamp with time zone
);
