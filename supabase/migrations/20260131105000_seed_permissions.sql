DO $$
DECLARE v_admin_role_id uuid;
v_perm_id uuid;
t_permission record;
BEGIN -- Get Admin Role ID
SELECT id INTO v_admin_role_id
FROM public.tb_cargo
WHERE name = 'Administrador';
IF v_admin_role_id IS NULL THEN RAISE EXCEPTION 'Role Administrador not found';
END IF;
-- List of permissions to insert
FOR t_permission IN
SELECT *
FROM (
        VALUES ('alterstatususer', 'Ativar/Desativar Usuários'),
            ('alteravatar', 'Alterar Avatar'),
            ('deleteavatar', 'Deletar Avatar'),
            ('altertipouser', 'Alterar Cargo de Usuários'),
            ('accesscaduser', 'Acessar Cadastro de Usuários'),
            ('altercaduser', 'Editar Próprio Perfil'),
            ('accessnotifi', 'Acessar Notificações'),
            ('accessfav', 'Acessar Favoritos'),
            ('accessprofile', 'Botão Rapido Perfil'),
            ('accessconfig', 'Acessar Configurações'),
            ('createcontact', 'Criar Contatos'),
            ('editcontact', 'Editar Contatos'),
            ('deletecontact', 'Excluir Contatos'),
            ('sendnotification', 'Enviar Notificações'),
            ('createuser', 'Criar Novos Usuários'),
            ('edituser', 'Editar Usuários'),
            -- Note: editUser is in AppPermissions but missing in metadata list, added generic description
            ('deleteuser', 'Excluir Usuários')
    ) AS t (code, description) LOOP -- Insert Permission
INSERT INTO public.tb_permissoes (code, description)
VALUES (t_permission.code, t_permission.description) ON CONFLICT (code) DO
UPDATE
SET description = EXCLUDED.description
RETURNING id INTO v_perm_id;
-- Link to Admin Role
INSERT INTO public.tb_cargo_permissoes (cargo_id, permissao_id)
VALUES (v_admin_role_id, v_perm_id) ON CONFLICT (cargo_id, permissao_id) DO NOTHING;
END LOOP;
END $$;