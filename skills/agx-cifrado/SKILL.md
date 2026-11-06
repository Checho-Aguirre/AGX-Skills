---
name: "agx-cifrado"
description: "Revisa que los datos de una web o app hecha con IA estén protegidos en tránsito (HTTPS, HSTS, TLS, SSL a la base de datos), en reposo (cifrado del proveedor, campos sensibles, buckets privados), en el dispositivo (cookies seguras, almacenamiento seguro en el celular) y en las copias de seguridad, y que las llaves y secretos estén bien guardados, separados y con respaldo. También revisa el uso correcto de la criptografía: algoritmos, aleatorios seguros y JWT. Primero audita y reporta; corrige solo lo aprobado. Úsala antes de lanzar, cuando la app guarde contraseñas, tokens, documentos o datos de salud, financieros o personales, y antes de cifrar datos existentes o rotar una llave."
---

# AGX Cifrado

Se complementa con `agx-security-check`, que revisa contraseñas, sesiones y
secretos en el código; con `agx-revision-legal`, porque la ley de datos exige
medidas de seguridad para los datos personales; y con
`agx-revision-pre-lanzamiento`, que revisa HTTPS y copias de seguridad en su
cierre. Esta skill revisa que los datos estén protegidos **en tránsito, en
reposo, en el dispositivo y en las copias**, y que las llaves estén bien
manejadas. Primero **audita y reporta**; corrige solo lo que el usuario apruebe.
Si el usuario pide solo el reporte, no cambies nada.

## Reglas

- Lee `CLAUDE.md` y `DESIGN.md` si existen; mandan sobre esta skill.
- **Antes de cambiar nada, asegura la vuelta atrás:** el estado actual guardado
  en un commit (o en una versión o copia) y la forma de volver a él.
- **Nunca inventes criptografía propia:** usa solo las librerías y funciones
  estándar del lenguaje (Web Crypto, `node:crypto`, `libsodium`, `cryptography`
  de Python...) o las del proveedor. Nada de algoritmos caseros, XOR,
  "ofuscación" ni Base64 presentado como cifrado.
- **Nunca muestres llaves ni secretos** en el chat, en reportes ni en logs:
  indica archivo, línea y tipo, con el valor enmascarado (`sk_live_…a1b2`).
- **Antes de cifrar datos que ya existen o de rotar una llave:** copia de
  seguridad verificada, plan de vuelta atrás y aprobación del usuario. Cifrar
  mal o perder una llave puede dejar los datos irrecuperables.
- **Verifica en la documentación actual del proveedor** lo que hace por
  defecto (por ejemplo, si cifra la base de datos o el storage en reposo, qué
  versiones de TLS acepta, si las copias de seguridad van cifradas) en vez de
  suponerlo. Si no pudiste consultarla, márcalo **No verificado**.
- Prueba solo contra localhost, staging o los dominios del propio usuario.
- No cambies diseño ni textos visibles sin aprobación.
- Cada punto queda en uno de cuatro estados: **OK**, **falla**, **No
  verificado** (con motivo: sin acceso al panel, sin despliegue, requiere a una
  persona) o **No aplica** (con motivo real, por ejemplo "no hay app móvil").
  **Nunca declares OK lo que no comprobaste.**
- Commit y push por cada grupo de correcciones.

## Paso 1: Inventario

- **Qué datos sensibles hay:** contraseñas, tokens y llaves de API, documentos
  (cédulas, contratos, facturas), datos de salud, datos financieros (cuentas,
  saldos, tarjetas) y datos personales en general.
- **Dónde vive cada uno:** base de datos (qué tabla y columna), storage
  (qué bucket), logs y errores, copias de seguridad, navegador (`localStorage`,
  `sessionStorage`, cookies, IndexedDB), celular (almacenamiento de la app) y
  servicios externos (correo, pagos, analítica, APIs de IA).
- **Stack:** hosting, base de datos y su proveedor, autenticación (propia o del
  proveedor), apps móviles y dónde están las variables secretas.
- **Extensiones y herramientas de cifrado** que ya existen (por ejemplo,
  `pgcrypto` o Supabase Vault en la base de datos): si están instaladas, mira
  qué se cifra o se guarda con hash con ellas. En Supabase, con el MCP, usa
  `list_extensions` y consultas `select` a los catálogos, nunca a las filas de
  los usuarios.

Adáptalo al proyecto: una web estática sin formularios tiene poco que revisar;
una app con cuentas, documentos o pagos, todo.

## Paso 2: En tránsito

