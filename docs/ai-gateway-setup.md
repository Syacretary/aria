# ARIA AI gateway setup

The Android app never receives a provider API key. It calls the authenticated
`aria-chat` Supabase Edge Function. That function reads the active provider and
model from a private database table and resolves the provider key from Supabase
Vault before sending an OpenAI-compatible Chat Completions request.

## 1. Configure the Supabase project

1. Create a Supabase project and enable **Anonymous Sign-Ins** in Authentication.
2. Enable the Vault extension in the database extensions screen.
3. Apply `supabase/migrations/202611130001_aria_ai_gateway.sql` with the Supabase
   CLI or SQL editor.
4. Add the rotated provider key to Vault. Never put it in this repository or
   the Flutter `.env` file:

   ```sql
   select vault.create_secret(
     'PASTE_ROTATED_PROVIDER_KEY_HERE',
     'aria_provider_api_key',
     'ARIA OpenAI-compatible provider key'
   );
   ```

5. Set the active provider configuration. Use the model IDs allowed by that
   provider account; the IDs are case-sensitive.

   ```sql
   insert into aria_private.provider_config (
     singleton, base_url, model, allowed_models, secret_name, max_tokens
   ) values (
     true,
     'https://ai.appverse.id/v1',
     'appverse2/deepseek-v4.1-flash',
     array[
       'appverse2/deepseek-v4.1-flash',
       'appverse2/glm-5.3',
       'appverse2/glm-5.3-flash',
       'appverse3/glm-5.3-flash',
       'appverse3/DeepSeek-V4.1-Flash',
       'appverse3/DeepSeek-V4.1-Flash-1017'
     ],
     'aria_provider_api_key',
     220
   )
   on conflict (singleton) do update set
     base_url = excluded.base_url,
     model = excluded.model,
     allowed_models = excluded.allowed_models,
     secret_name = excluded.secret_name,
     max_tokens = excluded.max_tokens,
     updated_at = now();
   ```

   `base_url` is the provider's `/v1` base. The Edge Function appends
   `/chat/completions`; it also accepts a URL that already ends with that path.

## 2. Deploy the Edge Function

Deploy `supabase/functions/aria-chat/index.ts` as `aria-chat`. The included
`supabase/config.toml` keeps JWT verification enabled. The function also checks
the user session itself and limits each anonymous user to 20 requests per hour.
Do not expose Supabase service-role keys to the app.

## 3. Configure the Flutter build

Copy `.env.example` to `.env`, replace the Supabase project URL and its public
publishable/anon key, then build:

```sh
flutter build apk --release --dart-define-from-file=.env
```

`.env` uses standard `KEY=value` syntax for the Supabase CLI. It is ignored by Git. Build with:

```sh
set -a
source .env
set +a
flutter build apk --release \\
  --dart-define="ARIA_SUPABASE_URL=$ARIA_SUPABASE_URL" \\
  --dart-define="ARIA_SUPABASE_ANON_KEY=$ARIA_SUPABASE_ANON_KEY"
```

The URL and publishable key are included in the app and
are not secrets; Supabase Auth, Edge Function JWT verification, and the private
schema protect access. Provider keys remain in Vault.

## 4. Change provider or rotate its key

- Change `base_url`, `model`, or `allowed_models` in the private provider row.
- Update the named Vault secret when rotating the provider key.
- The app continues calling the same Edge Function; no app release is needed.
- OpenAI-compatible providers use the same adapter. Providers with a different
  request/response format need a server-side adapter in the Edge Function.

The Supabase Free plan can pause projects after a week of low activity, so it
does not guarantee an always-available production gateway. Check the current
plan's availability terms before relying on it for published users.
