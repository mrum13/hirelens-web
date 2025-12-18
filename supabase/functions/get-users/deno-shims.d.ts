// Minimal Deno / URL import shims for the TypeScript language server in VS Code.
// These are only compile-time declarations to quiet editor errors (2307 / 2304).
// They do NOT affect runtime; the real implementations come from Deno when you
// run/deploy the function.

declare module "https://deno.land/std@0.177.0/http/server.ts" {
  // Very small slice of the runtime signature used by this function
  export function serve(
    handler: (req: Request) => Response | Promise<Response>
  ): void;
}

declare module "https://esm.sh/@supabase/supabase-js@2" {
  // Provide a very small, permissive shape for the supabase client used here.
  export function createClient(url: string, key: string, opts?: any): any;
  export default createClient;
}

// Minimal Deno global namespace used in the function (env.get)
declare namespace Deno {
  const env: {
    get(name: string): string | undefined;
  };
}
