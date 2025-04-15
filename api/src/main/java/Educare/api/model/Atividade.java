package Educare.api.model;

import jakarta.persistence.*;

import java.util.Date;

@Entity
@Table(name = "Atividades")
public class Atividade {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "aluno_id", nullable = false)
    private Aluno aluno;

    private String descricao;

    @Column(name = "arquivo_pdf")
    private String arquivoPdf;

    @Column(name = "adaptado_por_ia")
    private Boolean adaptadoPorIa = false;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "data_criacao")
    private Date dataCriacao;

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Aluno getAluno() {
        return aluno;
    }

    public void setAluno(Aluno aluno) {
        this.aluno = aluno;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public String getArquivoPdf() {
        return arquivoPdf;
    }

    public void setArquivoPdf(String arquivoPdf) {
        this.arquivoPdf = arquivoPdf;
    }

    public Boolean getAdaptadoPorIa() {
        return adaptadoPorIa;
    }

    public void setAdaptadoPorIa(Boolean adaptadoPorIa) {
        this.adaptadoPorIa = adaptadoPorIa;
    }

    public Date getDataCriacao() {
        return dataCriacao;
    }

    public void setDataCriacao(Date dataCriacao) {
        this.dataCriacao = dataCriacao;
    }
}
