CREATE EXTENSION IF NOT EXISTS postgres_fdw;

DROP SERVER IF EXISTS temporal_db CASCADE;

CREATE SERVER temporal_db
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', port '5432', dbname 'temporal');

CREATE USER MAPPING FOR postgres
SERVER temporal_db
OPTIONS (user 'postgres', password '<pwd>');

ALTER SERVER temporal_db OPTIONS (add use_remote_estimate 'true',add fetch_size '50000');


DROP SCHEMA IF EXISTS temporal CASCADE;

CREATE SCHEMA temporal;
IMPORT FOREIGN SCHEMA public FROM SERVER temporal_db INTO temporal;
