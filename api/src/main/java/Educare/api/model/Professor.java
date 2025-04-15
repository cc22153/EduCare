package Educare.api.model;

import Educare.api.model.usuario.Usuario;
import jakarta.persistence.*;

@Entity
@Table(name = "Professores")
public class Professor {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @OneToOne
    @JoinColumn(name = "usuario_id")
    private Usuario usuario;

    // getters e setters
}