- **HTTPS en todo** el sitio, la API y los subdominios.
- **Redirección de HTTP a HTTPS** con 301 (compruébalo con
  `curl -I http://<dominio>`).
- **HSTS** (`Strict-Transport-Security`) con `max-age` largo. `includeSubDomains`
  y `preload` solo si **todos** los subdominios tienen HTTPS: el preload es
  difícil de deshacer.
- **Sin contenido mixto:** ninguna imagen, script, fuente ni petición por
  `http://` dentro de páginas HTTPS (consola del navegador y build).
- **TLS 1.2 o superior;** TLS 1.0 y 1.1 deshabilitados. Compruébalo con
  `openssl s_client` o un analizador público de TLS, solo sobre dominios del
  usuario.
- **Conexión a la base de datos con SSL** (`sslmode=require` o superior en la
  cadena de conexión, o la opción del proveedor que obliga a usar SSL).
- **Webhooks y APIs** propios y de terceros solo por HTTPS.
- **Apps Android:** sin tráfico en texto plano
  (`android:usesCleartextTraffic="false"` o una `network_security_config` sin
  excepciones para dominios de producción). **iOS:** sin excepciones de App
  Transport Security para producción.

## Paso 3: En reposo

- **Cifrado por defecto del proveedor:** confirma en su documentación actual si
  la base de datos, el storage y las copias van cifrados en reposo, y anótalo
  con el enlace como evidencia.
- **Campos especialmente sensibles** (documentos de identidad, datos de salud,
  números de cuenta, tokens de terceros guardados): evalúa el cifrado a nivel de
  aplicación o de base de datos, por ejemplo `pgcrypto`, o Supabase Vault para
  secretos. Explica lo que cuesta antes de proponerlo: no se puede buscar,
  filtrar ni ordenar por ese campo, y hay que gestionar la llave (paso 6).
- **Archivos privados** (documentos, fotos de usuarios, facturas) en buckets
  privados, servidos con URLs firmadas que vencen pronto. Nunca en un bucket
  público con un nombre "difícil de adivinar".
- **Logs y errores** sin datos sensibles en claro (se cruza con la falla 3 de
  `agx-security-check`).

## Paso 4: Contraseñas y códigos

- **Contraseñas:** se guardan con **hash** (argon2id o bcrypt), nunca cifradas
  ni en texto plano. Es la falla 10 de `agx-security-check`: aquí solo se
  cruza. Si la autenticación la hace el proveedor (Supabase Auth, Firebase
  Auth, Clerk, Auth0), queda **No aplica** con ese motivo.
- **Otros códigos que la app emite y luego compara:** códigos de recuperación,
  de verificación o de invitación, enlaces de un solo uso y llaves de API que
  la app entrega a sus usuarios. Se guardan con hash (no en claro), se generan
  con aleatorios seguros (paso 8), vencen, sirven una sola vez y tienen límite
  de intentos.

## Paso 5: Tokens en el cliente

- **Web:** tokens de sesión en cookies `HttpOnly`, `Secure` y `SameSite` (se
  cruza con la falla 12 de `agx-security-check`).
- **Celular:** tokens y llaves en almacenamiento seguro (`expo-secure-store`,
  Keychain en iOS o Keystore en Android). Nunca en `AsyncStorage`,
  `SharedPreferences` ni archivos comunes.
- **Nada sensible** en `localStorage`, `sessionStorage` ni en la URL (tokens,
  correos o ids en parámetros quedan en el historial, los logs del servidor y
  el encabezado `Referer`).

## Paso 6: Llaves y secretos

- **Dónde se guardan:** en las variables secretas del hosting o en un gestor de
  secretos, nunca en el repo ni en variables públicas del cliente (se cruza con
  las fallas 1 y 2 de `agx-security-check`).
- **Separadas por entorno:** desarrollo, staging y producción con llaves
  distintas.
- **Rotación:** cómo se cambia cada llave, quién puede hacerlo y qué se rompe
  mientras tanto. Una llave que estuvo expuesta se rota aunque ya se haya
  borrado.
- **Qué pasa si se pierden:** identifica las llaves que cifran datos (por
  ejemplo, la que cifra credenciales guardadas en una herramienta de
  automatización, o la de un campo cifrado). Si se pierden, esos datos no se
  pueden recuperar.
- **Respaldo de la llave separado de los datos que cifra:** en otro lugar, con
  otro acceso. Una copia de los datos junto a su llave no protege nada.

## Paso 7: Copias de seguridad

- **Cifradas** si contienen datos sensibles o llaves (con la opción del
  proveedor o con una herramienta estándar como `age` o `gpg`).
