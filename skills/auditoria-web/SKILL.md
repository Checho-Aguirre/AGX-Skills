---
name: "auditoria-web"
description: "Audita una web o landing para que no se note hecha con IA: SEO técnico, metadatos, 404, favicon, accesibilidad básica, consola y peso. Úsala antes de publicar cualquier sitio."
---

# Auditoría Web

Se complementa con `revision-pre-lanzamiento`, que cubre pruebas, privacidad,
rendimiento y seguridad previas al lanzamiento.

Revisa una web pública y detecta los detalles que delatan que se armó con IA sin
revisión: cosas que no rompen el sitio pero lo hacen ver poco profesional e
invisible para buscadores y redes. Primero **audita y reporta**; corrige solo
lo que el usuario apruebe.

## Reglas

- Si el proyecto tiene `CLAUDE.md` o `DESIGN.md`, léelos primero. Sus reglas
  mandan sobre esta skill.
- No cambies diseño ni textos visibles sin aprobación explícita.
- No inventes datos (dirección, reseñas, calificaciones, cifras). Lo que falte
  se marca `[PENDIENTE: ...]`.
- Haz commit y push después de cada grupo de correcciones.
- Revisa en todos los idiomas y temas (claro/oscuro) que tenga el sitio, en
  escritorio y celular.

## Paso 1: Inventario

Lista las rutas públicas, el framework, cómo se renderiza (servidor, estático
o SPA), los idiomas y el dominio configurado.

## Paso 2: Revisar las 20 señales

### A. Visibles desde afuera
1. **Dominio:** el sitio usa un subdominio del hosting (vercel.app, pages.dev,
   netlify.app) en vez de dominio propio. Si ya hay dominio: una sola forma
   canónica (con o sin www) y la otra redirige con 301; ninguna URL vieja del
   hosting queda en el código, canonical u Open Graph. *(Si el usuario dice
   que el dominio ya lo tiene resuelto, omite este punto.)*
2. **HTML vacío:** `curl` a cada ruta debe devolver el texto real del hero. Si
   solo hay un `<div>` vacío, el contenido depende de JavaScript: proponer
   renderizado en servidor o prerender de rutas públicas.
3. **Página 404:** existe, dice en lenguaje humano que la página no existe,
   enlaza al inicio y a lo más buscado, tiene el diseño del sitio y `noindex`.
   Probar con una ruta inventada.
4. **Herramienta equivocada:** sitio de contenido hecho como SPA pura. Lo
   público debe salir en HTML sin JS (Next.js, Astro u otro con SSR/SSG).
5. **Títulos:** uno único por ruta, 50–60 caracteres, de lo específico a la
   marca.
6. **Meta descripciones:** una única por ruta, 140–160 caracteres, como
   promesa concreta con palabras que la gente busca.
7. **Open Graph:** og:title, og:description, og:url, og:image 1200×630 con URL
   absoluta https, y twitter:card `summary_large_image`. Ideal: imagen generada
   por ruta en el build.
8. **Datos estructurados (JSON-LD):** tipo correcto por página (Person,
   Organization, ProfessionalService, Service, SoftwareApplication, Article,
   FAQPage solo si hay preguntas visibles). Solo lo que se ve en la página;
   nunca reseñas ni ratings inventados.

### B. Visibles en el código fuente
9. **Varios h1:** uno solo por ruta, también en móvil (no duplicar el h1 para
   dos layouts).
10. **Sin h1:** el titular principal debe ser un `h1` real; jerarquía sin
    saltos (h2, h3...).
11. **Canonical:** absoluto en cada ruta, coherente con las redirecciones.
12. **llms.txt:** archivo en la raíz en markdown con nombre del sitio, una línea
    de qué hace y enlaces importantes con descripción. Opcional, va al final.
13. **robots.txt:** sin `Disallow: /` heredado; declara el sitemap. Preguntar al
    usuario si quiere permitir crawlers de IA (GPTBot, ClaudeBot,
    PerplexityBot); para quien ofrece servicios, suele convenir permitirlos.
14. **Favicon:** favicon.ico, apple-touch-icon 180×180 y manifest con 512×512;
    legible a 16 px (sin texto ni detalles finos).
15. **sitemap.xml:** generado desde el código, solo páginas públicas
    indexables, declarado en robots.txt.
16. **Idioma:** `lang` correcto en `<html>`; si hay varios idiomas, hreflang
    cruzados con autorreferencia y `x-default`.
17. **Alt:** toda imagen con alt descriptivo (qué muestra y para qué); las
    decorativas con `alt=""` a propósito; nunca "imagen de" ni nombres de
    archivo.

### C. Visibles en la consola y la red
18. **Source maps y secretos:** no publicar archivos `.map` en producción;
    ninguna clave secreta en variables públicas del cliente (`NEXT_PUBLIC_`,
    `VITE_`, etc.). Si una clave estuvo expuesta, recomendar rotarla.
19. **Consola:** cero errores y warnings en todas las rutas. Prioridad:
    hidratación, recursos 404, luego warnings.
20. **Peso:** Lighthouse en modo **celular**. Revisar librerías de animación
    enteras para pocos efectos, paquetes de íconos completos, fuentes en pesos
    sin usar, imágenes sin optimizar o sin width/height, y carga diferida de lo
    que está bajo el pliegue. Metas: LCP ≤ 2,5 s, CLS ≤ 0,1.

## Paso 3: Reporte

Entrega una tabla corta: señal, estado (OK / falla / no aplica), evidencia y
corrección propuesta. Ordena las fallas por impacto. Espera aprobación antes de
corregir, salvo que el usuario haya pedido corregir directamente.

## Paso 4: Correcciones

Aplica por grupos (A, B, C), con commit y push por grupo, y vuelve a verificar
cada señal corregida.

## Después de publicar (recordarle al usuario)

- Registrar el sitio en Google Search Console y enviar el sitemap.
- Probar la vista previa de enlaces en el depurador de Facebook y el Post
  Inspector de LinkedIn.
- Validar el JSON-LD con la prueba de resultados enriquecidos de Google.
