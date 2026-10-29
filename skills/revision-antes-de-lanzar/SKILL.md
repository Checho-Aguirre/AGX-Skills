---
name: revision-antes-de-lanzar
description: "Revisión en 5 pasos antes de publicar una app o web hecha con IA: pruebas end-to-end, prueba con agente, privacidad, rendimiento y seguridad. Úsala antes de cada lanzamiento."
---

# Revisión antes de lanzar

Cinco revisiones en orden, cada una con checklist. Adapta cada paso al tipo de
proyecto: una web estática no tiene login ni base de datos; una app con cuentas
(por ejemplo con Supabase o Firebase) necesita todo.

## Reglas

- Lee `CLAUDE.md` y `DESIGN.md` si existen; mandan sobre esta skill.
- **Congela la versión:** trabaja en una rama de lanzamiento y no agregues
  funciones nuevas mientras revisas.
- Solo datos y cuentas de prueba. Nunca claves ni datos de producción.
- No cambies diseño ni textos. Las correcciones de rendimiento o seguridad que
  cambien algo visible se proponen y esperan aprobación.
- Commit y push después de cada revisión. Si una corrección rompe algo, vuelve
  a correr las pruebas del paso 1.

## 1. Pruebas de principio a fin

- Lista los flujos críticos: los que, si fallan, cuestan usuarios o dinero
  (registro, login, flujo principal, formularios, pagos, cierre de sesión; en
  una web estática: navegación, menús, cambio de idioma y tema, enlaces de
  contacto, legales, 404, redirecciones).
- Un test automatizado por flujo (Playwright o Cypress), con al menos un caso de
  error (campos vacíos, contraseña incorrecta, sesión caducada, pago rechazado,
  doble clic, botón atrás, ruta inexistente).
- En escritorio y celular.
- Que corran solos en cada push y PR (GitHub Actions o similar).
- Si un fallo viene de la app, explicar causa y corrección antes de aplicarla.

## 2. Prueba con agente

Con un navegador controlado por agente (Playwright MCP, Claude en Chrome o el
navegador integrado), sin modificar código, usa la app como tres perfiles:
- alguien que entra por primera vez y no lee instrucciones;
- alguien que la usa a diario y va rápido;
- alguien que intenta romperla: textos larguísimos, emojis, campos vacíos, doble
  clic en enviar, retroceder a mitad de un proceso, solo teclado.

Por cada problema: pantalla, pasos para reproducir, esperado vs. obtenido,
gravedad y captura. Cerrar con los cinco más graves.

## 3. Privacidad y legal

- Inventario de datos personales: qué se recoge, dónde se guarda, cuánto tiempo
  y a qué servicios externos va (IA, correo, pagos, analítica, hosting).
- Clasificar cookies y scripts en esenciales y no esenciales; banner con opción
  real de rechazar solo si hay no esenciales.
- Política de privacidad y términos publicados y enlazados (desde el registro, si
  hay cuentas).
- Avisar si se envían datos a APIs de IA externas.
- Permitir exportar y eliminar la cuenta y sus datos, si hay cuentas.
- Usar la ley del país del responsable (en Colombia, Ley 1581 de 2012; en
  Ecuador, LOPDP); RGPD solo si hay usuarios en la UE. Marcar lo que debe
  validar un abogado. No inventar nada que no esté en el código.

## 4. Rendimiento

- Lighthouse en **celular** con Core Web Vitals en verde: LCP ≤ 2,5 s,
  INP ≤ 200 ms, CLS ≤ 0,1.
- Frontend: tamaño del bundle, imágenes sin optimizar, recursos que bloquean la
  carga, fuentes en pesos sin usar.
- Backend (si hay): consultas N+1, columnas filtradas sin índice, listas sin
  paginar, llamadas externas sin caché ni tiempo de espera.
- Prueba de carga con k6 o Artillery **solo si hay backend propio**, siempre en
  staging, nunca en producción. Reportar p95, tasa de errores y punto de
  degradación. Una web estática servida por CDN no la necesita.
- Ordenar mejoras por impacto y no aplicar sin aprobación.

## 5. Seguridad (no se salta)

- Ninguna clave en el frontend, el repo ni el historial de git: correr gitleaks.
  Si una clave se subió alguna vez, rotarla aunque ya se haya borrado.
- `.env` en `.gitignore`.
- Llamadas a pagos o IA solo desde el backend, nunca desde el navegador.
- Cada endpoint verifica quién es el usuario y que el recurso le pertenece.
- Supabase/Firebase: reglas de acceso (RLS / Security Rules) activas en todas las
  tablas y colecciones.
- Rutas de administrador inaccesibles para usuarios normales.
- Validación de entradas en el servidor, límite de peticiones real y CORS
  restringido al dominio propio.
- Dependencias auditadas (`npm audit`, `pip-audit`) y errores sin detalles
  internos.
- **Prueba manual de dos cuentas** (si hay cuentas): crear A y B, guardar un
  dato privado con B, entrar con A e intentar verlo cambiando el id en la URL o
  repitiendo la petición. Si se ve algo de B, es crítico: no se lanza.
- Clasificar hallazgos en crítico, alto, medio y bajo, con archivo, línea,
  riesgo y corrección.

## Mínimo para lanzar

| Revisión | Mínimo |
|---|---|
| 1. Pruebas | Todos los flujos críticos con test que pasa |
| 2. Agente | Tres perfiles sin errores de gravedad alta |
| 3. Privacidad | Datos inventariados y política publicada |
| 4. Rendimiento | Core Web Vitals en verde (y carga superada si hay backend) |
| 5. Seguridad | Cero hallazgos críticos o altos y prueba de dos cuentas superada |

## Cierre

Tabla final: revisión, resultado, pendiente. Después, una decisión de
lanzamiento: qué impide lanzar hoy, qué puede esperar a la siguiente versión y
qué vigilar la primera semana.