- **La llave de las copias guardada aparte** de las copias.
- **Fuera de carpetas que se sincronizan sin control** (OneDrive, Google Drive,
  Dropbox): una copia sin cifrar ahí termina en la nube de un tercero y en cada
  equipo sincronizado.
- **Restauración probada** al menos una vez, en staging o local, anotando
  cuánto tarda. Una copia que nunca se restauró queda **No verificado**.

## Paso 8: Uso correcto de la criptografía

Busca en el código (y en las dependencias propias) estos patrones:

- **Cifrado simétrico:** AES-GCM o ChaCha20-Poly1305. Nunca AES en modo ECB;
  nunca CBC sin autenticación. Un nonce o IV nuevo y aleatorio por cada mensaje,
  jamás repetido con la misma llave.
- **Hashes:** nada de MD5 ni SHA1 para seguridad (firmas, contraseñas, tokens).
  SHA-256 o superior para integridad; argon2id o bcrypt para contraseñas.
- **Llaves derivadas de una contraseña:** argon2id, scrypt o PBKDF2 con sal y
  parámetros actuales, nunca la contraseña tal cual como llave.
- **Números aleatorios seguros** para tokens, códigos e ids:
  `crypto.getRandomValues`, `crypto.randomUUID` o `crypto.randomBytes`. Nunca
  `Math.random`, la hora o un contador.
- **Comparación de tokens y firmas** en tiempo constante
  (`crypto.timingSafeEqual`).
- **JWT:** firmados con un secreto fuerte (al menos 256 bits aleatorios) o con
  llaves asimétricas; algoritmo fijo al verificar; `none` rechazado; vencimiento
  (`exp`) corto; y siempre verificados, no solo decodificados. El secreto de
  firma nunca en el cliente.

## Paso 9: Informe

Una tabla, ordenada por riesgo:

| Punto | Estado | Evidencia | Riesgo | Corrección |
|---|---|---|---|---|

- **Evidencia:** archivo y línea, salida de `curl -I`, configuración del panel o
  enlace a la documentación del proveedor. Los secretos, siempre enmascarados.
- **Riesgo:** qué podría pasar en una frase (por ejemplo, "si se pierde el
  portátil, la copia sin cifrar expone a todos los clientes").
- **Corrección:** el cambio mínimo, con lo que cuesta y si requiere copia de
  seguridad y aprobación antes de aplicarlo.

Al final, dos listas: lo que **bloquea el lanzamiento** y lo que **puede
esperar**.

## Mínimo para lanzar

| Área | Mínimo |
|---|---|
| En tránsito | HTTPS en todo con redirección desde HTTP, sin contenido mixto, TLS 1.2 o superior y la base de datos conectada con SSL |
| En reposo | Cifrado del proveedor confirmado en su documentación y archivos privados en buckets privados con URLs firmadas |
| Contraseñas y códigos | Contraseñas con hash argon2id o bcrypt (o autenticación del proveedor); códigos de recuperación y de un solo uso con hash, vencimiento y límite de intentos |
| Tokens | Cookies `HttpOnly`, `Secure` y `SameSite` en web; almacenamiento seguro en el celular; nada sensible en `localStorage` ni en la URL |
| Llaves | Fuera del repo y del cliente, separadas por entorno, y las que cifran datos con respaldo guardado aparte |
| Copias | Cifradas si tienen datos sensibles, fuera de carpetas sincronizadas y con una restauración probada |
| Criptografía | Sin ECB, MD5, SHA1 ni `Math.random` para seguridad, y JWT con algoritmo fijo y vencimiento |

Un punto **No verificado** no cuenta como cumplido.

## Cruces con otras skills

- `agx-security-check`: contraseñas (falla 10), tokens de sesión (falla 12),
  secretos en el código y en el cliente (fallas 1 y 2) y datos sensibles en
  logs (falla 3). Allí se revisan; aquí solo se cruzan.
- `agx-revision-legal`: la Ley 1581 exige medidas de seguridad para los datos
  personales, y un incidente de seguridad se le avisa a la SIC. Este informe es
  parte de la evidencia de esas medidas.
- `agx-revision-pre-lanzamiento`: HTTPS y copias de seguridad con restauración
  probada en su cierre.

## Aviso

Esta skill reduce los riesgos más comunes, pero no hace invulnerable una app
y no reemplaza una auditoría de seguridad profesional. Pídela si la app procesa
pagos, guarda datos de salud o documentos personales, maneja otra información
sensible o empieza a tener muchos usuarios.
