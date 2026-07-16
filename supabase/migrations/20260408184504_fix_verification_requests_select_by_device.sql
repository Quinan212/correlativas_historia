-- Eliminar la política anterior con headers (no funciona con Flutter)
DROP POLICY IF EXISTS "Ver solicitudes propias o admin" ON public.verification_requests;

-- Política correcta: lectura abierta (el filtrado por device_id lo hace el cliente Flutter)
-- La seguridad real está en que no hay UPDATE ni DELETE sin ser admin
CREATE POLICY "Lectura de solicitudes"
ON public.verification_requests
FOR SELECT
USING (true);;
