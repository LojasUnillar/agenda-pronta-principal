SET search_path = public,
    extensions;
DO $$
DECLARE new_user_id uuid := gen_random_uuid();
admin_role_id uuid := gen_random_uuid();
v_role_exists boolean;
BEGIN -- 1. Create User in auth.users
-- Check if user already exists to avoid duplicates
IF NOT EXISTS (
    SELECT 1
    FROM auth.users
    WHERE email = 'admin@agenda.com'
) THEN
INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        created_at,
        updated_at,
        raw_app_meta_data,
        raw_user_meta_data,
        is_super_admin,
        confirmation_token,
        email_change,
        email_change_token_new,
        recovery_token
    )
VALUES (
        '00000000-0000-0000-0000-000000000000',
        new_user_id,
        'authenticated',
        'authenticated',
        'admin@agenda.com',
        crypt('admin123', gen_salt('bf')),
        now(),
        now(),
        now(),
        '{"provider":"email","providers":["email"]}',
        '{}',
        false,
        '',
        '',
        '',
        ''
    );
-- 2. Create Profile in public.tb_usuario
INSERT INTO public.tb_usuario (
        id,
        nome,
        login,
        is_active
    )
VALUES (
        new_user_id,
        'Administrador',
        'admin',
        true
    );
-- 3. Handle Admin Role
SELECT EXISTS (
        SELECT 1
        FROM public.tb_cargo
        WHERE name = 'Admin'
    ) INTO v_role_exists;
IF v_role_exists THEN
SELECT id INTO admin_role_id
FROM public.tb_cargo
WHERE name = 'Admin';
ELSE
INSERT INTO public.tb_cargo (id, name, description)
VALUES (
        admin_role_id,
        'Admin',
        'Acesso total ao sistema'
    );
END IF;
-- 4. Assign Role to User
INSERT INTO public.tb_cargo_usuario (user_id, cargo_id)
VALUES (new_user_id, admin_role_id);
RAISE NOTICE 'Usuário admin criado com sucesso. Email: admin@agenda.com, Senha: admin123';
ELSE RAISE NOTICE 'Usuário admin@agenda.com já existe.';
END IF;
END $$;