---
name: "agx-optimizacion-web"
description: "Hace más rápida una web sin cambiar su diseño, sus textos ni sus funciones: 20 puntos de imágenes, fuentes, código y entrega, cada uno con cuándo aplicarlo y cuándo saltarlo, un commit por cambio y Lighthouse en celular antes y después. Úsala cuando auditoria-web o revision-pre-lanzamiento marquen el peso o los Core Web Vitals en falla, o cuando quieras aplicar las mejoras de rendimiento, no solo medirlas."
---

# AGX Optimización Web

Se complementa con `auditoria-web`, que mide el peso en su señal 20, y con
`revision-pre-lanzamiento`, que mide el rendimiento en su paso 4. Las dos
miden y reportan; esta skill **aplica** los cambios, de uno en uno, y mide el
resultado.

## Reglas

- Lee `CLAUDE.md` y `DESIGN.md` si existen; mandan sobre esta skill.
- **No cambies el diseño visual, los textos, el comportamiento ni las
  funciones.** No quites nada de la experiencia del usuario. Si una mejora
  cambia algo visible, se propone y espera aprobación.
- Si un punto no aplica, explica por qué en una frase y sáltalo. No hagas
  mejoras innecesarias.
- **Un commit por cambio**, para poder revertirlo solo. Comprueba que cada
  cambio funciona (build, pruebas si existen y la página en el navegador) antes
  de seguir con el siguiente.
- Mantén la compatibilidad con el framework, el hosting y las dependencias
  actuales. No cambies de framework ni subas versiones mayores. Una dependencia
  nueva se propone antes.
- **Mide sobre el build de producción** (local o preview), nunca sobre el
  servidor de desarrollo. Lighthouse en modo **celular**, 3 veces, y usa la
  mediana.
- Si un cambio no mejora LCP, CLS ni INP, propón revertirlo: menos código
  también es más velocidad. Si su beneficio no se ve en una prueba de
  laboratorio (caché, CDN), muéstralo con otra evidencia (`curl -I`, bytes
  transferidos).
- Prueba solo contra localhost o un preview, nunca contra producción.

## Paso 1: Inventario

Framework y versión, cómo se renderiza (estático, servidor o SPA), hosting,
comando de build, cómo servir el build en local, rutas principales y qué hay en
cada portada: imagen o video grande, solo texto, mapas, formularios, listas,
contenido que llega de una API.

## Paso 2: Medición inicial

1. Build de producción y servirlo en local (o abrir el preview).
2. Lighthouse en celular, 3 veces por ruta principal, por ejemplo:
   `npx lighthouse <url> --only-categories=performance --output=json --output-path=./lh-antes-1.json`
   (el modo celular es el predeterminado). No lo agregues al `package.json`.
3. Anota la mediana de LCP, CLS, Total Blocking Time y el peso transferido.
4. Si hay navegador, captura de cada ruta en celular y escritorio, para
   comparar al final.

## Paso 3: Los 20 puntos

Decide para cada uno si aplica o se salta, con el motivo. Ordena los que aplican
por impacto esperado en LCP, CLS o INP, y empieza por el de más impacto.

### Imágenes y multimedia

1. **Formatos modernos (AVIF o WebP) con respaldo.**
   Aplicar si: hay JPG o PNG de fotos. Saltar si: ya se sirven en AVIF/WebP, o
   el framework los convierte solo.
2. **Comprimir y redimensionar al tamaño real en que se muestran, siempre con
   `width` y `height`.**
   Aplicar si: hay imágenes más grandes que su tamaño en pantalla o sin
   dimensiones (causan CLS). Saltar si: ya están al tamaño y con dimensiones.
3. **Lazy loading para imágenes y videos bajo el pliegue.**
   Aplicar si: hay imágenes o videos fuera de la primera pantalla sin
   `loading="lazy"`. Saltar si: la página cabe en una pantalla o ya lo tiene.
4. **Prioridad a la imagen principal** (`fetchpriority="high"` o `preload`),
   sin lazy loading.
   Aplicar si: la portada tiene una imagen o video grande. Saltar si: la
   portada es solo texto.
5. **Imágenes según el tamaño de pantalla** (`srcset` y `sizes`, o el
   componente de imagen del framework).
   Aplicar si: hay fotos a todo el ancho. Saltar si: son íconos y logos SVG.
6. **Videos y mapas que cargan al hacer clic, con imagen previa.**
   Aplicar si: hay YouTube, Vimeo o mapas embebidos. Saltar si: es el video de
   fondo de la portada.

### Fuentes y estilos

7. **Solo las fuentes y pesos que se usan, con `font-display: swap`.**
   Aplicar si: se cargan pesos, estilos o subconjuntos que no aparecen en el
   CSS. Saltar si: solo se usan fuentes del sistema.
