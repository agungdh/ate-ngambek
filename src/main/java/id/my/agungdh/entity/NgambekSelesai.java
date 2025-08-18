package id.my.agungdh.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntity;
import jakarta.persistence.Entity;

import java.time.LocalDateTime;

@Entity
public class NgambekSelesai extends PanacheEntity {
    String gimana;
    LocalDateTime kapan;
}
