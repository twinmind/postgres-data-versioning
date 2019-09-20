CREATE TABLE public.employee
(
    id text,
    departmentid text,
    locationid text,
    email text,
    status text,
    compensation numeric,
    hiredate timestamp without time zone,
    createdate timestamp without time zone NOT NULL DEFAULT now(),
    CONSTRAINT employee_pkey PRIMARY KEY (id)
)
