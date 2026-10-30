---
name: "agx-security-check"
description: "Auditoría de seguridad del código completo de una app hecha con IA: 20 fallas comunes (secretos, permisos, IDOR, inyección, XSS, webhooks, subidas), escáneres gratuitos, arreglos uno a uno y blindaje para que no vuelvan. Úsala para auditar un proyecto entero, no solo un diff."
---

# AGX Security Check

Se complementa con `revision-pre-lanzamiento`, que revisa la seguridad general
antes de lanzar, y con `auditoria-web`, que revisa lo visible del sitio. Esta
skill baja al código: busca las fallas que una app hecha con IA suele tener y
que ni los escáneres ni el comando `/security-review` (solo revisa el diff de la
rama) encuentran.

## Reglas

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

## Créditos

Basada en el kit [vibe-check-security](https://github.com/jdj40211/vibe-check-security)
de Juan David Sierra (licencia MIT según su README), reescrito y adaptado.
