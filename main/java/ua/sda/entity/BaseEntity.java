package ua.sda.entity;

import javax.persistence.*;

/**
 * Base class that contains property "id".
 * Used as a based class for all objects that need this property.
 * @author Vasiliy Kylik on(Rocket) on 13.05.2018.
 */
@MappedSuperclass
public class BaseEntity {

	@Id
	@Column (name = "id")
	@GeneratedValue(strategy = GenerationType.AUTO)
	private Long id;

	public BaseEntity() {
	}

	public BaseEntity(Long id) {
		this.id = id;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}
	public boolean isNew(){
		return (this.id==null);
	}
}
