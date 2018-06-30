package ua.sda.entity.opticalnodeinterface;

import ua.sda.entity.BaseEntity;

import javax.persistence.*;
import java.util.List;

/**
 * Created by Vasiliy Kylik on 16.07.2017.
 */
@Entity
@Table(name = "modems")
public class Modem extends BaseEntity {

	@Column(name = "street")
	private String street;
	@Column(name = "houseNumber")
	private String houseNumber;
	@Column(name = "linkToMAC")
	private String linkToMAC;


	@OneToMany(fetch = FetchType.EAGER, cascade = CascadeType.ALL)
	@JoinTable(
			name = "modems_measurements",
			joinColumns = @JoinColumn(name = "modemId"),
			inverseJoinColumns = @JoinColumn(name = "measurementsId")
	)
	private List<Measurement> measurements;
	@OneToOne(fetch = FetchType.EAGER, cascade = CascadeType.ALL)
	@JoinTable(
			name = "modems_location",
			joinColumns = @JoinColumn(name = "modemId"),
			inverseJoinColumns = @JoinColumn(name = "locationId")
	)
	private ModemLocation modemLocation;

	public Modem() {
	}

	public Modem(String street, String houseNumber, String linkToMAC, List<Measurement> measurements, ModemLocation modemLocation) {
		this.street = street;
		this.houseNumber = houseNumber;
		this.linkToMAC = linkToMAC;
		this.measurements = measurements;
		this.modemLocation = modemLocation;
	}

	@Override
	public String toString() {
		return "Modem{" +
				"street='" + street + '\'' +
				", houseNumber='" + houseNumber + '\'' +
				", linkToMAC='" + linkToMAC + '\'' +
				", measurements=" + measurements +
				", modemLocation=" + modemLocation +
				'}';
	}

	public String getStreet() {
		return street;
	}

	public void setStreet(String street) {
		this.street = street;
	}

	public String getHouseNumber() {
		return houseNumber;
	}

	public void setHouseNumber(String houseNumber) {
		this.houseNumber = houseNumber;
	}

	public String getLinkToMAC() {
		return linkToMAC;
	}

	public void setLinkToMAC(String linkToMAC) {
		this.linkToMAC = linkToMAC;
	}

	public List<Measurement> getMeasurements() {
		return measurements;
	}

	public void setMeasurements(List<Measurement> measurements) {
		this.measurements = measurements;
	}

	public ModemLocation getModemLocation() {
		return modemLocation;
	}

	public void setModemLocation(ModemLocation modemLocation) {
		this.modemLocation = modemLocation;
	}
}
