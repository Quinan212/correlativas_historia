-- Eliminar la política permisiva de UPDATE
DROP POLICY IF EXISTS "verification_requests_update_all" ON public.verification_requests;

-- Nueva política: solo pueden actualizar solicitudes los dispositivos admin habilitados
CREATE POLICY "Solo admins pueden actualizar solicitudes"
ON public.verification_requests
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.admin_devices
    WHERE admin_devices.device_id = reviewed_by_device_id
      AND admin_devices.enabled = true
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.admin_devices
    WHERE admin_devices.device_id = reviewed_by_device_id
      AND admin_devices.enabled = true
  )
);;
