---
name: "agx-revision-legal"
description: "Revisa y corrige los riesgos legales de una web o app hecha con IA: tratamiento de datos personales (Ley 1581), cookies y consentimiento, páginas legales, retracto y garantía (Ley 1480), accesibilidad WCAG 2.2 AA, publicidad engañosa, derechos de autor, normas del sector y, por defecto, las leyes de la UE (RGPD, ePrivacy, Ley Europea de Accesibilidad) y de EE. UU. (COPPA, CCPA/CPRA, ADA, CAN-SPAM, reglas de la FTC), con edad mínima de 16 años en apps con login. Primero audita y reporta; corrige solo lo aprobado. Úsala antes de publicar, al agregar formularios, cuentas, analítica o ventas, y cuando cambien los datos que se recogen."
---

# AGX Revisión Legal

Se complementa con `agx-revision-pre-lanzamiento`, que la llama en su paso de
privacidad; con `agx-auditoria-web`, que revisa lo visible para buscadores; y con
`agx-security-check`, que revisa el código. Esta skill revisa lo que puede
traer una sanción, un reclamo o una demanda: datos personales, consentimiento,
textos legales, accesibilidad, publicidad, derechos de autor y normas del
sector. Primero **audita y reporta**; corrige solo lo que el usuario apruebe.
Si el usuario pide solo el reporte, no cambies nada.

## Reglas

- Lee `CLAUDE.md` y `DESIGN.md` si existen; mandan sobre esta skill.
- **Ley del país del responsable, y además la UE y EE. UU.** Colombia por
  defecto para el responsable (en Ecuador, la LOPDP; en otro país, su ley de
  datos y de consumidor). Como una web o app pública se puede usar desde la
  Unión Europea y desde Estados Unidos, por defecto se revisan también sus
  leyes (paso 12), salvo que el usuario diga expresamente que no.
- **Verifica antes de citar.** Confirma en fuentes oficiales que cada norma y
  artículo siga vigente: SIC, Función Pública y Secretaría del Senado para
  Colombia; EUR-Lex para la UE; la FTC y la oficina del fiscal general de
  California (y la agencia de privacidad del estado) para EE. UU. Lo que no
  pudiste consultar queda **No verificado** y marcado para el abogado. Nunca
  cites un proyecto de ley como vigente, ni un umbral o una cifra sin
  confirmar su valor actual.
- **No inventes datos:** NIT, dirección, teléfono, precios, plazos, términos de
  garantía, proveedores. Lo que falte va como `[PENDIENTE: ...]` y a la lista
  de pendientes. Avisa si un `[PENDIENTE]` quedaría visible en producción.
- **Los textos legales que generes son plantillas**, con versión y fecha de
  última actualización al inicio. El reporte dice siempre que debe revisarlos
  un abogado.
- **No cambies diseño ni textos visibles sin aprobación.** Reseñas,
  testimonios, cifras y afirmaciones dudosas se marcan y se preguntan: no puedes
  saber cuáles son falsas, así que no las borres por tu cuenta.
- Ante la duda, propón la opción que **recoja menos datos y cargue menos
  terceros**.
- Cada punto queda en uno de cuatro estados: **OK**, **falla**, **No
  verificado** (con motivo: sin acceso, sin despliegue, requiere a una persona)
  o **No aplica** (con motivo real, por ejemplo "no vende nada"). **Nunca
  declares OK lo que no comprobaste.**
- Commit y push por cada grupo de correcciones.

## 1. Inventario

Adáptalo al tipo de proyecto: una web estática sin formularios tiene poco que
revisar; una app con cuentas y pagos, todo.

- Rutas públicas y privadas, idiomas, si hay cuentas, si vende o cobra, y el
  sector del negocio.
- Datos personales: qué se recoge, en qué formulario o pantalla, dónde se
  guarda, cuánto tiempo y a qué servicios va (hosting, correo, base de datos,
  pagos, analítica, APIs de IA). Cada servicio que recibe datos es un encargado
  y, si sus servidores están fuera del país, hay transmisión internacional.
