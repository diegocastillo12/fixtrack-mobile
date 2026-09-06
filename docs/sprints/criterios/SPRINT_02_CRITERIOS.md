# Criterios de aceptación — Sprint 02

## US-03 — Registrar usuarios

**Historia:** Como administrador quiero registrar usuarios para asignar acceso.

### Escenario 1: Registro correcto
**Dado** que el administrador se encuentra autenticado  
**Y** dispone de permisos para gestionar usuarios  
**Cuando** registra un nombre y correo válidos  
**Entonces** el sistema crea el usuario correctamente.

### Escenario 2: Datos incompletos
**Dado** que el administrador intenta registrar un usuario  
**Cuando** omite un campo obligatorio  
**Entonces** el sistema no completa el registro  
**Y** muestra los campos que deben corregirse.

### Escenario 3: Correo duplicado
**Dado** que existe un usuario con el mismo correo  
**Cuando** el administrador intenta registrarlo nuevamente  
**Entonces** el sistema rechaza la operación  
**Y** informa que el correo ya se encuentra registrado.

**Datos personales:** nombre y correo electrónico.  
**Seguridad:** Sí. Solo un usuario autorizado puede registrar nuevas cuentas.

---

## US-08 — Generar código QR

**Historia:** Como administrador quiero generar códigos QR para los activos.

### Escenario 1: Generación correcta
**Dado** que existe un activo registrado  
**Cuando** el administrador solicita generar su código QR  
**Entonces** el sistema genera un código QR único asociado al activo.

### Escenario 2: Activo inexistente
**Dado** que el activo solicitado no existe  
**Cuando** se intenta generar su código QR  
**Entonces** el sistema informa que la operación no puede realizarse.

**Datos personales:** No.  
**Seguridad:** La generación de códigos QR debe estar disponible únicamente para usuarios autorizados.

---

## US-11 — Actualizar estado de incidencia

**Historia:** Como usuario quiero actualizar el estado de una incidencia.

### Escenario 1: Actualización correcta
**Dado** que existe una incidencia registrada  
**Y** el usuario tiene permisos para modificarla  
**Cuando** selecciona un nuevo estado permitido  
**Entonces** el sistema actualiza el estado correctamente.

### Escenario 2: Estado no permitido
**Dado** que existe una incidencia registrada  
**Cuando** el usuario intenta establecer un estado no permitido  
**Entonces** el sistema rechaza el cambio  
**Y** mantiene el estado anterior.

### Escenario 3: Sin conexión
**Dado** que el dispositivo no dispone de conexión a internet  
**Cuando** el usuario intenta actualizar el estado de la incidencia  
**Entonces** el sistema informa que la operación no pudo completarse por falta de conexión.

### Escenario 4: Error del servidor
**Dado** que el servicio presenta un error  
**Cuando** el usuario intenta actualizar el estado  
**Entonces** el sistema informa que ocurrió un problema  
**Y** permite volver a intentar la operación.

**Datos personales:** No.  
**Seguridad:** La actualización debe estar restringida a usuarios autorizados.

---

## US-12 — Agregar comentarios a una incidencia

**Historia:** Como usuario quiero agregar comentarios a una incidencia.

### Escenario 1: Comentario registrado correctamente
**Dado** que existe una incidencia registrada  
**Y** el usuario se encuentra autenticado  
**Cuando** escribe y envía un comentario válido  
**Entonces** el sistema almacena el comentario  
**Y** lo muestra asociado a la incidencia.

### Escenario 2: Comentario vacío
**Dado** que el usuario intenta agregar un comentario  
**Cuando** no introduce contenido  
**Entonces** el sistema evita el registro  
**Y** solicita ingresar un comentario válido.

### Escenario 3: Sin conexión
**Dado** que el dispositivo no dispone de conexión  
**Cuando** el usuario intenta registrar un comentario  
**Entonces** el sistema informa el problema de conectividad  
**Y** no muestra el comentario como registrado.

### Escenario 4: Error del servidor
**Dado** que ocurre un error en el servicio  
**Cuando** el usuario intenta registrar el comentario  
**Entonces** el sistema informa que la operación no pudo completarse  
**Y** permite volver a intentarla.

