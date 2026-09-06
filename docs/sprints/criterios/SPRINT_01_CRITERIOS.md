# Criterios de aceptación — Sprint 01

## US-01 — Iniciar sesión

**Historia:** Como usuario quiero iniciar sesión para acceder a FixTrack.

### Escenario 1: Inicio de sesión correcto
**Dado** que el usuario se encuentra en la pantalla de inicio de sesión  
**Y** posee credenciales válidas  
**Cuando** ingresa su correo y contraseña  
**Entonces** el sistema valida sus credenciales  
**Y** permite el acceso a FixTrack.

### Escenario 2: Credenciales incorrectas
**Dado** que el usuario se encuentra en la pantalla de inicio de sesión  
**Cuando** ingresa credenciales incorrectas  
**Entonces** el sistema rechaza el acceso  
**Y** muestra un mensaje informativo sin revelar información sensible.

**Datos personales:** correo electrónico.  
**Seguridad:** Sí. Las credenciales deben ser tratadas de forma segura y no deben exponerse en mensajes o registros.

---

## US-02 — Cerrar sesión

**Historia:** Como usuario quiero cerrar sesión para proteger mi cuenta.

### Escenario 1: Cierre de sesión correcto
**Dado** que el usuario mantiene una sesión activa  
**Cuando** selecciona la opción de cerrar sesión  
**Entonces** el sistema finaliza la sesión  
**Y** muestra nuevamente la pantalla de acceso.

### Escenario 2: Acceso posterior al cierre
**Dado** que el usuario cerró su sesión  
**Cuando** intenta acceder nuevamente a una función protegida  
**Entonces** el sistema solicita una nueva autenticación.

**Datos personales:** correo electrónico asociado a la sesión.  
**Seguridad:** Sí. La sesión debe invalidarse correctamente.

---

## US-04 — Consultar lista de activos

**Historia:** Como usuario quiero ver la lista de activos para consultarlos.

### Escenario 1: Consulta con datos
**Dado** que existen activos registrados  
**Cuando** el usuario accede a la lista de activos  
**Entonces** el sistema muestra los activos disponibles.

### Escenario 2: Lista vacía
**Dado** que no existen activos registrados  
**Cuando** el usuario accede a la lista  
**Entonces** el sistema muestra un estado vacío informativo.

### Escenario 3: Sin conexión
**Dado** que el dispositivo no tiene conexión disponible  
**Cuando** el usuario intenta consultar los activos  
**Entonces** el sistema muestra el estado correspondiente a falta de conexión.

### Escenario 4: Error del servidor
**Dado** que el servicio presenta un error  
**Cuando** el usuario intenta consultar los activos  
**Entonces** el sistema informa que no fue posible recuperar la información  
**Y** ofrece la posibilidad de reintentar.

**Datos personales:** No.  
**Seguridad:** No requiere controles adicionales específicos.

---

## US-05 — Buscar activo

**Historia:** Como usuario quiero buscar un activo por nombre o código.

### Escenario 1: Activo encontrado
**Dado** que existen activos registrados  
**Cuando** el usuario introduce un nombre o código válido  
**Entonces** el sistema muestra los activos que coinciden con la búsqueda.

### Escenario 2: Sin resultados
**Dado** que no existe un activo que coincida con el criterio  
**Cuando** se realiza la búsqueda  
**Entonces** el sistema informa que no se encontraron resultados.

### Escenario 3: Sin conexión
**Dado** que la búsqueda requiere información remota y no existe conexión  
**Cuando** el usuario realiza la búsqueda  
**Entonces** el sistema informa el problema de conectividad.

### Escenario 4: Error del servidor
**Dado** que el servicio de activos no se encuentra disponible  
**Cuando** el usuario realiza la búsqueda  
**Entonces** el sistema muestra un mensaje de error y permite reintentar.

**Datos personales:** No.  
**Seguridad:** No requiere controles adicionales específicos.

---

## US-06 — Consultar detalle de activo

**Historia:** Como usuario quiero ver el detalle de un activo.

### Escenario 1: Activo disponible
**Dado** que el usuario selecciona un activo existente  
**Cuando** abre su detalle  
**Entonces** el sistema muestra la información disponible del activo.

### Escenario 2: Información no disponible
**Dado** que el activo solicitado ya no está disponible  
**Cuando** se intenta consultar su detalle  
**Entonces** el sistema informa que no existe información disponible.

### Escenario 3: Sin conexión
**Dado** que no existe conexión y la información no está disponible localmente  
**Cuando** se consulta el detalle  
**Entonces** el sistema informa la falta de conectividad.

### Escenario 4: Error del servidor
**Dado** que ocurre un error al recuperar el activo  
**Cuando** se solicita su detalle  
**Entonces** el sistema muestra el estado de error y permite reintentar.

**Datos personales:** No.  
**Seguridad:** No requiere controles adicionales específicos.

---

## US-07 — Escanear código QR

**Historia:** Como usuario quiero escanear un código QR para identificar un activo.

### Escenario 1: Código QR válido
**Dado** que el usuario dispone de permiso para utilizar la cámara  
**Cuando** escanea un código QR asociado a un activo  
**Entonces** FixTrack identifica el activo  
**Y** permite acceder a su información.

### Escenario 2: Código QR no reconocido
**Dado** que el usuario utiliza el lector QR  
**Cuando** escanea un código que no corresponde a un activo válido  
**Entonces** el sistema informa que el código no fue reconocido.

**Datos personales:** No.  
**Seguridad:** Se debe solicitar únicamente el permiso de cámara necesario.

---

## US-09 — Registrar incidencia

**Historia:** Como usuario quiero registrar una incidencia sobre un activo.

### Escenario 1: Registro correcto
**Dado** que el usuario ha seleccionado un activo  
**Cuando** registra la información obligatoria de una incidencia  
**Entonces** el sistema crea la incidencia  
**Y** la asocia al activo correspondiente.

### Escenario 2: Información obligatoria incompleta
**Dado** que el usuario intenta registrar una incidencia  
**Cuando** omite información obligatoria  
**Entonces** el sistema no completa el registro  
**Y** indica los campos que deben corregirse.

**Datos personales:** nombre o identificación del usuario que realiza el registro.  
**Seguridad:** Sí. Debe existir control de acceso para registrar incidencias.

---

## US-10 — Consultar incidencias de un activo

**Historia:** Como usuario quiero ver las incidencias de un activo.

### Escenario 1: Consulta con datos
**Dado** que el activo tiene incidencias registradas  
**Cuando** el usuario consulta sus incidencias  
**Entonces** el sistema muestra la lista correspondiente.

### Escenario 2: Sin incidencias
**Dado** que el activo no tiene incidencias registradas  
**Cuando** se realiza la consulta  
**Entonces** el sistema muestra un estado vacío informativo.

### Escenario 3: Sin conexión
**Dado** que el dispositivo no dispone de conexión  
**Cuando** el usuario consulta las incidencias  
**Entonces** el sistema muestra el estado correspondiente a falta de conexión.

### Escenario 4: Error del servidor
**Dado** que ocurre un error en el servicio  
**Cuando** se solicitan las incidencias  
**Entonces** el sistema informa el error  
**Y** permite volver a intentar la operación.

**Datos personales:** No en la información básica definida para esta historia.  
**Seguridad:** El acceso se limita a usuarios autorizados.