- Cookies, `localStorage` y `sessionStorage` **comprobados en el navegador**,
  no supuestos: al cargar sin aceptar nada, después de aceptar y en cada ruta
  con formularios o terceros. Incluye las del hosting (por ejemplo, cookies de
  seguridad que algunos CDN ponen al mostrar un desafío).
- Todas las peticiones a dominios externos (pestaña de red y el build) y los
  scripts de terceros: fuentes, analítica, píxeles, chats, mapas, videos,
  widgets.
- Formularios: cada campo, si es obligatorio y a dónde se envía. Incluye los
  formularios y funciones que existen en el código pero están apagados: se
  revisan igual, para que no se activen sin cumplir.

## 2. Páginas legales

Enlazadas desde el footer de **todas** las páginas (y desde el registro, si hay
cuentas). Cada una con versión y fecha.

- **Política de Tratamiento de Datos** (Ley 1581 de 2012 y Decreto 1377 de
  2013, compilado en el Decreto 1074 de 2015):
  - responsable: nombre, domicilio, correo y teléfono;
  - qué datos, para qué finalidad exacta y por cuánto tiempo;
  - derechos del titular: conocer, actualizar, rectificar, suprimir, revocar la
    autorización, pedir prueba de ella y quejarse ante la SIC;
  - canal y plazos: consultas en 10 días hábiles y reclamos en 15;
  - menores: si el sitio no está dirigido a ellos, decirlo;
  - encargados y transmisiones internacionales (hosting, correo, base de
    datos), con el país de sus servidores;
  - si se envían datos a APIs de IA externas, decirlo y para qué;
  - si el contacto es por WhatsApp u otra red, que esa plataforma trata los
    datos según sus propias políticas;
  - si hay cuentas: cómo exportar y eliminar la cuenta y sus datos, y que la
    app lo permita de verdad.
- **Términos y condiciones:** objeto, uso permitido, propiedad intelectual,
  limitación de responsabilidad sin cláusulas abusivas (Ley 1480), ley
  aplicable y canal de PQR.
- **Política de cookies:** tabla con cada cookie o almacenamiento real del
  paso 1 (nombre, proveedor, finalidad, duración, si es esencial). Ni una que no
  exista. Si solo hay esenciales, decirlo.
- **Retracto, reversión del pago y reembolsos** (Ley 1480 de 2011, arts. 47 y
  51) si vende algo o cobra a distancia: plazo, procedimiento y excepciones (por
  ejemplo, un servicio que ya empezó con acuerdo del cliente). Si las compras
  son dentro de Google Play o App Store, aclarar que las procesa la tienda. Si
  no vende nada, decirlo claro y no inventar precios ni planes.
- **Garantía** (Ley 1480, arts. 7 y siguientes) si vende productos o presta
  servicios: cómo reclamarla y en qué plazo, sin condiciones abusivas ni
  términos por debajo del mínimo legal. Si presta servicios: precio y alcance
  aprobados por el cliente antes de empezar. Si recibe bienes del cliente (por
  ejemplo, reparaciones), las condiciones de recibo y custodia y la
  confidencialidad de lo que contengan.
- Si hay traducciones: un aviso de qué versión prevalece.

## 3. Consentimiento

- **Banner** solo si hay cookies o scripts no esenciales. Si los hay:
  - previo: nada no esencial se carga antes de aceptar (compruébalo en la
    pestaña de red);
  - "Aceptar todo", "Rechazar todo" y "Configurar", con el mismo peso visual;
  - nada preseleccionado;
  - forma de cambiar la decisión después (por ejemplo, "Configurar cookies" en
    el footer);
  - registro de la decisión: fecha, versión de la política y opciones.
- **Formularios:**
  - casilla de autorización sin marcar, obligatoria para enviar, con texto claro
    y enlace a la política (autorización previa, expresa e informada);
  - casilla separada y opcional para publicidad o boletines;
  - prueba guardada de cada autorización: quién, cuándo, qué versión de la
    política y qué texto aceptó. Puede ir en el mismo correo o registro que
    recibe el responsable.

## 4. Minimización