**Datos personales:** nombre o identificación del usuario autor del comentario.  
**Seguridad:** El comentario debe quedar asociado al usuario autenticado y solo debe registrarse cuando exista una sesión válida.

---

## US-13 — Adjuntar fotografía a una incidencia

**Historia:** Como usuario quiero adjuntar una fotografía a una incidencia.

### Escenario 1: Fotografía adjuntada correctamente
**Dado** que el usuario se encuentra registrando o consultando una incidencia  
**Y** dispone de los permisos necesarios  
**Cuando** captura o selecciona una fotografía válida  
**Entonces** el sistema permite asociar la fotografía a la incidencia.

### Escenario 2: Archivo no válido
**Dado** que el usuario desea adjuntar una fotografía  
**Cuando** selecciona un archivo con un formato no admitido  
**Entonces** el sistema rechaza el archivo  
**Y** muestra un mensaje informativo.

### Escenario 3: Sin conexión
**Dado** que el dispositivo no dispone de conexión  
**Cuando** el usuario intenta enviar la fotografía  
**Entonces** el sistema informa que no fue posible completar la operación.

### Escenario 4: Error del servidor
**Dado** que el servicio de almacenamiento presenta un error  
**Cuando** el usuario intenta adjuntar la fotografía  
**Entonces** el sistema informa el problema  
**Y** permite volver a intentar la operación.

**Datos personales:** La fotografía podría contener información identificable dependiendo de su contenido.  
**Seguridad:** Se debe restringir el acceso a las fotografías y solicitar únicamente los permisos necesarios del dispositivo.

---

## US-19 — Consultar perfil

**Historia:** Como usuario quiero ver mi perfil para consultar mis datos.

### Escenario 1: Perfil disponible
**Dado** que el usuario se encuentra autenticado  
**Cuando** accede a la sección de perfil  
**Entonces** el sistema muestra su nombre y correo electrónico.

### Escenario 2: Información no disponible
**Dado** que no existe información disponible para mostrar  
**Cuando** el usuario accede a su perfil  
**Entonces** el sistema presenta un estado vacío o informativo.

### Escenario 3: Sin conexión
**Dado** que el dispositivo no dispone de conexión  
**Cuando** el usuario intenta consultar información que requiere acceso remoto  
**Entonces** el sistema informa la falta de conectividad.

### Escenario 4: Error del servidor
**Dado** que el servicio presenta un error  
**Cuando** el usuario solicita la información de su perfil  
**Entonces** el sistema informa que no pudo recuperar los datos  
**Y** permite volver a intentar la consulta.

**Datos personales:** nombre y correo electrónico.  
**Seguridad:** El usuario únicamente debe poder consultar los datos correspondientes a su propia cuenta.

---

## SP-01 — Investigar almacenamiento local para funcionamiento sin conexión

**Tipo:** Spike técnico.

**Objetivo:** Evaluar una alternativa de almacenamiento local que permita soportar funcionalidades de FixTrack cuando el dispositivo no disponga temporalmente de conexión.

### Escenario 1: Evaluación de alternativas
**Dado** que FixTrack requiere contemplar funcionamiento sin conexión  
**Cuando** se investiguen las alternativas de almacenamiento local compatibles con Flutter y con la arquitectura del proyecto  
**Entonces** se documentarán las alternativas consideradas.

### Escenario 2: Selección de alternativa
**Dado** que se han evaluado las alternativas disponibles  
**Cuando** se comparen según compatibilidad, mantenibilidad, seguridad y facilidad de integración  
**Entonces** se seleccionará una alternativa  
**Y** se documentará su justificación técnica.

### Criterio de finalización
El Spike se considerará terminado cuando exista una conclusión documentada que indique la alternativa recomendada, sus principales ventajas, limitaciones y consideraciones para integrarla posteriormente en FixTrack.

**Datos personales:** No se utilizarán datos personales reales durante la investigación.  
**Seguridad:** La alternativa seleccionada deberá permitir aplicar mecanismos de protección cuando en el futuro se almacene información sensible.