CREATE OR REPLACE VIEW temporal_employee AS 
SELECT 
  id
 ,departmentid
 ,locationid
 ,email
 ,status
 ,compensation
 ,hiredate
 ,createdate
  ,tsrange(COALESCE
                (
                 (SELECT createdate FROM temporal.employee WHERE modelid = t.id ORDER BY createdate DESC LIMIT 1),
                 createdate
                ), null) as sys_period
FROM employee t
UNION ALL
SELECT id
 ,departmentid
 ,locationid
 ,email
 ,status
 ,compensation
 ,hiredate
 ,createdate
 ,sys_period 
FROM temporal.vw_employee t
;
