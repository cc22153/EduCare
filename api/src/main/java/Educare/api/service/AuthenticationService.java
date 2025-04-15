package Educare.api.service;

import Educare.api.dto.LoginRequest;
import Educare.api.model.usuario.Usuario;
import Educare.api.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.*;

import java.util.*;

@Service
public class AuthenticationService {
    @Autowired
    private UsuarioRepository usuarioRepository;

    public ResponseEntity<?> login(LoginRequest request) {
        Optional<Usuario> usuarioOpt = usuarioRepository.findByEmail(request.getEmail());

        if (usuarioOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Usuário não encontrado");
        }

        Usuario usuario = usuarioOpt.get();

        if (!usuario.getSenha().equals(request.getSenha())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Senha incorreta");
        }

        // Aqui você pode gerar um token JWT ou simplesmente retornar os dados do usuário
        usuario.setSenha("");
        return ResponseEntity.ok(usuario);
    }
}

