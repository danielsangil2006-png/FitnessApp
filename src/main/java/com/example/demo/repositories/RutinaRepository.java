package com.example.demo.repositories;

import com.example.demo.models.Rutina;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface RutinaRepository extends JpaRepository<Rutina, Long> {
    // Buscará automáticamente todas las rutinas creadas por un usuario específico
    List<Rutina> findByUsuarioId(Long usuarioId);
}