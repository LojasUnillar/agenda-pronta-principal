-- Inserir uma notificação de teste
-- Substitua 'SEU_USER_ID_AQUI' pelo ID do usuário real (UUID) que você quer testar.
-- Você pode pegar seu ID na tabela auth.users ou no painel do Supabase.

INSERT INTO public.tb_notificacao (user_id, titulo, mensagem, created_at)
VALUES 
  ('SEU_USER_ID_AQUI', 'Nova Notificação de Teste', 'Sua notificação chegou com sucesso!', NOW());

-- Para verificar se foi inserido:
-- SELECT * FROM public.tb_notificacao WHERE user_id = 'SEU_USER_ID_AQUI';
