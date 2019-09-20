CREATE OR REPLACE VIEW vw_employee AS 
SELECT 
  	t.modelid as id,
    (t.modeldata->>'departmentid') as departmentid,
    (t.modeldata->>'locationid') as locationid,
    (t.modeldata->>'email') as email,
    (t.modeldata->>'status') as status,
    (t.modeldata->>'compensation')::decimal as compensation,
    (t.modeldata->>'hiredate')::timestamp  as hiredate,
    (t.modeldata->>'createdate')::timestamp as createdate,
    tsrange(
        COALESCE(
             (SELECT createdate from employee where modelid = t.modelid AND createdate < t.createdate ORDER BY createdate DESC LIMIT 1)
            ,(SELECT LEAST((t.modeldata->>'createdate')::timestamp without time zone, t.createdate - interval '1 microsecond'))
        )
        , createdate) as sys_period
FROM employee t;
