---
name: "revision-pre-lanzamiento"
description: "Revisión en 5 pasos antes de publicar una app o web hecha con IA: pruebas end-to-end, prueba con agente, privacidad, rendimiento y seguridad. Úsala antes de cada lanzamiento."
---

# Revisión Pre lanzamiento

Se complementa con `auditoria-web`, que revisa SEO técnico, metadatos y
detalles visibles del sitio.

Cinco revisiones en orden, cada una con checklist. Adapta cada paso al tipo de
proyecto: una web estática no tiene login ni base de datos; una app con cuentas
(por ejemplo con Supabase o Firebase) necesita todo.

## Reglas

- Lee `CLAUDE.md` y `DESIGN.md` si existen; mandan sobre esta skill.
- **Congela la versión:** trabaja en una rama de lanzamiento y no agregues
  funciones nuevas mientras revisas.
- El despliegue (entornos, HTTPS, versión etiquetada, vuelta atrás, copias de
  seguridad y apps móviles) se revisa en el Cierre, antes de la decisión de
  lanzamiento; no es una sexta revisión.
- Prueba solo contra localhost o staging, nunca contra producción.
- Solo datos y cuentas de prueba, con prefijo `test-` o `qa-`, y bórralos al
  terminar. Nunca claves ni datos de producción.
- Nunca escribas contraseñas, tokens ni claves en el chat, en archivos del repo
  ni en logs.
- **No declares OK lo que no verificaste.** Cada punto queda en uno de tres
  estados: OK, falla o **No verificado**, este último con el motivo (sin
  acceso, sin entorno de staging, requiere a una persona, etc.).
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
- Un flujo cuyo test no se pudo correr queda **No verificado**, con el motivo;
  nunca como OK.

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
- Colombia, si hay cuentas o formularios: Política de Tratamiento de Datos
  publicada y autorización previa, expresa e informada del titular antes de
  recoger sus datos (casilla sin marcar por defecto y enlace a la política),
  con prueba guardada de cada autorización (quién, cuándo y qué versión de la
  política aceptó).

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
- Escalabilidad: identificar tareas pesadas que deberían correr en segundo
  plano (colas o jobs), qué se rompería primero con muchos usuarios a la vez y
  cómo simular esa carga.
- Caché: señalar datos que casi no cambian y se piden siempre, cuánto tiempo
  cachearlos y cómo invalidar la caché; marcar el riesgo de mostrar datos
  viejos. Nunca cachear datos personales ni de usuarios con sesión en cachés
  compartidas (CDN).
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
- Dependencias auditadas (`npm audit`, `pnpm audit`, `pip-audit`) y errores sin detalles
  internos.
- Build de producción: sin source maps (`.map`) publicados, código minificado y
  ninguna clave secreta en variables públicas del cliente (`NEXT_PUBLIC_`,
  `VITE_`, `EXPO_PUBLIC_`). Una clave pública anon/publishable es normal solo si
  RLS está activo en todas las tablas; una service role o secret, nunca.
- Login y sesiones (si hay cuentas): expiración de sesión, cierre de sesión que
  invalide el token, cookies con `HttpOnly`, `Secure` y `SameSite`, y protección
  contra inyección (consultas parametrizadas) y XSS.
- Límite de peticiones por ruta: identificar los endpoints caros o sensibles
  (IA, correo, login, pagos), proponer un límite por usuario o IP aplicado en el
  servidor y definir qué mensaje recibe quien se pasa y por cuánto tiempo se
  bloquea.
- Topes de gasto: límites de facturación configurados en los paneles de los
  servicios que cobran por uso (IA, base de datos, correo, SMS).
- Monitoreo: si hay backend o servicios que cobran por uso, confirmar captura de
  errores en producción (por ejemplo Sentry), logs accesibles y alertas de
  caída, lentitud y gasto inusual, sin ruido. Sin correos, tokens ni datos
  personales en errores y logs, y el servicio declarado en la política de
  privacidad. Si no existe, queda como falla. En una web estática basta con un
  aviso de caída (uptime).
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
| 3. Privacidad | Datos inventariados y política publicada; en Colombia, con cuentas o formularios, Política de Tratamiento de Datos publicada y autorización previa, expresa e informada con prueba guardada |
| 4. Rendimiento | Core Web Vitals en verde (y carga superada si hay backend) |
| 5. Seguridad | Cero hallazgos críticos o altos y prueba de dos cuentas superada |

Además deben existir el monitoreo con alertas (o el aviso de caída en webs
estáticas), el plan de vuelta atrás y, si hay base de datos, las copias de
seguridad probadas.

Un punto **No verificado** no cuenta como cumplido.

## Cierre

1. Borra primero los datos y cuentas de prueba (`test-`, `qa-`) que se crearon.
2. Despliegue, cada punto con estado OK / falla / No verificado / No aplica
   (con motivo):
   - Antes de lanzar: entornos de pruebas y producción separados, variables de
     entorno de producción configuradas, HTTPS activo, una etiqueta (tag) de la
     versión estable y el procedimiento para volver atrás (incluidas
     migraciones de base de datos reversibles).
   - Copias de seguridad (si hay base de datos): respaldo automático de la base
     de datos y una restauración probada al menos una vez.
   - Apps móviles (si aplica): formulario de Seguridad de los datos en Google
     Play, eliminación de cuenta dentro de la app y desde una web, respaldo
     seguro de la llave de firma (keystore) fuera del repo y plan para revertir
     actualizaciones OTA (Expo).

   "No aplica" sí cuenta como cumplido, siempre que el motivo sea real (por
   ejemplo, una web estática sin base de datos).
3. Tabla final: revisión, resultado (OK / falla / No verificado, con motivo) y
   pendiente.
4. Una decisión de lanzamiento: qué impide lanzar hoy, qué puede esperar a la
   siguiente versión y qué vigilar la primera semana.
5. Después de publicar: una comprobación rápida de los flujos críticos en
   producción, sin crear datos reales.
