CREATE TABLE public.parking_area
(
  id serial,
  parking_code character varying,
  parking_name character varying,
  parking_capacity integer,
  parking_filled double precision,
  "createdAt" timestamp with time zone,
  "updatedAt" timestamp with time zone,
  latitude character varying,
  longitude character varying,
  traffic_model character varying,
  CONSTRAINT parking_area_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.parking_area
  OWNER TO postgres;


CREATE TABLE public.parking_record
(
  id serial,
  parking_area_id integer,
  parking_entrance boolean,
  parking_exit boolean,
  bus_type integer,
  "createdAt" timestamp with time zone,
  "updatedAt" timestamp with time zone,
  CONSTRAINT parking_record_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.parking_record
  OWNER TO postgres;


CREATE TABLE public.project_prototype
(
  id serial,
  prototype character varying,
  "createdAt" timestamp with time zone,
  "updatedAt" timestamp with time zone,
  CONSTRAINT project_prototype_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.project_prototype
  OWNER TO postgres;

