---
name: "agx-security-check"
description: "Auditoría de seguridad del código completo de una app hecha con IA: 20 fallas comunes (secretos, permisos, IDOR, inyección, XSS, webhooks, subidas), escáneres gratuitos, arreglos uno a uno, blindaje para que no vuelvan, una segunda ronda que intenta explotar de nuevo lo corregido y revisa la lógica de negocio (planes, precios, saldos, doble envío), y la revisión de los paneles de Supabase, Firebase y storage. Úsala para auditar un proyecto entero, no solo un diff, antes de lanzar o después de cambios grandes en permisos, pagos o datos."
---

# AGX Security Check

Se complementa con `agx-revision-pre-lanzamiento`, que revisa la seguridad general
antes de lanzar, y con `agx-auditoria-web`, que revisa lo visible del sitio. Esta
skill baja al código y a los paneles de los servicios: busca las fallas que una
app hecha con IA suele tener y que ni los escáneres ni el comando
`/security-review` (solo revisa el diff de la rama) encuentran. Los cruces con
las demás skills están al final.

## Reglas

- **Antes de cambiar nada, asegura la vuelta atrás:** confirma que el estado
  actual está guardado en un commit (o en una versión o copia, si el proyecto
  no usa git) y que se puede volver a él. Si hay cambios sin guardar, pídele al
  usuario que los confirme o los guarde antes de empezar.
- Lee `CLAUDE.md` y `DESIGN.md` si existen; mandan sobre esta skill.
- **Primero audita y reporta.** No cambies código, configuración ni
  dependencias hasta que el usuario apruebe cada arreglo.
- Solo el proyecto del usuario. Un escaneo de la app en vivo (DAST) se hace
  solo contra una app suya, con su confirmación explícita y preferiblemente en
  localhost o staging; nunca contra dominios o IPs de otros.
- Nunca copies un secreto encontrado en el chat, en reportes ni en logs: indica
  archivo, línea y tipo, con el valor enmascarado (`sk_live_…a1b2`).
- Si una clave estuvo expuesta alguna vez, recomienda rotarla aunque ya se haya
  borrado del código.
- **No declares OK lo que no verificaste.** Cada falla queda en OK, falla,
  **No verificado** (con motivo) o **No aplica** (con motivo real, por ejemplo
  "no hay webhooks").

## Paso 1: Inventario

Stack y framework, dónde corre el backend, cómo se autentica, qué base de datos
usa (y si tiene RLS o reglas de acceso), pagos y webhooks, subida de archivos,
servicios externos con clave (IA, correo, SMS) y qué se despliega al cliente.

## Paso 2: Escáneres automáticos

Corre los que estén instalados, desde la raíz del proyecto. Solo leen el código
en disco; no atacan nada.

| Escáner | Qué busca | Comando |
|---|---|---|
| gitleaks | Secretos en el código | `gitleaks detect --source . --no-git -v` |
| trufflehog | Secretos que siguen activos | `trufflehog filesystem . --only-verified` |
| semgrep | Inyección SQL, XSS y más (OWASP) | `semgrep --config p/owasp-top-ten .` |
| trivy | Dependencias, secretos y misconfig | `trivy fs --scanners vuln,secret,misconfig .` |
| osv-scanner | Dependencias con vulnerabilidades | `osv-scanner scan -r .` |

- trufflehog `--only-verified` prueba cada clave encontrada contra el servicio
  que la emitió para saber si sigue viva; avísale al usuario antes de correrlo.
- Si falta alguno, márcalo **No verificado** y da el comando de instalación
  para su sistema (Windows: `winget` o `scoop`; macOS: `brew`; semgrep también
  con `pip`). No instales nada sin aprobación.
- Si hay `package.json`, corre también `npm audit` (o `pnpm audit`).

## Paso 3: Las 20 fallas

Revisa archivo por archivo donde haga falta. Los escáneres pescan lo mecánico;
aquí importa la lógica.