8. **Quitar el CSS que no se usa.**
   Aplicar si: hay hojas de estilo o librerías CSS enteras para pocos
   componentes. Saltar si: Tailwind ya lo quita al compilar.
9. **Minificar JS y CSS.**
   Aplicar si: el build publica archivos sin minificar. Saltar si: Next.js,
   Astro o Vite ya lo hacen.

### Código y rendimiento

10. **Dividir el código y cargar por separado los componentes pesados** (mapas,
    gráficos, editores).
    Aplicar si: el bundle inicial incluye componentes que no se ven al cargar.
    Saltar si: es una sola página ligera.
11. **Diferir scripts no críticos** (chat, analítica, píxeles) con `defer`,
    `async` o carga después de la interacción.
    Aplicar si: bloquean la carga inicial. Saltar si: el script es necesario
    para mostrar el contenido.
12. **Quitar dependencias que no se usan.**
    Aplicar si: hay paquetes en `package.json` que nadie importa o librerías
    enteras para una función. Saltar si: el proyecto recién empieza y no hay
    nada que sobre.
13. **Evitar re-renders innecesarios** (`memo`, `useMemo`, estado más cerca de
    donde se usa).
    Aplicar si: es React con formularios o filtros que se traban al escribir.
    Saltar si: es HTML estático.
14. **Debounce en buscadores y filtros que consultan al escribir.**
    Aplicar si: cada tecla lanza una petición o un filtrado pesado. Saltar si:
    no hay búsqueda ni filtros.
15. **Paginar listas largas** (blogs, catálogos, portafolios grandes), o cargar
    por partes.
    Aplicar si: una página pinta decenas de elementos pesados de una vez.
    Saltar si: las listas son cortas.
16. **Esqueletos de carga para contenido que llega de una API o base de
    datos.**
    Aplicar si: el contenido aparece de golpe y empuja lo demás (CLS). Saltar
    si: el contenido es estático. Ojo: un esqueleto nuevo cambia lo que se ve,
    así que se propone y espera aprobación.

### Entrega y medición

17. **Páginas estáticas para las que no cambian.**
    Aplicar si: páginas públicas sin datos por usuario se renderizan en cada
    petición o en el navegador. Saltar si: muestran datos personalizados de
    cada usuario.
18. **Caché del navegador para archivos que cambian poco** (encabezados largos
    para archivos con hash en el nombre; el HTML, corto o sin caché).
    Aplicar si: `curl -I` muestra caché corta o nula en JS, CSS, fuentes e
    imágenes. Saltar si: el hosting ya lo configura bien; compruébalo con
    `curl -I`.
19. **CDN.**
    Aplicar si: el sitio se sirve desde un solo servidor sin CDN. Saltar si:
    Vercel, Netlify o Cloudflare ya lo incluyen.
20. **Lighthouse al empezar y al terminar.** Nunca se salta.

## Paso 4: Aplicar, de uno en uno

Para cada punto que aplica:

1. Haz el cambio mínimo, sin tocar nada más.
2. Build, pruebas si existen y revisión de la página: se ve y funciona igual.
3. Lighthouse en celular sobre las rutas afectadas.
4. Si mejora, commit con un mensaje que diga qué cambió y cuánto mejoró. Si no
   mejora LCP, CLS ni INP, propón revertirlo.

## Paso 5: Medición final

Repite el paso 2 con el mismo método: 3 corridas por ruta, mediana, en celular,
sobre el build de producción. Toma las capturas de las mismas rutas y
compáralas con las de antes.

## Métricas (celular)

| Métrica | Meta |
|---|---|
| LCP | ≤ 2,5 s |
| CLS | ≤ 0,1 |
| INP | ≤ 200 ms |

Lighthouse es una prueba de laboratorio y no mide INP. Usa Total Blocking Time
como referencia (≤ 200 ms) y dilo en el informe. El INP real sale de los datos
de campo (Search Console o PageSpeed Insights, cuando el sitio tenga tráfico).

## Informe final

- Puntos que ya estaban resueltos.
- Mejoras hechas, cada una con su commit y los archivos modificados.
- Puntos que no aplicaban y por qué.
- Tabla de Lighthouse antes y después por ruta (puntaje, LCP, CLS, TBT y peso
  transferido), con la mediana de las 3 corridas.
- Comparación de LCP, CLS e INP (o TBT) con las metas.
- Confirmación de que el diseño, los textos y las funciones siguen igual, con
  capturas de antes y después si hay navegador. Lo que no se pudo comprobar
  queda **No verificado**.
- Mejoras propuestas que esperan aprobación porque cambiarían algo visible.
