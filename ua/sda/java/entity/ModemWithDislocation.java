package entity;

import entity.opticalnodeinterface.Measurement;
import entity.opticalnodeinterface.Modem;

import java.util.List;

/**
 * @author Vasiliy Kylik on(Rocket) on 18.03.2018.
 */
public class ModemWithDislocation extends Modem {
	private List measurements;
	private String location;
	private Measurement currentMeasurement;

	public ModemWithDislocation(String street, String houseNumber, String linkToMAC, List measurements, String location, Measurement currentMeasurement) {
		super(street, houseNumber, linkToMAC);
		this.measurements = measurements;
		this.location = location;
		this.currentMeasurement = currentMeasurement;
	}

	public List getMeasurements() {
		return measurements;
	}

	public void setMeasurements(List measurements) {
		this.measurements = measurements;
	}

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public Measurement getCurrentMeasurement() {
		return currentMeasurement;
	}

	public void setCurrentMeasurement(Measurement currentMeasurement) {
		this.currentMeasurement = currentMeasurement;
	}
}
