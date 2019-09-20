CREATE OR REPLACE FUNCTION temporal()
  RETURNS trigger
  LANGUAGE plpgsql
  AS $function$
BEGIN

IF TG_OP = 'UPDATE'
THEN
INSERT INTO temporal_staging (operation, modeltype, modelid, modeldata)
VALUES (TG_OP, TG_TABLE_NAME, OLD.id, to_jsonb(OLD));
RETURN NEW;

ELSIF TG_OP = 'DELETE'
THEN
INSERT INTO temporal_staging (operation, modeltype, modelid, modeldata)
VALUES (TG_OP, TG_TABLE_NAME, OLD.id, to_jsonb(OLD));
RETURN OLD;
END IF;
END;
$function$ ;
