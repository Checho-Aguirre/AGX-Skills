# AGX Skills · revisión web para Claude Code

[![Licencia: MIT](https://img.shields.io/badge/licencia-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skills-d97757.svg)](https://code.claude.com/docs/en/skills)

Dos skills que revisan tu web o app hecha con IA antes de publicarla, para que
no se note improvisada y no salga con fallos graves.

| Skill | Qué revisa |
|---|---|
| [`auditoria-sitio-vibecodeado`](skills/auditoria-sitio-vibecodeado/SKILL.md) | 20 señales que delatan un sitio hecho con IA sin revisión: dominio, HTML vacío, 404, títulos, Open Graph, JSON-LD, h1, canonical, robots, sitemap, favicon, alt, consola y peso |
| [`revision-antes-de-lanzar`](skills/revision-antes-de-lanzar/SKILL.md) | 5 revisiones antes de lanzar: pruebas de principio a fin, prueba con agente, privacidad, rendimiento y seguridad |

Las dos **primero auditan y reportan**; solo corrigen lo que tú apruebes.

> **English summary:** Two Claude Code skills (in Spanish) to review a website
> or app built with AI before launch. `auditoria-sitio-vibecodeado` checks 20
> signs of an unreviewed AI-built site (technical SEO, metadata, 404, favicon,
> console errors, page weight). `revision-antes-de-lanzar` runs a 5-step
> pre-launch review: end-to-end tests, agent-driven testing, privacy,
> performance and security. Install with `npx skills add Checho-Aguirre/agx-skills`,
> as a Claude Code plugin, or by copying the folders into `~/.claude/skills/`.
> MIT licensed.

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
`/agx-skills:auditoria-sitio-vibecodeado` y `/agx-skills:revision-antes-de-lanzar`.

### 3. Manual

Descarga el repositorio y copia las dos carpetas de `skills/` en tu carpeta de
skills personales:

- **macOS / Linux:** `~/.claude/skills/`
- **Windows:** `C:\Users\<tu-usuario>\.claude\skills\`

Debe quedar así, sin carpetas de más en medio:

```
.claude/skills/auditoria-sitio-vibecodeado/SKILL.md
.claude/skills/revision-antes-de-lanzar/SKILL.md
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
/auditoria-sitio-vibecodeado
```

```
/revision-antes-de-lanzar
```

Claude también las activa solo cuando pides algo como *"revisa la web antes de
publicarla"*. Si tu proyecto tiene `CLAUDE.md` o `DESIGN.md`, sus reglas mandan
sobre las de la skill.

### Qué entregan

Una tabla con cada punto revisado, ordenada por impacto. Por ejemplo, la
auditoría:

| Señal | Estado | Evidencia | Corrección propuesta |
|---|---|---|---|
| 2. HTML vacío | Falla | `curl /` devuelve solo `<div id="root">` | Prerender de las rutas públicas |
| 7. Open Graph | Falla | Falta `og:image` en `/servicios` | Imagen 1200×630 con URL absoluta |
| 14. Favicon | OK | `favicon.ico`, `apple-touch-icon` y manifest 512×512 | — |
| 19. Consola | Falla | 2 errores de hidratación en `/contacto` | Mover la fecha al cliente |

Y la revisión antes de lanzar cierra con una decisión:

| Revisión | Resultado | Pendiente |
|---|---|---|
| 1. Pruebas | 6 de 6 flujos críticos pasan | — |
| 3. Privacidad | Falta la política de privacidad | Publicarla y enlazarla desde el registro |
| 5. Seguridad | 1 hallazgo crítico: la cuenta A ve datos de B | Activar RLS en `pedidos`. **No se lanza** hasta corregirlo |

## Créditos

Basadas en ideas de dos guías públicas, reescritas y adaptadas:

- *"20 señales de que tu sitio está vibecodeado"*, de Ben Ramos.
- *"Revisa tu app antes de lanzarla"*, de Ricardo Cabascango (AUPRIA).

## Autor

**Sergio Granados Aguirre** · AGX Tech And Code ·
[github.com/Checho-Aguirre](https://github.com/Checho-Aguirre)

## Aviso

Estas skills son una guía de revisión, no asesoría legal ni de seguridad
profesional. Los textos legales debe revisarlos un abogado y las aplicaciones
con datos sensibles, un especialista en seguridad.

## Licencia

[MIT](LICENSE) © 2026 Sergio Granados Aguirre (AGX Tech And Code)
