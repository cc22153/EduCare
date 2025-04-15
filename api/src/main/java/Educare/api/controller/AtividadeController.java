package Educare.api.controller;

import Educare.api.model.Atividade;
import Educare.api.repository.AtividadeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/atividades")
class AtividadeController {
    @Autowired
    private AtividadeRepository repository;

    @GetMapping
    public List<Atividade> listar() {
        return repository.findAll();
    }

    @PostMapping
    public Atividade criar(@RequestBody Atividade atividade) {
        return repository.save(atividade);
    }
}