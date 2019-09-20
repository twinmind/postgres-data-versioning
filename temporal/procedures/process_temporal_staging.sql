CREATE OR REPLACE PROCEDURE process_temporal_staging(batchSize INT) 
LANGUAGE plpgsql 
AS $$
DECLARE	
	err_context text;
	max_staging_id bigint;
	min_staging_id bigint;
	crow record;
	tables_count integer := 0;
	batch_size integer := batchSize;
	rows_affected integer;
	is_locked boolean;

	startTime timestamptz;
	endTime timestamptz;
	delta double precision;
BEGIN

SELECT pg_try_advisory_lock(101) INTO is_locked;
IF NOT is_locked THEN
	RAISE NOTICE 'Current procedure run cannot acquire lock at the moment.';
	RETURN;
END IF;

SELECT id INTO min_staging_id 
FROM actual.temporal_staging
WHERE modeltype IN 
(
  SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE' and table_name <> 'history_lookup'
)
ORDER BY id 
LIMIT 1;

IF FOUND THEN         
	RAISE NOTICE 'min staging id is %', min_staging_id;
	max_staging_id := min_staging_id + batch_size;
	RAISE NOTICE 'max staging id is %', max_staging_id;

	SELECT COUNT(1) INTO tables_count
	FROM information_schema.tables inf_tables 
	INNER JOIN (
		SELECT DISTINCT modeltype 
		FROM actual.temporal_staging 
		WHERE id >= min_staging_id 
		AND id < max_staging_id
	) wr 
	ON inf_tables.table_name = wr.modeltype
	WHERE table_schema = 'public' 
	AND table_type = 'BASE TABLE' and table_name <> 'history_lookup';
	

	IF tables_count > 0 THEN
		RAISE NOTICE 'Found % table(s)', tables_count;

		FOR crow IN
			SELECT table_name 
			FROM information_schema.tables inf_tables 
			INNER JOIN (
				SELECT DISTINCT modeltype 
				FROM actual.temporal_staging 
				WHERE id >= min_staging_id 
				AND id < max_staging_id
			) wr 
			ON inf_tables.table_name = wr.modeltype
			WHERE table_schema = 'public' AND table_type = 'BASE TABLE' and table_name <> 'history_lookup' 
			ORDER BY table_name
		LOOP
			RAISE NOTICE 'Moving temporal staging data to table %', crow.table_name;
			startTime := clock_timestamp();
			EXECUTE 'WITH moved_rows AS (
					DELETE FROM actual.temporal_staging
					WHERE id IN (
					SELECT id from actual.temporal_staging 
					WHERE modeltype = ''' || quote_ident(crow.table_name) || '''
					AND id < ' || max_staging_id || ' AND id >= ' || min_staging_id || '
					ORDER BY id
					)
					RETURNING *
				) 
				INSERT INTO ' || quote_ident(crow.table_name) || ' (modelid, modeldata, operation, createdate) 
				SELECT modelid,  modeldata, operation, createdate from moved_rows;';

			endTime := clock_timestamp();
			delta := 1000 * (extract(epoch from endTime) - extract(epoch from startTime));
			GET DIAGNOSTICS rows_affected = ROW_COUNT;
			RAISE NOTICE '-- rows affected: %', rows_affected;
			RAISE NOTICE '-- duration in millisecs: %', delta;
		END LOOP;
	ELSE
		RAISE NOTICE 'No tables found. Current DB user might not have access to SELECT on public schema tables';
	END IF;
ELSE
    RAISE NOTICE 'Min staging ID wasn''t found. Temporal staging is most likely empty';
END IF;

PERFORM pg_advisory_unlock(101);

EXCEPTION WHEN OTHERS THEN
  PERFORM pg_advisory_unlock(101);
        GET STACKED DIAGNOSTICS err_context = PG_EXCEPTION_CONTEXT;
        RAISE INFO 'Error Name:%',SQLERRM;
        RAISE INFO 'Error State:%', SQLSTATE;
        RAISE INFO 'Error Context:%', err_context;
        RAISE EXCEPTION '%', SQLERRM;

END $$;



--CALL process_temporal_staging(1000); --invocation
