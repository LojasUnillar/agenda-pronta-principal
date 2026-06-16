-- CORREÇÃO DA TABELA tb_fcm_tokens
-- Execute este script no SQL Editor do Supabase

-- 1. Renomeia device_type → device_info (alinha com o código Dart)
ALTER TABLE public.tb_fcm_tokens
  RENAME COLUMN device_type TO device_info;

-- 2. Remove a constraint UNIQUE antiga que é apenas no token
ALTER TABLE public.tb_fcm_tokens
  DROP CONSTRAINT IF EXISTS tb_fcm_tokens_token_key;

-- 3. Adiciona a constraint composta UNIQUE(user_id, token) necessária para o upsert
ALTER TABLE public.tb_fcm_tokens
  ADD CONSTRAINT tb_fcm_tokens_user_id_token_key UNIQUE (user_id, token);
