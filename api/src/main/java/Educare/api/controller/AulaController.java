package Educare.api.controller;

import Educare.api.model.Aula;
import Educare.api.repository.AulaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/aulas")
class AulaController {
    @Autowired
    private AulaRepository repository;

    @GetMapping
    public List<Aula> listar() {
        return repository.findAll();
    }

    @PostMapping
    public Aula criar(@RequestBody Aula aula) {
        return repository.save(aula);
    }
}