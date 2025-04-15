package Educare.api.model.usuario;
import jakarta.validation.constraints.*;
import java.time.LocalDate;

public record DadosCadastroUsuario(
        @NotBlank
        String nome,

        @NotBlank
        @Email
        String email,

        @NotBlank
        String senha,

        @NotNull
        TipoUsuario tipoUsuario,

        @NotBlank
        String dataNascimento,

        @NotBlank
        String genero
) {}
