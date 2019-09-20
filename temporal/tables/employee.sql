CREATE TABLE public.employee
(
    modelid,
    modeldata jsonb,
    operation character varying(10),
    createdate timestamp without time zone NOT NULL DEFAULT now()
)
