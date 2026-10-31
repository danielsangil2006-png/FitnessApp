package com.example.demo.dto;
import java.util.List;

public class RutinaRequest {
    private String nombre;
    private String descripcion;
    private List<Long> ejercicioIds;

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public List<Long> getEjercicioIds() { return ejercicioIds; }
    public void setEjercicioIds(List<Long> ejercicioIds) { this.ejercicioIds = ejercicioIds; }
}