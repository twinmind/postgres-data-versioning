CREATE TABLE temporal_staging (
   id bigserial primary key,
   modeltype text,
   modelid text,
   modeldata jsonb,
   operation varchar(10) not null,
   createdate timestamp not null default now()
);
CREATE INDEX temporal_staging_modelid_idx ON temporal_staging(modelid);
CREATE INDEX temporal_staging_modeltype_idx ON temporal_staging(modeltype);
