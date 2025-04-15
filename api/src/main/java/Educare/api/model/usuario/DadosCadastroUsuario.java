package Educare.api.model.usuario;

import Educare.api.model.Professor;
import Educare.api.repository.ProfessorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/professores")
class ProfessorController {
    @Autowired
    private ProfessorRepository repository;

    @GetMapping
    public List<Professor> listar() {
        return repository.findAll();
    }

    @PostMapping
    public Professor criar(@RequestBody Professor p) {
        return repository.save(p);
    }
}

