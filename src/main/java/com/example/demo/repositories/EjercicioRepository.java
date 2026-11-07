package com.example.demo.repositories;

import com.example.demo.models.Ejercicio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EjercicioRepository extends JpaRepository<Ejercicio, Long> {
    // Aquí puedes agregar búsquedas personalizadas luego, ej: findByGrupoMuscular(String grupo);
}