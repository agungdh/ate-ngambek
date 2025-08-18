package id.my.agungdh.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Entity;
import jakarta.persistence.OneToOne;

import java.time.LocalDateTime;

@Entity
public class Ngambek extends PanacheEntity {
    String kenapa;
    LocalDateTime kapan;
    String siapa;
    @OneToOne
    NgambekSelesai ngambekSelesai;
}
