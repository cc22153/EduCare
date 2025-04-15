package Educare.api.controller;

import Educare.api.model.Rotina;
import Educare.api.repository.RotinaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/rotinas")
class RotinaController {
    @Autowired
    private RotinaRepository repository;

    @GetMapping
    public List<Rotina> listar() {
        return repository.findAll();
    }

    @PostMapping
    public Rotina criar(@RequestBody Rotina rotina) {
        return repository.save(rotina);
    }
}
