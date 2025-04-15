package Educare.api.controller;

import Educare.api.model.Responsavel;
import Educare.api.repository.ResponsavelRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/responsaveis")
class ResponsavelController {
    @Autowired
    private ResponsavelRepository repository;

    @GetMapping
    public List<Responsavel> listar() {
        return repository.findAll();
    }

    @PostMapping
    public Responsavel criar(@RequestBody Responsavel r) {
        return repository.save(r);
    }
}
