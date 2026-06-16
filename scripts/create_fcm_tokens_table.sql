-- CRIAÇÃO TABELA DE TOKENS FCM (Versão sem Auth do Supabase)
-- Tabela para vincular UserID -> FCM Token

CREATE TABLE IF NOT EXISTS public.tb_fcm_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    token TEXT NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    device_info TEXT, -- 'android' | 'ios' | 'web'

    -- Permite que o mesmo usuário tenha tokens em múltiplos dispositivos,
    -- mas não duplica o mesmo token para o mesmo usuário
    UNIQUE(user_id, token)
);


-- Como você não usa o Auth padrão, o RLS (Row Level Security) padrão do Supabase (auth.uid()) não vai funcionar direto.
-- Você pode desabilitar o RLS para essa tabela funcionar livremente (perigoso se for exposto publicamente sem API Gateway),
-- ou criar policies baseadas na sua lógica de JWT customizado.

-- Opção 1: Desabilitar RLS (Mais simples para fazer funcionar agora)
ALTER TABLE public.tb_fcm_tokens DISABLE ROW LEVEL SECURITY;

-- Opção 2: Habilitar RLS mas permitir tudo (Cuidado)
-- ALTER TABLE public.tb_fcm_tokens ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Enable access to all users" ON public.tb_fcm_tokens FOR ALL USING (true) WITH CHECK (true);
