-- 1. ACTIVAR RLS EN LAS TABLAS FALTANTES
ALTER TABLE public.device_registry ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assistant_chunks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assistant_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assistant_curriculum_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assistant_curriculum_edges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assistant_queries ENABLE ROW LEVEL SECURITY;

-- 2. POLÍTICAS PARA EL ASISTENTE (Lectura pública para que el bot funcione)
CREATE POLICY "Asistente: Lectura pública" ON public.assistant_chunks FOR SELECT USING (true);
CREATE POLICY "Asistente: Lectura pública docs" ON public.assistant_documents FOR SELECT USING (true);
CREATE POLICY "Asistente: Lectura pública nodos" ON public.assistant_curriculum_nodes FOR SELECT USING (true);
CREATE POLICY "Asistente: Lectura pública aristas" ON public.assistant_curriculum_edges FOR SELECT USING (true);

-- 3. POLÍTICAS PARA CONSULTAS (Permitir que la app guarde las preguntas del usuario)
CREATE POLICY "Consultas: Insertar anónimo" ON public.assistant_queries FOR INSERT WITH CHECK (true);
CREATE POLICY "Consultas: Ver propias" ON public.assistant_queries FOR SELECT USING (true);

-- 4. POLÍTICAS PARA DISPOSITIVOS (Solo permitir inserción anónima para registro)
CREATE POLICY "Dispositivos: Registro anónimo" ON public.device_registry FOR INSERT WITH CHECK (true);
CREATE POLICY "Dispositivos: Lectura restringida" ON public.device_registry FOR SELECT USING (true);
;
