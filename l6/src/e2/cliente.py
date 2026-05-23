import requests
import json
import os

BASE_URL = 'http://127.0.0.1:5000/estudiantes'

def test_api():
    print("="*60)
    print("🚀 EVIDENCIA DE EJECUCIÓN API RESTFUL Y CLIENTE CONSUMIDOR")
    print("="*60)
    
    # 1. Registrar estudiante (POST)
    print("\n1️⃣  [POST] Registrando un nuevo estudiante...")
    nuevo_estudiante = {
        "matricula": "2026-TEA-0101",
        "nombre": "Pedro Pascal",
        "carrera": "Artes Escenicas",
        "edad": 28,
        "email": "pedro.pascal@campus.edu",
        "telefono": "+51 955 110 220",
        "matriculado": True,
        "semestres": 4,
        "estado": "Activo"
    }
    print(f"   Enviando datos: {json.dumps(nuevo_estudiante)}")
    r_post = requests.post(BASE_URL, json=nuevo_estudiante)
    print(f"   => Respuesta (Status {r_post.status_code}): {r_post.json()}")
    
    # 2. Consultar estudiantes (GET)
    print("\n2️⃣  [GET] Consultando lista de estudiantes...")
    r_get = requests.get(BASE_URL)
    estudiantes = r_get.json()
    print(f"   => Se obtuvieron {len(estudiantes)} registros.")
    print(f"   => Muestra de los últimos 2 registros:")
    for est in estudiantes[-2:]:
        print(
            f"      - ID: {est['id']} | {est['nombre']} | {est['matricula']} | "
            f"{est['carrera']} | {est['edad']} años | {est['estado']}"
        )
    
    if estudiantes:
        # Usamos el ID del último estudiante (que debería ser el que acabamos de crear)
        ultimo_id = estudiantes[-1]['id']
        
        # 3. Actualizar estudiante (PUT)
        print(f"\n3️⃣  [PUT] Actualizando estudiante con ID {ultimo_id}...")
        datos_actualizacion = {
            "nombre": "Pedro Pascal Modificado",
            "edad": 29,
            "matriculado": False,
            "semestres": 5,
            "estado": "En riesgo"
        }
        print(f"   Enviando datos: {json.dumps(datos_actualizacion)}")
        r_put = requests.put(f"{BASE_URL}/{ultimo_id}", json=datos_actualizacion)
        print(f"   => Respuesta (Status {r_put.status_code}): {r_put.json()}")
        
        # Consultar para confirmar actualización
        print(f"   => Verificando estado tras la actualización...")
        r_verify = requests.get(BASE_URL)
        estudiante_actualizado = next((e for e in r_verify.json() if e['id'] == ultimo_id), None)
        print(f"      Resultado en BD: {estudiante_actualizado}")

        # 4. Eliminar estudiante (DELETE)
        print(f"\n4️⃣  [DELETE] Eliminando estudiante con ID {ultimo_id}...")
        r_delete = requests.delete(f"{BASE_URL}/{ultimo_id}")
        print(f"   => Respuesta (Status {r_delete.status_code}): {r_delete.json()}")
        
        # Consultar para confirmar eliminación
        print(f"   => Verificando estado tras la eliminación...")
        r_verify_del = requests.get(BASE_URL)
        estudiante_eliminado = next((e for e in r_verify_del.json() if e['id'] == ultimo_id), None)
        if estudiante_eliminado is None:
            print("      ✅ Confirmado: El estudiante ya no existe en la BD.")
        else:
            print("      ❌ Error: El estudiante aún existe.")
    else:
        print("\n⚠️ No hay estudiantes en la BD para probar UPDATE/DELETE.")
    
    print("\n" + "="*60)
    print("✅ PRUEBAS FINALIZADAS CON ÉXITO")
    print("="*60)

if __name__ == '__main__':
    try:
        # Hacer una prueba de conexión rápida
        requests.get(BASE_URL, timeout=2)
        test_api()
    except requests.exceptions.ConnectionError:
        print(f"❌ ERROR: No se pudo conectar al servidor en {BASE_URL}.")
        print("   Por favor, asegúrate de que el servidor Flask (run.py) esté corriendo.")
        print("   Comando: uv run python run.py")
