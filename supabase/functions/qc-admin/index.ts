// Quarry Users & Roles admin function. Only a signed-in Administrator may call it.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};
const json = (b: unknown, s = 200) =>
  new Response(JSON.stringify(b), { status: s, headers: { ...cors, "Content-Type": "application/json" } });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  try {
    const url = Deno.env.get("SUPABASE_URL")!;
    const admin = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
    const token = (req.headers.get("Authorization") || "").replace("Bearer ", "");
    const { data: caller } = await admin.auth.getUser(token);
    if (!caller?.user || caller.user.app_metadata?.qc_role !== "administrator") {
      return json({ error: "Only the Administrator can manage users." }, 403);
    }
    const b = await req.json();
    const { data: roles } = await admin.from("qc_roles").select("role_id").eq("active", true);
    const okRole = (r: string) => (roles || []).some((x) => x.role_id === r);
    const strongPw = (p: string) => typeof p === "string" && p.length >= 8;

    if (b.action === "create") {
      const username = String(b.username || "").trim().toLowerCase();
      if (!/^[a-z0-9._-]{3,30}$/.test(username)) return json({ error: "Username: 3-30 letters, numbers, . _ -" }, 400);
      if (!okRole(b.role)) return json({ error: "Unknown role." }, 400);
      if (!strongPw(b.password)) return json({ error: "Password must be at least 8 characters." }, 400);
      const { data, error } = await admin.auth.admin.createUser({
        email: `${username}@quary.invalid`, password: b.password, email_confirm: true,
        app_metadata: { qc_role: b.role },
      });
      if (error) return json({ error: error.message }, 400);
      const { error: e2 } = await admin.from("qc_users").insert({
        user_id: data.user!.id, username, display_name: b.display_name || username,
        role_id: b.role, created_by: caller.user.email,
      });
      if (e2) { await admin.auth.admin.deleteUser(data.user!.id); return json({ error: e2.message }, 400); }
      return json({ ok: true });
    }
    if (b.action === "update") {
      if (!okRole(b.role)) return json({ error: "Unknown role." }, 400);
      if (b.user_id === caller.user.id && (b.role !== "administrator" || b.active === false)) {
        return json({ error: "You cannot remove your own Administrator access." }, 400);
      }
      const { error } = await admin.auth.admin.updateUserById(b.user_id, {
        app_metadata: { qc_role: b.role }, ban_duration: b.active === false ? "876000h" : "none",
      });
      if (error) return json({ error: error.message }, 400);
      await admin.from("qc_users").update({ role_id: b.role, active: b.active !== false, display_name: b.display_name }).eq("user_id", b.user_id);
      return json({ ok: true });
    }
    if (b.action === "reset") {
      if (!strongPw(b.password)) return json({ error: "Password must be at least 8 characters." }, 400);
      const { error } = await admin.auth.admin.updateUserById(b.user_id, { password: b.password });
      if (error) return json({ error: error.message }, 400);
      return json({ ok: true });
    }
    return json({ error: "Unknown action." }, 400);
  } catch (e) {
    return json({ error: String((e as Error).message || e) }, 500);
  }
});
