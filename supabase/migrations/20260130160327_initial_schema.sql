-- Create extension pgcrypto used for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1. Create independent tables
CREATE TABLE public.tb_usuario (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  login text NOT NULL UNIQUE,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  avatar_url text,
  CONSTRAINT tb_usuario_pkey PRIMARY KEY (id)
);

CREATE TABLE public.tb_cargo (
  id uuid NOT NULL,
  name text NOT NULL UNIQUE,
  description text,
  created_at timestamp without time zone DEFAULT now(),
  permissions text[] DEFAULT '{}'::text[],
  CONSTRAINT tb_cargo_pkey PRIMARY KEY (id)
);

CREATE TABLE public.tb_permissoes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  description text,
  CONSTRAINT tb_permissoes_pkey PRIMARY KEY (id)
);

CREATE TABLE public.tb_departamento (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT tb_departamento_pkey PRIMARY KEY (id)
);

CREATE TABLE public.tb_marcas (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT tb_marcas_pkey PRIMARY KEY (id)
);

CREATE TABLE public.tb_produtos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT tb_produtos_pkey PRIMARY KEY (id)
);

CREATE TABLE public.tb_setor_contato (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nome_setor text NOT NULL UNIQUE,
  CONSTRAINT tb_setor_contato_pkey PRIMARY KEY (id)
);

CREATE TABLE public.tb_tipo_contato (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nome text NOT NULL UNIQUE,
  CONSTRAINT tb_tipo_contato_pkey PRIMARY KEY (id)
);

-- 2. Create tables dependent on independent tables

CREATE TABLE public.tb_avaliacoes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  id_usuario uuid,
  avaliacao integer,
  descricao text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT tb_avaliacoes_pkey PRIMARY KEY (id),
  CONSTRAINT tb_avaliacoes_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.tb_usuario(id)
);

CREATE TABLE public.tb_cargo_permissoes (
  cargo_id uuid NOT NULL,
  permissao_id uuid NOT NULL,
  CONSTRAINT tb_cargo_permissoes_pkey PRIMARY KEY (cargo_id, permissao_id),
  CONSTRAINT fk_cargo_permissoes_cargo FOREIGN KEY (cargo_id) REFERENCES public.tb_cargo(id),
  CONSTRAINT fk_cargo_permissoes_permissao FOREIGN KEY (permissao_id) REFERENCES public.tb_permissoes(id)
);

CREATE TABLE public.tb_cargo_usuario (
  user_id uuid NOT NULL UNIQUE,
  cargo_id uuid NOT NULL,
  CONSTRAINT tb_cargo_usuario_pkey PRIMARY KEY (user_id, cargo_id),
  CONSTRAINT tb_cargo_usuario_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.tb_usuario(id),
  CONSTRAINT tb_cargo_usuario_role_id_fkey FOREIGN KEY (cargo_id) REFERENCES public.tb_cargo(id)
);

CREATE TABLE public.tb_contatos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  codigo_erp text UNIQUE,
  nome_fantasia text NOT NULL,
  razao_social text,
  cnpj text UNIQUE,
  tipo_contato text,
  endereco text,
  email text,
  site text,
  site_boleto text,
  is_actived boolean DEFAULT true,
  marca uuid,
  tempo_mercado text,
  tempo_casa text,
  tempo_entrega text,
  tempo_faturamento text,
  tem_assistencia boolean,
  tem_nota boolean,
  tem_boleto boolean,
  info_adicional text,
  avaliacao uuid,
  data_aniversario text,
  casado boolean,
  reg_atuacao text,
  nome_conjugue text,
  personalidade text,
  tem_filhos boolean,
  nome_filhos text,
  created_at timestamp with time zone DEFAULT now(),
  update_at timestamp with time zone DEFAULT now(),
  emite_nota_fiscal boolean DEFAULT true,
  departamentos uuid[],
  representantes uuid[],
  num_assistencia text,
  num_devolucao text,
  num_financeiro text,
  marcas uuid[] DEFAULT '{}'::uuid[],
  produtos uuid[] DEFAULT '{}'::uuid[],
  CONSTRAINT tb_contatos_pkey PRIMARY KEY (id),
  CONSTRAINT tb_contatos_avaliacao_fkey FOREIGN KEY (avaliacao) REFERENCES public.tb_avaliacoes(id)
);

CREATE TABLE public.tb_num_contatos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  id_contato uuid,
  tipo_contato uuid,
  CONSTRAINT tb_num_contatos_pkey PRIMARY KEY (id),
  CONSTRAINT tb_num_contatos_id_contato_fkey FOREIGN KEY (id_contato) REFERENCES public.tb_contatos(id),
  CONSTRAINT tb_num_contatos_tipo_contato_fkey FOREIGN KEY (tipo_contato) REFERENCES public.tb_setor_contato(id)
);

CREATE TABLE public.tb_notificacao (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  titulo text NOT NULL,
  mensagem text NOT NULL,
  destinatario_perfil text NOT NULL DEFAULT 'Todos'::text,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT tb_notificacao_pkey PRIMARY KEY (id),
  CONSTRAINT tb_notificacao_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.tb_usuario(id)
);

CREATE TABLE public.tb_notificacoes_leituras (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  id_notificacao uuid NOT NULL UNIQUE,
  id_usuario uuid NOT NULL,
  is_read boolean DEFAULT false,
  lida_em timestamp with time zone DEFAULT now(),
  CONSTRAINT tb_notificacoes_leituras_pkey PRIMARY KEY (id),
  CONSTRAINT tb_notificacoes_leituras_id_notificacao_fkey FOREIGN KEY (id_notificacao) REFERENCES public.tb_notificacao(id),
  CONSTRAINT tb_notificacoes_leituras_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.tb_usuario(id)
);

-- 3. Create tables dependent on auth.users

CREATE TABLE public.tb_fcm_tokens (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  token text NOT NULL,
  device_info text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT tb_fcm_tokens_pkey PRIMARY KEY (id),
  CONSTRAINT tb_fcm_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
