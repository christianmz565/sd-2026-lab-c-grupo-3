from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class Estudiante(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    matricula = db.Column(db.String(50), nullable=False)
    nombre = db.Column(db.String(100), nullable=False)
    carrera = db.Column(db.String(100), nullable=False)
    edad = db.Column(db.Integer, nullable=False)
    email = db.Column(db.String(120), nullable=False)
    telefono = db.Column(db.String(30), nullable=False)
    matriculado = db.Column(db.Boolean, nullable=False, default=True)
    semestres = db.Column(db.Integer, nullable=False)
    estado = db.Column(db.String(40), nullable=False)

    def to_dict(self):
        return {
            "id": self.id,
            "matricula": self.matricula,
            "nombre": self.nombre,
            "carrera": self.carrera,
            "edad": self.edad,
            "email": self.email,
            "telefono": self.telefono,
            "matriculado": self.matriculado,
            "semestres": self.semestres,
            "estado": self.estado
        }
