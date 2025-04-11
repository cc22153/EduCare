package Educare.api.controller;

import org.springframework.web.bind.annotation.RestController;

import org.springframework.web.bind.annotation.RequestMapping;

@RestController
@RequestMapping("/hello")
public class HelloController {
    public String olaMundo(){
        return "<h1> Hello World! </h1>";
    }
}