import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

export const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

export interface JwtPayload {
    sub: string;
    email?: string;
    app_metadata?: any;
    user_metadata?: any;
    roles?: string[]; // Adicionado post-validação se necessário
}

// Cria um cliente Supabase "scoped" para a requisição atual
// Isso valida o token automaticamente
export function createScopedClient(req: Request) {
    return createClient(
        Deno.env.get("SUPABASE_URL")!,
        Deno.env.get("SUPABASE_ANON_KEY")!,
        {
            global: {
                headers: { Authorization: req.headers.get('Authorization')! },
            },
        }
    );
}

export async function validateToken(authHeader: string | null): Promise<{ payload: any | null; error: string | null; user?: any }> {
    if (!authHeader) {
        return { payload: null, error: "Token de autorização não fornecido" };
    }

    try {
        // Usa o cliente oficial para validar o token
        const supabase = createClient(
            Deno.env.get("SUPABASE_URL")!,
            Deno.env.get("SUPABASE_ANON_KEY")!,
            {
                global: {
                    headers: { Authorization: authHeader },
                },
            }
        );

        const { data: { user }, error } = await supabase.auth.getUser();

        if (error || !user) {
            return { payload: null, error: error?.message || "Token inválido" };
        }

        return { payload: user, error: null, user };
    } catch (e: any) {
        console.error("Erro na validação do JWT:", e.message || e);
        return { payload: null, error: e.message || "Token inválido" };
    }
}

export function errorResponse(message: string, status: number = 400, details?: string): Response {
    return new Response(
        JSON.stringify({ error: message, ...(details && { details }) }),
        { status, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
}

export function successResponse(data: any): Response {
    return new Response(
        JSON.stringify(data),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
}
