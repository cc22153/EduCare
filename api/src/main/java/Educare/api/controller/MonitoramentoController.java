package Educare.api.controller;

import Educare.api.model.Monitoramento;
import Educare.api.repository.MonitoramentoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/monitoramentos")
class MonitoramentoController {
    @Autowired
    private MonitoramentoRepository repository;

    @GetMapping
    public List<Monitoramento> listar() {
        return repository.findAll();
    }

    @PostMapping
    public Monitoramento criar(@RequestBody Monitoramento monitoramento) {
        return repository.save(monitoramento);
    }
}