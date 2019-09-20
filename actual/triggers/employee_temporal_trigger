CREATE TRIGGER employee_temporal_trigger
    AFTER DELETE OR UPDATE 
    ON public.employee
    FOR EACH ROW
    EXECUTE PROCEDURE public.temporal();
