from flask import request, jsonify, send_from_directory
from .models import db, Estudiante

def register_routes(app):
    
    @app.route('/')
    def index():
        return send_from_directory(app.static_folder, 'index.html')
    
    @app.route('/estudiantes', methods=['GET'])
    def listar():
        estudiantes = Estudiante.query.all()
        return jsonify([e.to_dict() for e in estudiantes])

    @app.route('/estudiantes', methods=['POST'])
    def agregar():
        data = request.json
        nuevo = Estudiante(
            matricula=data.get('matricula', ''),
            nombre=data.get('nombre', ''),
            carrera=data.get('carrera', ''),
            edad=data.get('edad', 0),
            email=data.get('email', ''),
            telefono=data.get('telefono', ''),
            matriculado=bool(data.get('matriculado', True)) if isinstance(data.get('matriculado', True), bool) else data.get('matriculado', 'true') in ['true', True, 1],
            semestres=data.get('semestres', 0),
            estado=data.get('estado', 'Activo')
        )
        db.session.add(nuevo)
        db.session.commit()
        return jsonify({"ok": True})

    @app.route('/estudiantes/<int:i>', methods=['PUT'])
    def actualizar(i):
        estudiante = db.session.get(Estudiante, i)
        if estudiante:
            data = request.json
            if 'matricula' in data:
                estudiante.matricula = data['matricula']
            if 'nombre' in data:
                estudiante.nombre = data['nombre']
            if 'carrera' in data:
                estudiante.carrera = data['carrera']
            if 'edad' in data:
                estudiante.edad = data['edad']
            if 'email' in data:
                estudiante.email = data['email']
            if 'telefono' in data:
                estudiante.telefono = data['telefono']
            if 'matriculado' in data:
                estudiante.matriculado = data['matriculado'] if isinstance(data['matriculado'], bool) else data['matriculado'] in ['true', True, 1]
            if 'semestres' in data:
                estudiante.semestres = data['semestres']
            if 'estado' in data:
                estudiante.estado = data['estado']
            
            db.session.commit()
            return jsonify({"actualizado": True})
        return jsonify({"error": "Estudiante no encontrado"}), 404

    @app.route('/estudiantes/<int:i>', methods=['DELETE'])
    def eliminar(i):
        estudiante = db.session.get(Estudiante, i)
        if estudiante:
            db.session.delete(estudiante)
            db.session.commit()
            return jsonify({"eliminado": True})
        return jsonify({"error": "Estudiante no encontrado"}), 404
