package com.example.demo.controllers;

import com.example.demo.dto.ProgresoRequest;
import com.example.demo.models.*;
import com.example.demo.repositories.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.Optional;

@RestController
@RequestMapping("/api/progresos")
public class ProgresoController {

    @Autowired private ProgresoRepository progresoRepository;
    @Autowired private UsuarioRepository usuarioRepository;
    @Autowired private RutinaRepository rutinaRepository;

    @PostMapping
    public ResponseEntity<?> guardarProgreso(@RequestBody ProgresoRequest request, Authentication authentication) {
        Optional<Usuario> usuarioOpt = usuarioRepository.findByEmail(authentication.getName());
        if (usuarioOpt.isPresent()) {
            Optional<Rutina> rutinaOpt = rutinaRepository.findById(request.getRutinaId());
            if (rutinaOpt.isPresent()) {
                Progreso p = new Progreso();
                p.setUsuario(usuarioOpt.get());
                p.setRutina(rutinaOpt.get());
                p.setDuracionSegundos(request.getDuracionSegundos());
                p.setPesoTotalLevantado(request.getPesoTotalLevantado());
                progresoRepository.save(p);
                return ResponseEntity.ok("Progreso guardado");
            }
        }
        return ResponseEntity.badRequest().build();
    }
}