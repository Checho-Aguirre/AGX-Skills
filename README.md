# AGX Skills · revisión web para Claude Code

[![Licencia: MIT](https://img.shields.io/badge/licencia-MIT-blue.svg)](LICENSE)
[![Versión](https://img.shields.io/badge/versión-3.0.0-green.svg)](#cambios)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skills-d97757.svg)](https://code.claude.com/docs/en/skills)

Cinco skills que revisan y mejoran tu web o app hecha con IA antes de
publicarla, para que no se note improvisada, no salga con fallos graves y no te
traiga problemas legales.

| Skill | Comando | Qué revisa |
|---|---|---|
| [**AGX Auditoría Web**](skills/agx-auditoria-web/SKILL.md) | `/agx-auditoria-web` | 20 señales que delatan un sitio hecho con IA sin revisión: dominio, HTML vacío, 404, títulos, Open Graph, JSON-LD, h1, canonical, robots, sitemap, favicon, alt, consola y peso |
| [**AGX Revisión Pre lanzamiento**](skills/agx-revision-pre-lanzamiento/SKILL.md) | `/agx-revision-pre-lanzamiento` | 5 revisiones previas al lanzamiento: pruebas de principio a fin, prueba con agente, privacidad, rendimiento (con escalabilidad y caché) y seguridad (con sesiones, límites de peticiones, topes de gasto y monitoreo). Cierra con el despliegue: vuelta atrás, copias de seguridad probadas y apps móviles |
| [**AGX Security Check**](skills/agx-security-check/SKILL.md) | `/agx-security-check` | Auditoría de seguridad del código completo: 20 fallas comunes (secretos, permisos, IDs adivinables, inyección, XSS, mass assignment, webhooks, subidas), escáneres gratuitos, arreglos de uno en uno y blindaje con `CLAUDE.md`, un hook anti-secretos y revisión automática de cada PR |
| [**AGX Revisión Legal**](skills/agx-revision-legal/SKILL.md) | `/agx-revision-legal` | Riesgos legales en 12 pasos: datos personales (Ley 1581), cookies comprobadas en el navegador, consentimiento con prueba guardada, páginas legales, retracto y garantía (Ley 1480), accesibilidad WCAG 2.2 AA, reseñas y cifras dudosas, datos del negocio, derechos de autor y normas del sector. Cierra con un informe de riesgos para el abogado |
| [**AGX Optimización Web**](skills/agx-optimizacion-web/SKILL.md) | `/agx-optimizacion-web` | Hace más rápida la web sin cambiar diseño, textos ni funciones: 20 puntos de imágenes, fuentes, código y entrega, cada uno con cuándo aplicarlo y cuándo saltarlo, un commit por cambio y Lighthouse en celular antes y después |

Se complementan: AGX Auditoría Web cuida lo que ven buscadores, redes y visitantes;
AGX Revisión Pre lanzamiento, que la app funcione y proteja los datos; AGX Security
Check baja al código para encontrar fallas de seguridad; AGX Revisión Legal
revisa lo que puede traer una sanción o un reclamo; y AGX Optimización Web
aplica las mejoras de rendimiento que las demás solo miden. Todas **primero
auditan y reportan**; solo cambian lo que tú apruebes.

> **English summary:** Five Claude Code skills (in Spanish) to review and
> improve a website or app built with AI before launch. **AGX Auditoría Web** (`/agx-auditoria-web`)
> checks 20 signs of an unreviewed AI-built site (technical SEO, metadata, 404,
> favicon, console errors, page weight). **AGX Revisión Pre lanzamiento**
> (`/agx-revision-pre-lanzamiento`) runs a 5-step pre-launch review: end-to-end
> tests, agent-driven testing, privacy, performance and security (sessions,
> rate limits, spending caps, monitoring), then checks deployment (rollback,
> tested backups, mobile apps), and never marks as OK what it couldn't verify.
> **AGX Security Check** (`/agx-security-check`) audits the whole codebase for
> 20 common security flaws (secrets, authorization, IDOR, injection, XSS,
> webhooks, uploads), runs free scanners, fixes findings one by one and adds
> guardrails so they don't come back. **AGX Revisión Legal**
> (`/agx-revision-legal`) reviews legal risks under Colombian law by default:
> personal data, cookies checked in the browser, consent, legal pages, consumer
> rights, WCAG 2.2 AA accessibility, misleading claims, copyright and
> sector rules, and ends with a risk report for a lawyer. **AGX Optimización
> Web** (`/agx-optimizacion-web`) makes the site faster without changing its
> design, copy or behavior: 20 checks, one commit per change, and mobile
> Lighthouse before and after. Install with
> `npx skills add Checho-Aguirre/agx-skills`, as a Claude Code plugin, or by
> copying the folders into `~/.claude/skills/`. MIT licensed.

## Instalación

Elige una de las tres formas.

### 1. Con el CLI `skills` (la más rápida)

```bash
npx skills add Checho-Aguirre/agx-skills
```

Te pregunta en qué agente instalarlas. Para dejarlas en Claude Code y en todos
tus proyectos:

```bash
npx skills add Checho-Aguirre/agx-skills -a claude-code -g
```

### 2. Como plugin de Claude Code

Dentro de una sesión de Claude Code:

```
/plugin marketplace add Checho-Aguirre/agx-skills
```

```
/plugin install agx-skills@agx-skills
```

O desde la terminal:

```bash
claude plugin marketplace add Checho-Aguirre/agx-skills
```

```bash
claude plugin install agx-skills@agx-skills
```

Instaladas como plugin, las skills llevan el prefijo del plugin:
`/agx-skills:agx-auditoria-web`, `/agx-skills:agx-revision-pre-lanzamiento`,
`/agx-skills:agx-security-check`, `/agx-skills:agx-revision-legal` y
`/agx-skills:agx-optimizacion-web`.

### 3. Manual

Descarga el repositorio y copia las cinco carpetas de `skills/` en tu carpeta de
skills personales:

- **macOS / Linux:** `~/.claude/skills/`
- **Windows:** `C:\Users\<tu-usuario>\.claude\skills\`

Debe quedar así, sin carpetas de más en medio:

```
.claude/skills/agx-auditoria-web/SKILL.md
.claude/skills/agx-revision-pre-lanzamiento/SKILL.md
.claude/skills/agx-security-check/SKILL.md
.claude/skills/agx-revision-legal/SKILL.md
.claude/skills/agx-optimizacion-web/SKILL.md
```

En macOS o Linux puedes hacerlo de una vez:

```bash
git clone https://github.com/Checho-Aguirre/agx-skills && cp -r agx-skills/skills/* ~/.claude/skills/
```

Para un solo proyecto, cópialas en `.claude/skills/` dentro del repo y haz
commit: así también las tienen las sesiones en la nube de ese repo.

Abre una sesión nueva de Claude Code y escribe `/` para verlas.

## Cómo usarlas

En cualquier sesión de Claude Code, dentro de tu proyecto:

```
/agx-auditoria-web
```

```
/agx-revision-pre-lanzamiento
```

```
/agx-security-check
```

```
/agx-revision-legal
```

```
/agx-optimizacion-web
```

Claude también las activa solo cuando pides algo como *"revisa la web antes de
publicarla"*, *"audita la seguridad de este proyecto"*, *"revisa los riesgos
legales"* o *"haz más rápida la web"*. Si tu proyecto tiene `CLAUDE.md` o `DESIGN.md`, sus reglas mandan
sobre las de la skill.

### Qué entregan

Una tabla con cada punto revisado, ordenada por impacto. Por ejemplo, la
AGX Auditoría Web:

| Señal | Estado | Evidencia | Corrección propuesta |
|---|---|---|---|
| 2. HTML vacío | Falla | `curl /` devuelve solo `<div id="root">` | Prerender de las rutas públicas |
| 7. Open Graph | Falla | Falta `og:image` en `/servicios` | Imagen 1200×630 con URL absoluta |
| 14. Favicon | OK | `favicon.ico`, `apple-touch-icon` y manifest 512×512 | — |
| 19. Consola | Falla | 2 errores de hidratación en `/contacto` | Mover la fecha al cliente |

Y la AGX Revisión Pre lanzamiento cierra con una decisión. Lo que no pudo
comprobar queda como **No verificado**, nunca como OK:

| Revisión | Resultado | Pendiente |
|---|---|---|
| 1. Pruebas | OK: 6 de 6 flujos críticos pasan | — |
| 3. Privacidad | Falla: falta la autorización de tratamiento de datos en el registro | Casilla sin marcar con enlace a la política y prueba guardada |
| 4. Rendimiento | No verificado: no hay entorno de staging para la prueba de carga | Crear staging y repetir |
| 5. Seguridad | Falla crítica: la cuenta A ve datos de B | Activar RLS en `pedidos`. **No se lanza** hasta corregirlo |
| 5. Seguridad | Falla: sin tope de gasto en la API de IA ni alerta de gasto inusual | Configurar el límite de facturación y la alerta |
| Despliegue | No verificado: la copia de seguridad nunca se restauró | Restaurarla en staging y anotar cuánto tarda |

Y AGX Security Check ordena las fallas por gravedad, sin mostrar nunca los
secretos que encuentra:

| # | Falla | Estado | Gravedad | Archivo:línea | Cómo se explotaría | Arreglo |
|---|---|---|---|---|---|---|
| 8 | IDs adivinables | Falla | Crítico | `api/pedidos/[id].ts:12` | Cambiando el id en la URL se ven pedidos ajenos | Filtrar por el usuario de la sesión |
| 2 | Clave en el cliente | Falla | Alto | `src/lib/pagos.ts:4` (`sk_live_…a1b2`) | Cualquiera la lee en el bundle y cobra a tu cuenta | Moverla al servidor y rotarla |
| 19 | Webhooks sin firma | No aplica | — | — | — | No hay webhooks |
| 5 | Dependencias | No verificado | — | — | — | Falta osv-scanner; instalarlo y repetir |

AGX Revisión Legal marca qué debe ver un abogado y separa lo que bloquea el
lanzamiento:

| Punto | Estado | Evidencia | Corrección | ¿Abogado? |
|---|---|---|---|---|
| 3. Autorización en el formulario | Falla | La casilla de `/contacto` viene marcada | Dejarla sin marcar y guardar la prueba de cada envío | No |
| 2. Política de cookies | Falla | Lista 4 cookies de analítica; en el navegador no aparece ninguna | Listar solo `tema` en `localStorage` | Sí |
| 8. Veracidad | No verificado | "+500 clientes" en el inicio | Preguntar al dueño de dónde sale la cifra | No |
| 11. RNBD | No verificado | Falta saber los activos del responsable | Confirmar con el contador | Sí |

## Cambios

### 3.0.0

Todas las skills llevan ahora el prefijo `agx-`. Dos cambiaron de nombre:

| Antes | Ahora |
|---|---|
| `auditoria-web` | `agx-auditoria-web` (**AGX Auditoría Web**) |
| `revision-pre-lanzamiento` | `agx-revision-pre-lanzamiento` (**AGX Revisión Pre lanzamiento**) |

Y hay dos skills nuevas:

- **AGX Revisión Legal** (`/agx-revision-legal`): revisión legal en 12 pasos
  con la ley del país del responsable (Colombia por defecto), cookies
  comprobadas en el navegador y un informe de riesgos para el abogado.
- **AGX Optimización Web** (`/agx-optimizacion-web`): 20 mejoras de
  rendimiento que se aplican de una en una, sin cambiar diseño, textos ni
  funciones, con Lighthouse antes y después.

Además, el paso 3 de AGX Revisión Pre lanzamiento ahora resume y llama a la
revisión legal, y su paso 4 y la señal 20 de AGX Auditoría Web miden y remiten
a la optimización para aplicar las mejoras.

**Cómo actualizar:**

- **CLI `skills`:** borra las viejas e instala todas de nuevo (añade `-g` si
  las instalaste globalmente).

  ```bash
  npx skills remove auditoria-web revision-pre-lanzamiento
  ```

  ```bash
  npx skills add Checho-Aguirre/agx-skills
  ```

- **Plugin:** sigue llamándose `agx-skills`; solo actualízalo. Los comandos
  pasan a ser `/agx-skills:agx-auditoria-web` y
  `/agx-skills:agx-revision-pre-lanzamiento`.

  ```
  /plugin marketplace update agx-skills
  ```

- **Manual:** borra las carpetas `auditoria-web` y `revision-pre-lanzamiento`
  de tu carpeta de skills y copia las cinco de `skills/`.

### 2.2.0

Nueva skill **AGX Security Check** (`/agx-security-check`): auditoría de
seguridad del código completo con 20 fallas comunes, escáneres gratuitos,
arreglos de uno en uno y blindaje. Incluye un hook anti-secretos
(`hooks/block-secrets.sh`) para copiar a tus proyectos.

Para tenerla: con el CLI `skills`, vuelve a correr
`npx skills add Checho-Aguirre/agx-skills`; como plugin,
`/plugin marketplace update agx-skills`.

### 2.1.0

La Revisión Pre lanzamiento suma, sin cambiar sus 5 revisiones:

- **Rendimiento:** escalabilidad (tareas en segundo plano, qué se rompe primero
  con mucha carga) y caché (qué cachear, cómo invalidarla, nunca datos
  personales en cachés compartidas).
- **Seguridad:** build de producción sin source maps ni claves secretas en el
  cliente, sesiones y cookies seguras, límites de peticiones por ruta, topes de
  gasto y monitoreo con alertas.
- **Cierre:** despliegue (entornos separados, HTTPS, versión etiquetada, plan
  de vuelta atrás), copias de seguridad con restauración probada, apps móviles
  y una comprobación rápida en producción después de publicar.

Si la instalaste con el CLI `skills`, actualízala con `npx skills update`; como
plugin, con `/plugin marketplace update agx-skills`.

### 2.0.0

Las skills cambiaron de nombre:

| Antes | Ahora |
|---|---|
| `auditoria-sitio-vibecodeado` | `auditoria-web` (**Auditoría Web**) |
| `revision-antes-de-lanzar` | `revision-pre-lanzamiento` (**Revisión Pre lanzamiento**) |

Además, la Revisión Pre lanzamiento ahora prueba solo en localhost o staging,
usa datos de prueba con prefijo `test-` o `qa-` que borra al terminar, marca
como **No verificado** lo que no pudo comprobar y revisa la autorización de
tratamiento de datos que exige la ley colombiana.

**Cómo actualizar:**

- **CLI `skills`:** borra las viejas e instala las nuevas (añade `-g` si las
  instalaste globalmente).

  ```bash
  npx skills remove auditoria-sitio-vibecodeado revision-antes-de-lanzar
  ```

  ```bash
  npx skills add Checho-Aguirre/agx-skills
  ```

- **Plugin:** el plugin sigue llamándose `agx-skills`; solo actualízalo.

  ```
  /plugin marketplace update agx-skills
  ```

- **Manual:** borra las carpetas `auditoria-sitio-vibecodeado` y
  `revision-antes-de-lanzar` de tu carpeta de skills y copia las nuevas.

## Créditos

Basadas en ideas de guías y kits públicos, reescritos y adaptados:

- *"20 señales de que tu sitio está vibecodeado"*, de Ben Ramos.
- *"Revisa tu app antes de lanzarla"*, de Ricardo Cabascango (AUPRIA).
- *"De demo a vendible: las 10 capas"*, de tododeia.
- [*vibe-check-security*](https://github.com/jdj40211/vibe-check-security), de
  Juan David Sierra (MIT).

## Autor

**Sergio Granados Aguirre** · AGX Tech And Code ·
[github.com/Checho-Aguirre](https://github.com/Checho-Aguirre)

## Aviso

Estas skills son una guía de revisión, no asesoría legal ni de seguridad
profesional. Los textos legales debe revisarlos un abogado y las aplicaciones
con datos sensibles, un especialista en seguridad.

## Licencia

[MIT](LICENSE) © 2026 Sergio Granados Aguirre (AGX Tech And Code)
