import os
import json
from flask import Flask
from .models import db, Estudiante

def create_app():
    app = Flask(__name__, static_url_path='')
    
    # Configuración de SQLite
    basedir = os.path.abspath(os.path.dirname(__file__))
    
    # Ubicacion de la base de datos
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, '..', 'estudiantes.db')
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    db.init_app(app)

    from .routes import register_routes
    register_routes(app)

    # Llenar la base de datos con datos iniciales si está vacía
    with app.app_context():
        db.create_all()
        if Estudiante.query.first() is None:
            seed_file_path = os.path.join(basedir, '..', 'seed', 'data-mock.json')
            if os.path.exists(seed_file_path):
                with open(seed_file_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    datos_iniciales = data.get('datos_iniciales', [])
                    for est_data in datos_iniciales:
                        nuevo = Estudiante(
                            matricula=est_data['matricula'],
                            nombre=est_data['nombre'],
                            carrera=est_data['carrera'],
                            edad=est_data['edad'],
                            email=est_data['email'],
                            telefono=est_data['telefono'],
                            matriculado=est_data['matriculado'],
                            semestres=est_data['semestres'],
                            estado=est_data['estado']
                        )
                        db.session.add(nuevo)
                    db.session.commit()
                    print("✅ Base de datos inicializada desde seed/data-mock.json")
    
    return app
