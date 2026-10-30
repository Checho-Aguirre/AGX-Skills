# AGX Skills · revisión web para Claude Code

[![Licencia: MIT](https://img.shields.io/badge/licencia-MIT-blue.svg)](LICENSE)
[![Versión](https://img.shields.io/badge/versión-2.1.0-green.svg)](#cambios)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skills-d97757.svg)](https://code.claude.com/docs/en/skills)

Dos skills que revisan tu web o app hecha con IA antes de publicarla, para que
no se note improvisada y no salga con fallos graves.

| Skill | Comando | Qué revisa |
|---|---|---|
| [**Auditoría Web**](skills/auditoria-web/SKILL.md) | `/auditoria-web` | 20 señales que delatan un sitio hecho con IA sin revisión: dominio, HTML vacío, 404, títulos, Open Graph, JSON-LD, h1, canonical, robots, sitemap, favicon, alt, consola y peso |
| [**Revisión Pre lanzamiento**](skills/revision-pre-lanzamiento/SKILL.md) | `/revision-pre-lanzamiento` | 5 revisiones previas al lanzamiento: pruebas de principio a fin, prueba con agente, privacidad, rendimiento (con escalabilidad y caché) y seguridad (con sesiones, límites de peticiones, topes de gasto y monitoreo). Cierra con el despliegue: vuelta atrás, copias de seguridad probadas y apps móviles |

Se complementan: la primera cuida lo que ven buscadores, redes y visitantes; la
segunda, que la app funcione, proteja los datos y cumpla la ley. Las dos
**primero auditan y reportan**; solo corrigen lo que tú apruebes.

> **English summary:** Two Claude Code skills (in Spanish) to review a website
> or app built with AI before launch. **Auditoría Web** (`/auditoria-web`)
> checks 20 signs of an unreviewed AI-built site (technical SEO, metadata, 404,
> favicon, console errors, page weight). **Revisión Pre lanzamiento**
> (`/revision-pre-lanzamiento`) runs a 5-step pre-launch review: end-to-end
> tests, agent-driven testing, privacy, performance and security (sessions,
> rate limits, spending caps, monitoring), then checks deployment (rollback,
> tested backups, mobile apps), and never marks as OK what it couldn't verify. Install with
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
`/agx-skills:auditoria-web` y `/agx-skills:revision-pre-lanzamiento`.

### 3. Manual

Descarga el repositorio y copia las dos carpetas de `skills/` en tu carpeta de
skills personales:

- **macOS / Linux:** `~/.claude/skills/`
- **Windows:** `C:\Users\<tu-usuario>\.claude\skills\`

Debe quedar así, sin carpetas de más en medio:

```
.claude/skills/auditoria-web/SKILL.md
.claude/skills/revision-pre-lanzamiento/SKILL.md
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
/auditoria-web
```

```
/revision-pre-lanzamiento
```

Claude también las activa solo cuando pides algo como *"revisa la web antes de
publicarla"*. Si tu proyecto tiene `CLAUDE.md` o `DESIGN.md`, sus reglas mandan
sobre las de la skill.

### Qué entregan

Una tabla con cada punto revisado, ordenada por impacto. Por ejemplo, la
Auditoría Web:

| Señal | Estado | Evidencia | Corrección propuesta |
|---|---|---|---|
| 2. HTML vacío | Falla | `curl /` devuelve solo `<div id="root">` | Prerender de las rutas públicas |
| 7. Open Graph | Falla | Falta `og:image` en `/servicios` | Imagen 1200×630 con URL absoluta |
| 14. Favicon | OK | `favicon.ico`, `apple-touch-icon` y manifest 512×512 | — |
| 19. Consola | Falla | 2 errores de hidratación en `/contacto` | Mover la fecha al cliente |

Y la Revisión Pre lanzamiento cierra con una decisión. Lo que no pudo
comprobar queda como **No verificado**, nunca como OK:

| Revisión | Resultado | Pendiente |
|---|---|---|
| 1. Pruebas | OK: 6 de 6 flujos críticos pasan | — |
| 3. Privacidad | Falla: falta la autorización de tratamiento de datos en el registro | Casilla sin marcar con enlace a la política y prueba guardada |
| 4. Rendimiento | No verificado: no hay entorno de staging para la prueba de carga | Crear staging y repetir |
| 5. Seguridad | Falla crítica: la cuenta A ve datos de B | Activar RLS en `pedidos`. **No se lanza** hasta corregirlo |
| 5. Seguridad | Falla: sin tope de gasto en la API de IA ni alerta de gasto inusual | Configurar el límite de facturación y la alerta |
| Despliegue | No verificado: la copia de seguridad nunca se restauró | Restaurarla en staging y anotar cuánto tarda |

## Cambios

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

Basadas en ideas de dos guías públicas, reescritas y adaptadas:

- *"20 señales de que tu sitio está vibecodeado"*, de Ben Ramos.
- *"Revisa tu app antes de lanzarla"*, de Ricardo Cabascango (AUPRIA).
- *"De demo a vendible: las 10 capas"*, de tododeia.

## Autor

**Sergio Granados Aguirre** · AGX Tech And Code ·
[github.com/Checho-Aguirre](https://github.com/Checho-Aguirre)

## Aviso

Estas skills son una guía de revisión, no asesoría legal ni de seguridad
profesional. Los textos legales debe revisarlos un abogado y las aplicaciones
con datos sensibles, un especialista en seguridad.

## Licencia

[MIT](LICENSE) © 2026 Sergio Granados Aguirre (AGX Tech And Code)
