import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

serve(async (req) => {
    try {
        const adminEmail = "admin@agenda.com";
        const adminPass = "Admin@123";

        // 1. Limpar usuário existente (se houver)
        const { data: list } = await supabase.auth.admin.listUsers();
        const existing = list?.users.find(u => u.email === adminEmail);

        if (existing) {
            await supabase.auth.admin.deleteUser(existing.id);
            console.log("Usuário antigo removido.");
        }

        // 2. Criar Usuário via API
        // O Gatilho 'on_auth_user_created' no Banco de Dados vai criar o registro em 'public.tb_usuario' automaticamente.
        const { data: newUser, error: createError } = await supabase.auth.admin.createUser({
            email: adminEmail,
            password: adminPass,
            email_confirm: true,
            user_metadata: {
                name: "Administrador",
                avatar_url: "https://ui-avatars.com/api/?name=Admin&background=random"
            }
        });

        if (createError) throw createError;
        const userId = newUser.user.id;

        // 3. Vincular Cargo (Admin)
        // Apenas vinculamos o cargo, pois o usuário em si já existe (criado pelo trigger)
        const { data: roleData } = await supabase.from('tb_cargo').select('id').eq('name', 'Administrador').single();
        if (roleData) {
            // Pequeno delay para garantir que o trigger tenha terminado (embora seja síncrono no Postgres, a replicação pode variar)
            // Mas triggers AFTER INSERT for each row são transacionais com o insert.
            const { error: roleError } = await supabase.from('tb_cargo_usuario').upsert({
                user_id: userId,
                cargo_id: roleData.id
            });
            if (roleError) console.error("Erro ao vincular cargo:", roleError);
        }

        return new Response(JSON.stringify({ success: true, userId, message: "Admin created via API + DB Trigger" }), {
            headers: { "Content-Type": "application/json" }
        });

    } catch (err: any) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500 });
    }
});