Cada campo del formulario necesita una razón para estar. Para cada uno, di para
qué sirve y propón quitar los que sobran (cédula, dirección o fecha de
nacimiento en un formulario de contacto, por ejemplo). Si no hace falta guardar
nada, un enlace `mailto:` o de WhatsApp puede reemplazar el formulario.

## 5. Terceros embebidos

- Fuentes servidas desde el propio sitio, no desde Google Fonts.
- YouTube con `youtube-nocookie.com` y carga al hacer clic (fachada con imagen
  previa).
- Mapas, redes sociales, chats y widgets: como enlace simple o detrás del
  consentimiento.
- **Analítica:** preferir una sin cookies (Cloudflare Web Analytics,
  Plausible, Umami), que no necesita banner. Si se usa Google Analytics u otra
  con cookies, solo con banner previo y con su modo de consentimiento activado
  (nada se envía antes de aceptar). En los dos casos, declararla en la política
  de privacidad, con lo que recoge según su documentación actual.
- CAPTCHAs de terceros: preferir honeypot y límite de envíos; si se usa uno,
  declararlo.
- Planes gratuitos de hosting, APIs, plantillas o librerías: que sus términos
  vigentes permitan el uso comercial. Si no se pudo confirmar, **No
  verificado**.

## 6. Accesibilidad (WCAG 2.2 AA)

- Contraste de 4.5:1 en texto normal y 3:1 en texto grande y componentes
  (bordes de campos, íconos, foco), en tema claro **y** oscuro.
- Recorrido completo solo con teclado: orden lógico, foco siempre visible, sin
  trampas de foco, Esc cierra menús y modales.
- Enlace "Saltar al contenido" al inicio.
- `label` asociado a cada campo, errores anunciados (`aria-live` o
  `aria-describedby`) y obligatorios indicados sin depender solo del color.
- `prefers-reduced-motion` respetado en las animaciones.
- Objetivos táctiles de al menos 24×24 px.
- `alt` en las imágenes: es la señal 17 de `agx-auditoria-web`; aquí solo se cruza.
- Corre axe si está disponible (`@axe-core/playwright` o la extensión) en cada
  ruta y en los dos temas. Si no, márcalo **No verificado**.

## 7. Textos de botones

Cada botón y enlace dice qué pasa al hacer clic: "Enviar mensaje", "Ver
precios", "Descargar en Google Play". Nada de "Clic aquí" ni "Más" sin
contexto. Proponer el cambio; no aplicarlo sin aprobación.

## 8. Veracidad (publicidad engañosa, Ley 1480)

