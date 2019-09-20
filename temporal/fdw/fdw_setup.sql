CREATE EXTENSION IF NOT EXISTS postgres_fdw;

DROP SERVER IF EXISTS actual_db CASCADE;

CREATE SERVER actual_db
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', port '5432', dbname 'actual');

CREATE USER MAPPING FOR postgres
SERVER actual_db
OPTIONS (user 'postgres', password '<pwd>');

ALTER SERVER actual_db OPTIONS (add use_remote_estimate 'true',add fetch_size '50000');


DROP SCHEMA IF EXISTS actual CASCADE;

CREATE SCHEMA actual;
IMPORT FOREIGN SCHEMA public FROM SERVER actual_db INTO actual;
