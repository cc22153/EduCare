package Educare.api.model.usuario;

import Educare.api.model.usuario.TipoUsuario;
import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "Usuarios")
public class Usuario {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String nome;
    private String email;
    private String senha;

    @Enumerated(EnumType.STRING)
    private TipoUsuario tipoUsuario;

    private LocalDate dataNascimento;
    private String genero;

    // getters e setters
}