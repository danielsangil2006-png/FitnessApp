package com.example.demo.dto;
import java.util.List;

public class RutinaDetalleDTO {
    private Long id;
    private String nombre;
    private String descripcion;
    private List<RutinaEjercicioDTO> ejercicios;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public List<RutinaEjercicioDTO> getEjercicios() { return ejercicios; }
    public void setEjercicios(List<RutinaEjercicioDTO> ejercicios) { this.ejercicios = ejercicios; }
}