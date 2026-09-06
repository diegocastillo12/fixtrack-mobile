# Estimación mediante Planning Poker — FixTrack

## 1. Participantes

- Diego Fernando Castillo Mamani
- Sergio Alberto Colque Ponce

## 2. Método de estimación

Para estimar las historias previstas para los primeros sprints se aplicó la técnica Planning Poker utilizando la escala Fibonacci. Cada integrante realizó una estimación individual y posteriormente se compararon los resultados para establecer un consenso considerando complejidad, esfuerzo e incertidumbre.

## 3. Resultados de la estimación

| Historia | Diego | Sergio | Consenso | Observación |
|---|---:|---:|---:|---|
| US-01 — Iniciar sesión | 5 | 5 | 5 | Se consideró autenticación y validaciones. |
| US-02 — Cerrar sesión | 2 | 2 | 2 | Flujo de baja complejidad. |
| US-03 — Registrar usuarios | 5 | 5 | 5 | Incluye validaciones y control de acceso. |
| US-04 — Consultar lista de activos | 3 | 3 | 3 | Consulta y representación de diferentes estados. |
| US-05 — Buscar activo | 3 | 3 | 3 | Requiere búsqueda y filtrado. |
| US-06 — Consultar detalle de activo | 3 | 3 | 3 | Consulta individual de información. |
| US-07 — Escanear código QR | 5 | 8 | 5 | Se presentó una discrepancia por la integración con cámara y lectura QR. |
| US-08 — Generar código QR | 5 | 5 | 5 | Requiere generación y asociación del código. |
| US-09 — Registrar incidencia | 5 | 5 | 5 | Incluye validaciones y asociación con activo. |
| US-10 — Consultar incidencias | 3 | 3 | 3 | Consulta con diferentes estados de interfaz. |
| US-11 — Actualizar estado de incidencia | 3 | 5 | 3 | Se discutieron las validaciones de transición de estado. |
| US-12 — Agregar comentarios | 3 | 3 | 3 | Registro y asociación del comentario. |
| US-13 — Adjuntar fotografía | 5 | 5 | 5 | Requiere cámara o selección de archivos. |
| US-19 — Consultar perfil | 2 | 2 | 2 | Consulta de información básica del usuario. |
| SP-01 — Investigar almacenamiento local | 3 | 3 | 3 | Investigación técnica acotada. |

## 4. Discrepancia identificada

Durante la estimación de la historia **US-07 — Escanear código QR**, Diego asignó inicialmente 5 puntos y Sergio 8 puntos. La diferencia surgió por la incertidumbre relacionada con el acceso a la cámara del dispositivo, los permisos requeridos y el procesamiento de códigos QR.

Luego de discutir el alcance se estableció un consenso de **5 puntos**, considerando que el Sprint contempla únicamente la lectura de un código QR válido y la identificación del activo asociado, dejando comportamientos adicionales para futuras historias si fueran necesarios.

## 5. Hallazgo de la discusión

La discrepancia permitió identificar que la integración con capacidades propias del dispositivo puede incrementar la incertidumbre de una historia aun cuando su interfaz sea sencilla. El equipo acordó considerar permisos, dependencias externas y pruebas en dispositivo o emulador antes de establecer la estimación definitiva de historias que involucren hardware móvil.

## 6. Resultado

El Planning Poker permitió revisar las estimaciones de las historias previstas para los primeros sprints y alcanzar valores de consenso. Ninguna de las historias refinadas alcanza los 13 puntos, por lo que no fue necesario dividirlas antes de continuar con la planificación del Sprint 1.