### Secretos y configuración
1. Archivos `.env`, claves o credenciales versionados en git, también en el
   historial.
2. Claves reales en el frontend o en variables públicas del cliente
   (`NEXT_PUBLIC_`, `VITE_`, `EXPO_PUBLIC_`). Una clave anon/publishable solo es
   aceptable con RLS activo en todas las tablas.
3. Secretos o configuración sensible escritos en consola o en logs.
4. Errores detallados o stack traces devueltos al cliente en producción.
5. Dependencias con vulnerabilidades conocidas.

### Autenticación y permisos
6. Autorización validada solo en el frontend y no en el servidor.
7. Rutas de administración sin verificar sesión y rol.
8. IDs adivinables (1, 2, 3) sin comprobar que el recurso sea de quien lo pide
   (IDOR).
9. Registro que no verifica el correo (permite cuentas falsas en masa).
10. Contraseñas en texto plano o con hash débil (MD5, SHA1 sin sal).
11. Contraseñas sin comprobar contra listas de contraseñas filtradas.
12. Tokens de sesión en `localStorage` en vez de cookies `HttpOnly`.
13. Endpoints sin límite de peticiones, sobre todo login, registro y
    recuperación de contraseña.

### Entradas y datos
14. Datos del usuario que llegan al servidor sin validar.
15. SQL armado concatenando datos del usuario (inyección SQL).
16. Contenido del usuario pintado como HTML sin sanitizar
    (`dangerouslySetInnerHTML`, `innerHTML`, `document.write`): XSS.
17. Guardar el cuerpo completo de la petición sin filtrar campos (mass
    assignment: el usuario envía `isAdmin: true` y queda guardado).
18. Subida de archivos sin validar tipo, tamaño ni contenido.

### Integraciones
19. Webhooks procesados sin verificar la firma de quien los envía.
20. CORS con `*` en endpoints con datos privados o autenticados.

## Paso 4: Reporte

Una tabla ordenada por gravedad (crítico, alto, medio, bajo):

| # | Falla | Estado | Gravedad | Archivo:línea | Cómo se explotaría | Arreglo |
|---|---|---|---|---|---|---|

"Cómo se explotaría" va en una frase. Cierra con los arreglos que harías
primero si solo hubiera una hora.

## Paso 5: Arreglos, de uno en uno

Empieza por el más grave y, para cada hallazgo:

1. Muestra el código actual y el corregido.
2. Explica en una frase por qué el nuevo es seguro.
3. No cambies nada que no tenga que ver con la falla ni refactorices de más.
4. Si hace falta una librería o un cambio de configuración, dilo antes.
5. Di qué debe probar el usuario para confirmar que no se rompió nada.

Para después de cada arreglo y espera a que el usuario diga "sigue".

## Paso 6: Blindaje, para que no vuelva

Propón y aplica solo lo que el usuario apruebe:

- **Sección de seguridad en el `CLAUDE.md` del proyecto:** validar entradas en
  el servidor; ningún secreto en el frontend, en variables públicas ni en
  archivos versionados; consultas parametrizadas; nada de HTML sin sanitizar;
  `/admin` siempre con autorización; comparar tokens con
  `crypto.timingSafeEqual`; sesiones en cookies `HttpOnly`; verificar la firma
  de cada webhook; sin stack traces en producción. Recuerda que esto es
  contexto, no un candado.
- **Hook anti-secretos** (el candado): copia `hooks/block-secrets.sh` de esta
  skill a `.claude/hooks/` del proyecto y regístralo como `PreToolUse` con
  matcher `Write|Edit` en `.claude/settings.json`. Bloquea escribir archivos
  `.env` (salvo `.env.example` y `.env.sample`) y contenido que parece una clave
  real. Necesita bash y `jq` (en Windows, Git Bash y `winget install jqlang.jq`).
- **Revisión automática de cada PR:** la GitHub Action oficial
  `anthropics/claude-code-security-review`. Necesita una clave de API de
  Anthropic como secreto del repo y cobra por uso; fija una versión en vez de
  `@main`.