Marca y pregunta al usuario por cada:
- reseña, testimonio y calificación;
- cifra: clientes, usuarios, descargas, años de experiencia, métricas;
- logo de clientes, premio o certificación;
- superlativo que no se pueda demostrar ("el mejor", "líder", "#1", "100 %
  seguro");
- estado de un producto o app ("Disponible" solo si de verdad lo está);
- "gratis", precios o descuentos, y afirmaciones de inscripciones que no
  existan (factura electrónica, IVA).

Testimonios solo si son reales, con autorización escrita de quien los da, y esa
autorización guardada.

## 9. Datos del negocio

- Visibles en el footer o en contacto: nombre del responsable, ciudad y un
  canal de contacto.
- Nada de "S.A.S.", "Ltda." o similares si la empresa no está constituida.
- Nada de ® si la marca no está registrada ante la SIC (se puede usar ™ o
  nada).
- Nunca la cédula del responsable. Nada de NIT inventado.
- Si vende en línea: la información obligatoria del art. 50 de la Ley 1480
  (identidad con NIT, dirección de notificación, teléfono y correo;
  características del producto; precio total con impuestos y envío; medios de
  pago; tiempo de entrega; retracto; condiciones generales descargables;
  resumen del pedido antes de pagar).

## 10. Derechos de autor

- Inventario de cada imagen, ícono, fuente, ilustración y video en un
  `CREDITOS.md`: archivo, origen (propio, banco de imágenes con licencia,
  generado con IA, sin origen conocido), autor, licencia, enlace y si exige
  atribución. Si la exige, mostrarla en el sitio.
- Lo de origen dudoso o desconocido se le pregunta al usuario. Nada de imágenes
  sacadas de buscadores o webs ajenas.
- Lo generado con IA: la titularidad es incierta; guardar prompts y bocetos, y
  antes de invertir en un logo, buscar antecedentes de la marca ante la SIC.
- Logos de terceros (WhatsApp, Google Play, redes) solo según sus guías de
  marca oficiales.
- Licencias de las dependencias y de las fuentes.
- No puedes comprobar licencias por tu cuenta: dilo en el reporte. Lo que el
  usuario no confirme queda **No verificado**.

## 11. Normas del sector y la actividad

Verifica cada una antes de exigirla. La lista se puede ampliar con otros
sectores (salud, educación, finanzas, alimentos, menores de edad...).

- **Turismo:** Registro Nacional de Turismo (RNT) visible y aviso contra la
  explotación sexual de menores (Ley 679 de 2001 y normas que la modifican).
- **Contacto comercial por WhatsApp, llamadas o SMS:** Ley 2300 de 2023
  (horarios, días y frecuencia de contacto). Si el cliente escribe primero no
  es contacto no solicitado, pero no se le puede enviar publicidad sin
  autorización.
- **Ventas en línea:** Ley 527 de 1999 (mensajes de datos) y art. 50 de la Ley
  1480.
- **Registro Nacional de Bases de Datos (RNBD) de la SIC:** según el tipo y el
  tamaño del responsable. Verifica el umbral vigente; una persona natural o una
  empresa pequeña puede no estar obligada.
- **Apps en tiendas:** formulario de Seguridad de los datos (Google Play) o
  etiquetas de privacidad (App Store), URL de una política que cubra esa app
  (la de la web, si la incluye, o una propia), y eliminación de cuenta dentro
  de la app y desde una web.

## 12. Leyes de la UE y de EE. UU.

Se revisan por defecto (ver Reglas). Verifica cada norma y cada umbral en
EUR-Lex, la FTC o la oficina del fiscal de California antes de exigirlos.

### Unión Europea

- **RGPD:**
  - una base legal para cada tratamiento (consentimiento, contrato, obligación
    legal, interés legítimo...), dicha en la política;
  - los derechos del titular (acceso, rectificación, supresión, oposición,
    limitación, portabilidad, retirar el consentimiento y reclamar ante una
    autoridad de protección de datos) y cómo ejercerlos;
  - transferencias internacionales: a qué países van los datos (hosting,
    correo, base de datos) y con qué garantía (decisión de adecuación,
    cláusulas contractuales tipo u otra);
  - edad de consentimiento digital: 16 años por defecto; cada país puede
    bajarla hasta 13;
  - representante en la UE: si se ofrecen servicios a personas en la UE sin
    tener sede allá, revisa si hace falta designarlo (art. 27) o si aplica la
    excepción para tratamientos ocasionales y de bajo riesgo.
- **Cookies (Directiva ePrivacy):** consentimiento previo para todo lo que no
  sea estrictamente necesario. Es lo mismo del paso 3; aquí se confirma que
  cumple también para la UE.
- **Ley Europea de Accesibilidad:** a qué productos y servicios aplica (por
  ejemplo, comercio electrónico, banca y servicios digitales al consumidor),
  desde cuándo, y la excepción para microempresas que prestan servicios.
  Aunque no aplique, el paso 6 (WCAG 2.2 AA) cubre lo que exige.

### Estados Unidos

- **COPPA:** si el servicio está dirigido a menores de 13 años, o sabe que los
  tiene como usuarios, necesita el consentimiento verificable de los padres
  antes de recoger sus datos.
- **Leyes estatales de privacidad,** empezando por la de California
  (CCPA/CPRA): revisa sus umbrales de aplicación (ingresos anuales, número de
  consumidores cuyos datos se tratan, o ingresos por vender o compartir
  datos). Muchas webs pequeñas quedan por debajo; dilo con el umbral vigente
  como evidencia. Si aplica: aviso al recoger los datos, derechos de saber,
  borrar y corregir, y opción de no vender ni compartir los datos.
- **Accesibilidad (ADA):** hay demandas contra webs que no son accesibles, y
  se usa WCAG como referencia. El paso 6 es la defensa.
- **CAN-SPAM** si se envían correos comerciales: remitente y asunto honestos,
  identificar al negocio con una dirección física y permitir darse de baja de
  forma simple, cumpliéndolo a tiempo.
- **Reglas de la FTC sobre reseñas y testimonios:** nada de reseñas falsas,
  compradas o escritas por el propio negocio, ni testimonios que no reflejen
  una experiencia real. Se cruza con el paso 8.

### Edad mínima de 16 años

- **Webs y apps con login** (cuentas o registro):
  - una declaración de edad al crear la cuenta ("Tengo 16 años o más"), sin
    marcar y obligatoria;
  - no pedir la fecha de nacimiento completa si basta con la declaración
    (minimización, paso 4);
  - en la política: que el servicio no está dirigido a menores de 16 y qué se
    hace si se detecta la cuenta de un menor (cerrarla y borrar sus datos).
- **Webs sin login** (por ejemplo, solo con formulario de contacto): basta con
  decir en la política que no están dirigidas a menores.
- **Si el producto sí está dirigido a menores:** para y márcalo para el
  abogado. Esta skill no cubre ese caso.

## 13. Informe de riesgos

Una tabla, ordenada por gravedad:

| Punto | Estado | Evidencia | Corrección | ¿Abogado? |
|---|---|---|---|---|

- **Punto:** para las leyes del paso 12, nombra la norma y la jurisdicción
  (por ejemplo, "RGPD (UE): base legal" o "CCPA (California): umbrales").
- **Evidencia:** archivo y línea, ruta, captura o lo visto en la pestaña de red.
- **¿Abogado?:** sí en todo texto legal, en las normas que no se pudieron
  verificar y en los casos dudosos.

Después, los **compromisos que prometen los textos** y que el responsable debe
poder cumplir: responder consultas y reclamos a tiempo, devolver el dinero en
el plazo prometido, recordar el retracto antes de empezar un servicio y avisar
a la SIC si hay un incidente de seguridad.

Al final, dos listas: los pendientes que **bloquean el lanzamiento** y los que
**pueden esperar**. Ofrece guardar el informe en `docs/informe-de-riesgos.md`
del proyecto.

## Mínimo para lanzar

| Área | Mínimo |
|---|---|
| Datos personales | Inventario completo y Política de Tratamiento de Datos publicada y enlazada en todas las páginas |
| Consentimiento | Nada no esencial antes de aceptar; casilla de autorización sin marcar y prueba guardada en cada formulario |
| Cookies | La política lista exactamente lo que se comprobó en el navegador |
| Ventas | Si vende: retracto, reversión del pago, garantía e información del art. 50; si no, dicho claramente |
| Veracidad | Ninguna reseña, cifra o afirmación sin confirmar por el usuario |
| Accesibilidad | Sin errores de axe, contraste medido en los dos temas y recorrido con teclado completo |
| Textos legales | Marcados como plantilla, con versión y fecha, y la revisión del abogado en los pendientes |
| UE y EE. UU. | Base legal y transferencias dichas en la política, cookies con consentimiento previo, umbrales de la CCPA/CPRA revisados y, si hay correos comerciales, baja simple e identificación del negocio (o el usuario dijo expresamente que no aplican) |
| Edad mínima | Con login: declaración de 16 años o más al registrarse y qué pasa con cuentas de menores en la política; sin login: aviso en la política. Si el producto es para menores: revisado por el abogado |

Un punto **No verificado** no cuenta como cumplido.

## Cruces con otras skills

- `agx-security-check`: datos personales en logs y errores, CSP de los scripts
  de terceros, y validación y límite de envíos de los formularios.
- `agx-auditoria-web`: `alt` de las imágenes (señal 17) y JSON-LD sin reseñas ni
  calificaciones inventadas (señal 8).

## Aviso

Esta skill es una guía de revisión, no asesoría legal. Los textos que genera
son plantillas que debe revisar un abogado antes de publicarse.
