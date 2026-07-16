-- Eliminar política de SELECT abierta
DROP POLICY IF EXISTS "verification_requests_select_all" ON public.verification_requests;

-- Nueva política: cada dispositivo ve solo sus propias solicitudes,
-- los admins habilitados ven todas
CREATE POLICY "Ver solicitudes propias o admin"
ON public.verification_requests
FOR SELECT
USING (
  device_id = current_setting('request.headers', true)::json->>'x-device-id'
  OR
  EXISTS (
    SELECT 1 FROM public.admin_devices
    WHERE admin_devices.device_id = current_setting('request.headers', true)::json->>'x-device-id'
      AND admin_devices.enabled = true
  )
);;
