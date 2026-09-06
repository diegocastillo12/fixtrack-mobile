# Sprint Backlog — Sprint 01

## 1. Capacidad del equipo

El equipo del Sprint 1 está conformado por dos integrantes:

- Diego Fernando Castillo Mamani
- Sergio Alberto Colque Ponce

Para la planificación se considera una disponibilidad de 3 horas diarias por integrante durante 10 días hábiles.

### Cálculo de capacidad

Capacidad inicial:

2 integrantes × 10 días × 3 horas = 60 horas

Descuento por eventos Scrum:

60 horas - 8 horas = 52 horas

Reserva del 15 % para imprevistos:

52 × 0.85 = 44.2 horas

**Capacidad efectiva del Sprint 1: 44.2 horas.**

La reserva permite considerar interrupciones, dificultades técnicas y actividades no previstas durante el desarrollo.

## 2. Criterio para el compromiso

Al no disponer todavía de una velocidad histórica consolidada del equipo, se adopta un compromiso conservador para el primer Sprint. Se seleccionarán entre 8 y 13 puntos de historia, evitando comprometer una cantidad de trabajo superior a la capacidad estimada.

## 3. Sprint Goal

**Sprint Goal:** Al finalizar el Sprint 1, FixTrack contará con un primer flujo funcional que permita al usuario acceder a la aplicación e identificar y consultar información básica de los activos desde un dispositivo móvil, estableciendo una base verificable para incorporar posteriormente la gestión completa de incidencias.

### Validación del Sprint Goal

El Sprint Goal fue definido antes de realizar la selección definitiva de las historias del Sprint Backlog. Su formulación se centra en el resultado de valor que se desea obtener y no únicamente en completar una lista específica de funcionalidades.

El objetivo puede mantenerse aun cuando alguna historia individual deba retirarse durante el Sprint, debido a que las historias seleccionadas posteriormente deberán contribuir de manera complementaria al flujo de acceso, identificación y consulta de activos.

### Resultado esperado

Al cierre del Sprint se espera disponer de un incremento funcional y demostrable de FixTrack que permita validar el flujo principal relacionado con la consulta e identificación de activos y que sirva como base para continuar desarrollando las funcionalidades del producto en los siguientes sprints.

## 4. Historias seleccionadas para el Sprint 1

Considerando el Sprint Goal, la capacidad efectiva del equipo y la ausencia de una velocidad histórica consolidada, se seleccionó un conjunto conservador de historias que suma 11 puntos.

| ID | Historia | Puntos | Responsable inicial |
|---|---|---:|---|
| US-01 | Como usuario quiero iniciar sesión para acceder a FixTrack | 5 | Diego Fernando Castillo Mamani |
| US-04 | Como usuario quiero ver la lista de activos para consultarlos | 3 | Sergio Alberto Colque Ponce |
| US-06 | Como usuario quiero ver el detalle de un activo | 3 | Diego Fernando Castillo Mamani |

**Total comprometido: 11 puntos de historia.**

La selección se encuentra dentro del rango conservador de 8 a 13 puntos establecido para el primer Sprint.

## 5. Plan de entrega

### US-01 — Iniciar sesión
**Responsable inicial:** Diego Fernando Castillo Mamani

Tareas:
- Preparar la interfaz de inicio de sesión.
- Implementar validación de campos.
- Integrar el flujo de autenticación con la arquitectura definida.
- Implementar estados de carga y error.
- Ejecutar pruebas del flujo de acceso.

### US-04 — Consultar lista de activos
**Responsable inicial:** Sergio Alberto Colque Ponce

Tareas:
- Preparar la vista de listado de activos.
- Integrar la obtención de datos mediante el repositorio.
- Implementar estado con información.
- Implementar estado vacío.
- Implementar estado sin conexión.
- Implementar estado de error y opción de reintento.
- Ejecutar pruebas de presentación.

### US-06 — Consultar detalle de activo
**Responsable inicial:** Diego Fernando Castillo Mamani

Tareas:
- Preparar la vista de detalle del activo.
- Recuperar la información del activo seleccionado.
- Implementar los diferentes estados de presentación.
- Controlar errores durante la consulta.
- Ejecutar pruebas del flujo de navegación y presentación.

## 6. Riesgos del Sprint

| Riesgo | Impacto | Acción de respuesta |
|---|---|---|
| Problemas durante la integración de las capas de la aplicación | Alto | Integrar progresivamente y ejecutar pruebas después de cada cambio |
| Diferencias entre el comportamiento esperado y los datos disponibles | Medio | Validar tempranamente los contratos y datos utilizados |
| Falta de conectividad durante las pruebas | Medio | Contemplar estados sin conexión y utilizar datos controlados cuando corresponda |
| Retrasos por disponibilidad limitada del equipo | Alto | Mantener el compromiso conservador de 11 puntos y respetar los límites WIP |
| Errores detectados durante la integración | Medio | Priorizar correcciones que afecten directamente al Sprint Goal |

## 7. Acuerdo para la Daily Scrum

El equipo realizará una coordinación diaria breve para revisar el avance del Sprint. Cada integrante comunicará:

1. Qué trabajo relacionado con el Sprint Goal completó.
2. Qué trabajo realizará a continuación.
3. Qué impedimentos o riesgos están afectando su avance.

La coordinación tendrá una duración máxima aproximada de 15 minutos. Cuando exista un problema que requiera una discusión técnica extensa, este será tratado después de la Daily para evitar extender innecesariamente la reunión.

## 8. Criterio de finalización del Sprint

Una historia podrá considerarse terminada cuando cumpla sus criterios de aceptación, las pruebas correspondientes hayan sido ejecutadas, no existan errores críticos conocidos y los cambios hayan pasado por el flujo de revisión definido por el equipo.

El Sprint se evaluará principalmente en función del cumplimiento del Sprint Goal y del incremento funcional obtenido, y no únicamente por la cantidad de historias completadas.