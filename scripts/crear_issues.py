import csv
import json
import subprocess
from pathlib import Path

RUTA_BACKLOG = Path("docs/sprints/PRODUCT_BACKLOG.csv")

def ejecutar_gh(argumentos):
    resultado = subprocess.run(
        ["gh", *argumentos],
        capture_output=True,
        text=True,
        encoding="utf-8"
    )

    if resultado.returncode != 0:
        print("ERROR:")
        print(resultado.stderr)
        raise SystemExit(1)

    return resultado.stdout.strip()


print("=== CREACIÓN DE ISSUES DEL PRODUCT BACKLOG — FIXTRACK ===")

# Obtener Issues existentes para evitar duplicados
salida = ejecutar_gh([
    "issue", "list",
    "--state", "all",
    "--limit", "500",
    "--json", "title,number"
])

issues_existentes = json.loads(salida) if salida else []
titulos_existentes = {issue["title"] for issue in issues_existentes}

creados = 0
omitidos = 0

with RUTA_BACKLOG.open("r", encoding="utf-8-sig", newline="") as archivo:
    lector = csv.DictReader(archivo)

    for fila in lector:
        identificador = fila["id"].strip()
        historia = fila["Historia de usuario"].strip()

        titulo = f"[{identificador}] {historia}"

        if titulo in titulos_existentes:
            print(f"OMITIDO: {titulo}")
            omitidos += 1
            continue

        cuerpo = f"""## Historia / elemento del Product Backlog

**ID:** {identificador}

**Épica:** {fila["Épica"]}

**Tipo:** {fila["Tipo"]}

### Descripción

{historia}

### Criterios de aceptación

{fila["Criterios de aceptación"]}

### Planificación

- **Valor:** {fila["Valor (1–5)"]}
- **Riesgo:** {fila["Riesgo (1–5)"]}
- **Puntos:** {fila["Puntos"]}
- **Prioridad:** {fila["Prioridad"]}
- **Sprint previsto:** {fila["Sprint previsto"]}

### Datos personales y seguridad

- **Dato personal:** {fila["¿Trata datos personales?"]}
- **Requisito de seguridad:** {fila["¿Requisitos de seguridad?"]}

---

Elemento generado a partir de `docs/sprints/PRODUCT_BACKLOG.csv`.
"""

        print(f"CREANDO: {titulo}")

        ejecutar_gh([
            "issue", "create",
            "--title", titulo,
            "--body", cuerpo
        ])

        creados += 1
        titulos_existentes.add(titulo)

print()
print("=== RESULTADO ===")
print(f"Issues creados: {creados}")
print(f"Issues omitidos por existir previamente: {omitidos}")
print(f"Total procesado: {creados + omitidos}")