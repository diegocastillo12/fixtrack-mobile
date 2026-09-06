import csv
from pathlib import Path

RUTA = Path("docs/sprints/PRODUCT_BACKLOG.csv")

elementos = []

with RUTA.open("r", encoding="utf-8-sig", newline="") as archivo:
    lector = csv.DictReader(archivo)

    for fila in lector:
        valor = int(fila["Valor (1–5)"])
        riesgo = int(fila["Riesgo (1–5)"])
        puntos = int(fila["Puntos"])

        indice = (valor * 0.6) + (riesgo * 0.4)

        elementos.append({
            "id": fila["id"],
            "valor": valor,
            "riesgo": riesgo,
            "puntos": puntos,
            "indice": indice,
            "datos_personales": fila["¿Trata datos personales?"]
        })

elementos.sort(key=lambda x: x["indice"], reverse=True)

total_puntos = sum(e["puntos"] for e in elementos)
sin_estimar = sum(1 for e in elementos if e["puntos"] <= 0)
grandes = [e for e in elementos if e["puntos"] >= 13]
datos_personales = sum(
    1 for e in elementos
    if e["datos_personales"].strip().lower() != "no"
)

print("=== PRIORIZACION DEL PRODUCT BACKLOG - FIXTRACK ===")
print(f"Elementos del backlog: {len(elementos)}")
print(f"Total de puntos: {total_puntos}")
print(f"Historias sin estimar: {sin_estimar}")
print(f"Historias >= 13 puntos: {len(grandes)}")
print(f"Elementos que tratan datos personales: {datos_personales}")

print("\n=== ORDEN POR VALOR + RIESGO ===")
print("ID       Valor   Riesgo   Puntos   Indice")

for e in elementos:
    print(
        f"{e['id']:<8} "
        f"{e['valor']:<7} "
        f"{e['riesgo']:<8} "
        f"{e['puntos']:<8} "
        f"{e['indice']:.2f}"
    )