## Paso 7: Segunda ronda

Vuelve a auditar como si fuera la primera vez. **No des por buenos los
arreglos:** intenta explotar de nuevo cada falla corregida (la misma petición,
el mismo id, la misma entrada maliciosa) y confirma que ahora falla. Un arreglo
que no se pudo volver a probar queda **No verificado**.

Después revisa la lógica de negocio, que ningún escáner encuentra. Hazlo en
localhost o staging, con dos cuentas de prueba (`test-a`, `test-b`), modificando
las peticiones con las herramientas de desarrollo del navegador o con `curl`:

- **Plan, créditos, saldo o rol:** ¿puede un usuario cambiarlos enviando datos
  modificados (`plan: "pro"`, `credits: 9999`, `role: "admin"`)? Esos campos
  solo los cambia el servidor, a partir de un pago confirmado o de un
  administrador.
- **Precio, descuento o total:** ¿el servidor recalcula el total desde sus
  propios precios, o confía en el que manda el cliente? ¿Se puede aplicar un
  cupón vencido, uno ajeno o el mismo cupón dos veces? ¿Acepta cantidades
  negativas o con decimales donde no deberían ir?
- **Otra cuenta:** ¿puede la cuenta A cambiar los permisos, los datos o la
  configuración de la cuenta B cambiando un id en la petición? (Es la falla 8
  vista desde las escrituras, no solo las lecturas.)
- **Acciones importantes validadas solo en la interfaz:** botones ocultos o
  deshabilitados, límites de un plan gratuito o pasos de confirmación que solo
  existen en el frontend. Llama directamente al endpoint y mira si el servidor
  lo impide.
- **Repetir, reordenar o manipular peticiones:**
  - doble envío: dos clics o dos peticiones iguales a la vez que cobran,
    descuentan o canjean dos veces;
  - condiciones de carrera: varias peticiones en paralelo que gastan el mismo
    saldo o el mismo cupón (pruébalo lanzando 10 peticiones a la vez);
  - pasos saltados: ir directo al último paso de un proceso (pago, verificación,
    registro) sin pasar por los anteriores;
  - peticiones viejas repetidas: reenviar una petición válida ya usada (un
    enlace de un solo uso, un código de verificación, un webhook).

  El arreglo suele ser una restricción en el servidor o en la base de datos:
  claves de idempotencia, una restricción `unique`, transacciones o
  actualizaciones atómicas (`update ... set saldo = saldo - x where saldo >= x`)
  y validar el estado anterior antes de cada paso.

Cada hallazgo va a la tabla del paso 4, con gravedad y arreglo, y se corrige
con el procedimiento del paso 5.

## Paso 8: Paneles de los servicios

Lo que no está en el código también expone datos. Revisa la configuración de
cada servicio en su panel (o con su CLI o MCP), **en solo lectura**: cualquier
cambio se propone y espera aprobación, igual que en el paso 5.

### Supabase

- **RLS activo en todas las tablas** del esquema `public` (y de cualquier
  esquema expuesto por la API). Una tabla sin RLS se puede leer y modificar con
  la clave anon, que es pública.
- **Advisors → Security Advisor:** corre el reporte y trae cada aviso con su
  nivel (tablas sin RLS, funciones con `search_path` mutable, vistas con
  `security definer`, extensiones en `public`, protección de contraseñas
  filtradas apagada).
- Revisa las políticas que ya existen: RLS activo **sin políticas** bloquea
  todo; una política con `using (true)` deja la tabla abierta; las de `insert`
  y `update` necesitan `with check`, o un usuario puede escribir filas a nombre
  de otro.
- **Escribe las políticas que falten** con la regla "cada usuario solo ve y
  modifica lo suyo" (por ejemplo, `using (auth.uid() = user_id)` y
  `with check (auth.uid() = user_id)`). Di dónde pegarlas: en una migración
  nueva del proyecto (`supabase/migrations/`) si usa el CLI, o en el SQL Editor
  del panel si no.
