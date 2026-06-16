// Supabase Edge Function: push-notify
// Versão simplificada para debug

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const supabase = createClient(supabaseUrl, supabaseKey);

const FCM_PROJECT_ID = Deno.env.get("FCM_PROJECT_ID");

// Tenta pegar e parsear o Service Account
let serviceAccount: any = null;
try {
    const saJson = Deno.env.get("FCM_SERVICE_ACCOUNT");
    if (saJson) {
        serviceAccount = JSON.parse(saJson);
        console.log("Service Account loaded for:", serviceAccount.client_email);
    }
} catch (e) {
    console.error("Erro ao parsear FCM_SERVICE_ACCOUNT:", e.message);
}

// Gera Access Token para FCM HTTP v1
async function getAccessToken(): Promise<string> {
    if (!serviceAccount) {
        throw new Error("Service Account não configurado corretamente");
    }

    const now = Math.floor(Date.now() / 1000);

    // Header JWT
    const header = { alg: "RS256", typ: "JWT" };

    // Payload JWT
    const payload = {
        iss: serviceAccount.client_email,
        sub: serviceAccount.client_email,
        aud: "https://oauth2.googleapis.com/token",
        iat: now,
        exp: now + 3600,
        scope: "https://www.googleapis.com/auth/firebase.messaging"
    };

    // Encode Base64URL
    const enc = new TextEncoder();
    const toB64 = (s: string) => btoa(s).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

    const hdrB64 = toB64(JSON.stringify(header));
    const payB64 = toB64(JSON.stringify(payload));
    const unsigned = `${hdrB64}.${payB64}`;

    // Parse private key PEM to binary
    const pemBody = serviceAccount.private_key
        .replace(/-----BEGIN PRIVATE KEY-----/, '')
        .replace(/-----END PRIVATE KEY-----/, '')
        .replace(/\n/g, '');
    const keyBinary = Uint8Array.from(atob(pemBody), c => c.charCodeAt(0));

    // Import key
    const cryptoKey = await crypto.subtle.importKey(
        "pkcs8",
        keyBinary.buffer,
        { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
        false,
        ["sign"]
    );

    // Sign
    const sig = await crypto.subtle.sign("RSASSA-PKCS1-v1_5", cryptoKey, enc.encode(unsigned));
    const sigB64 = toB64(String.fromCharCode(...new Uint8Array(sig)));

    const jwt = `${unsigned}.${sigB64}`;

    // Exchange JWT for Access Token
    const res = await fetch("https://oauth2.googleapis.com/token", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`
    });

    const data = await res.json();
    if (!data.access_token) {
        console.error("Token response:", JSON.stringify(data));
        throw new Error("Failed to get access token");
    }

    return data.access_token;
}

// Envia notificação via FCM
async function sendPush(token: string, title: string, body: string, data: any): Promise<boolean> {
    try {
        const accessToken = await getAccessToken();

        const res = await fetch(
            `https://fcm.googleapis.com/v1/projects/${FCM_PROJECT_ID}/messages:send`,
            {
                method: "POST",
                headers: {
                    "Authorization": `Bearer ${accessToken}`,
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    message: {
                        token,
                        notification: { title, body },
                        data,
                        android: { priority: "high" }
                    }
                })
            }
        );

        if (!res.ok) {
            const err = await res.text();
            console.error("FCM error:", err);
            return false;
        }
        return true;
    } catch (e) {
        console.error("sendPush error:", e.message);
        return false;
    }
}

serve(async (req) => {
    try {
        const payload = await req.json();
        const record = payload.record;

        if (!record) {
            return new Response("No record", { status: 400 });
        }

        console.log("Nova notificação:", record.titulo);

        // Buscar tokens FCM
        let tokens: string[] = [];

        if (record.destinatario_perfil && !record.user_id) {
            // Broadcast por cargo
            const { data: users } = await supabase
                .from('tb_cargo_usuario')
                .select('user_id, cargo:tb_cargo!inner(name)')
                .eq('cargo.name', record.destinatario_perfil);

            if (users?.length) {
                const userIds = users.map(u => u.user_id);
                const { data: tokenData } = await supabase
                    .from('tb_fcm_tokens')
                    .select('token')
                    .in('user_id', userIds);
                tokens = tokenData?.map(t => t.token) || [];
            }
        } else if (record.user_id) {
            const { data } = await supabase
                .from('tb_fcm_tokens')
                .select('token')
                .eq('user_id', record.user_id);
            tokens = data?.map(t => t.token) || [];
        }

        console.log(`Encontrados ${tokens.length} tokens`);

        if (!tokens.length) {
            return new Response(JSON.stringify({ sent: 0 }), {
                headers: { "Content-Type": "application/json" }
            });
        }

        // Enviar push
        const results = await Promise.all(
            tokens.map(t => sendPush(t, record.titulo, record.mensagem, { id: record.id }))
        );

        const sent = results.filter(r => r).length;
        console.log(`Enviados: ${sent}/${tokens.length}`);

        return new Response(JSON.stringify({ sent, total: tokens.length }), {
            headers: { "Content-Type": "application/json" }
        });

    } catch (e) {
        console.error("Erro na Edge Function:", e);
        return new Response(JSON.stringify({ error: e.message }), {
            status: 500,
            headers: { "Content-Type": "application/json" }
        });
    }
});
