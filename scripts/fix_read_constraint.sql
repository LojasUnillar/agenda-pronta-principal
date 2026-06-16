-- CORREÇÃO DA TABELA DE LEITURAS
-- ID do Erro: 23505 (unique violation on tb_notificacoes_leituras_id_usuario_key)
-- Problema: A tabela está impedindo que o MESMO usuário apareça mais de uma vez.
-- Solução: Permitir que o usuário apareça várias vezes, mas apenas uma vez por notificação.

-- 1. Remove a restrição errada (que bloqueia o usuário)
ALTER TABLE public.tb_notificacoes_leituras 
DROP CONSTRAINT IF EXISTS tb_notificacoes_leituras_id_usuario_key;

-- 2. Adiciona a restrição correta (Usuário + Notificação deve ser único)
ALTER TABLE public.tb_notificacoes_leituras 
ADD CONSTRAINT tb_notificacoes_leituras_user_notif_unique 
UNIQUE (id_usuario, id_notificacao);