- **Comprueba que no bloquean funciones legítimas:** repite los flujos
  principales con las dos cuentas de prueba (crear, ver, editar, borrar lo
  propio) y confirma que A sigue sin ver nada de B. Revisa también las Edge
  Functions, triggers y tareas que leen esas tablas.
- **Funciones `security definer`** que se pueden llamar por la API (avisos del
  Security Advisor para `anon` y `authenticated`): confirma con el usuario si
  cada una debe ser pública. Si debe serlo (por ejemplo, recuperar la
  contraseña sin sesión), que fije `search_path = ''`, valide todo por dentro y
  limite los intentos; si no, quitarle el `execute` a ese rol o pasarla a
  `security invoker`.
- **Esquemas privados:** las tablas fuera de los esquemas expuestos por la API
  (por ejemplo, un esquema `private`) no necesitan políticas, pero confirma en
  la configuración de la API que de verdad no están expuestas.
- **Storage de Supabase:** qué buckets son públicos y qué políticas tiene
  `storage.objects`.
- **Qué proyecto revisar:** si hay uno de pruebas y otro de producción,
  revisa los dos en solo lectura; pueden tener políticas distintas. No
  reactives un proyecto pausado sin preguntar.
- **Si está conectado el MCP de Supabase,** usa `get_advisors` (tipo
  `security`), `list_tables` y `list_extensions`. Para ver las políticas
  (`list_tables` no las muestra), usa `execute_sql` solo con consultas `select`
  a los catálogos (`pg_policies`, `information_schema`), nunca a las filas de
  los usuarios. No uses `execute_sql` para modificar ni `apply_migration` sin
  la aprobación del usuario.

### Firebase

- **Reglas de Firestore y Realtime Database:** busca `allow read, write: if
  true` y las reglas del "modo de prueba" (`if request.time < timestamp...`),
  que dejan todo abierto hasta una fecha y después lo bloquean todo. Cada
  documento debe comprobar `request.auth.uid` contra su dueño.
- **Reglas de Storage:** las mismas preguntas para los archivos.
- Prueba las reglas con el simulador de reglas del panel o con el emulador
  local antes de publicarlas.

### Storage, buckets y APIs con clave

- Lista cada bucket o carpeta (Supabase Storage, Firebase Storage, S3, R2,
  Cloudinary...) y di si es público o privado. Lo privado (documentos, fotos de
  usuarios, facturas) va en buckets privados con URLs firmadas que vencen.
- Claves de API que el cliente necesita (por ejemplo, de mapas): restringidas
  por dominio, por app y por API en el panel del proveedor.
- Topes de gasto y alertas en los servicios que cobran por uso: se cruza con
  el paso 5 de `agx-revision-pre-lanzamiento`.

Cada hallazgo de los paneles va también a la tabla del paso 4.

## Cruces con otras skills

- `agx-revision-pre-lanzamiento`: su paso 5 resume esta auditoría y su prueba
  manual de dos cuentas es la misma de los pasos 7 y 8.
- `agx-revision-legal`: datos personales en logs y errores (falla 3), CSP de
  los scripts de terceros y validación y límite de envíos de los formularios
  (fallas 13 y 14).
- `agx-cifrado`: HTTPS, datos cifrados en reposo, llaves y copias de seguridad.
  Las fallas 10 (contraseñas) y 12 (tokens de sesión) se revisan aquí y allá
  solo se cruzan.

## Aviso

Esta skill reduce los riesgos más comunes, pero no hace invulnerable una app
y no reemplaza una auditoría de seguridad profesional. Pídela si la app procesa
pagos, guarda datos de salud o documentos personales, maneja otra información
sensible o empieza a tener muchos usuarios.

## Créditos

Basada en el kit [vibe-check-security](https://github.com/jdj40211/vibe-check-security)
de Juan David Sierra (licencia MIT según su README), reescrito y adaptado.
