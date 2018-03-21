package entity;

import entity.opticalnodeinterface.Measurement;
import entity.opticalnodeinterface.Modem;

import java.util.List;

/**
 * @author Vasiliy Kylik on(Rocket) on 18.03.2018.
 */
public class ModemWithLocation extends Modem {
	private List measurements;
	private Integer entranceNumber;
	private Integer floorNumber;
	private Integer interFloorLineNumber;
	private Measurement currentMeasurement;

	public ModemWithLocation(String street, String houseNumber, String linkToMAC, List measurements, Integer entranceNumber, Integer floorNumber, Integer interFloorLineNumber, Measurement currentMeasurement) {
		super(street, houseNumber, linkToMAC);
		this.measurements = measurements;
		this.entranceNumber = entranceNumber;
		this.floorNumber = floorNumber;
		this.interFloorLineNumber = interFloorLineNumber;
		this.currentMeasurement = currentMeasurement;
	}

	public List getMeasurements() {
		return measurements;
	}

	public void setMeasurements(List measurements) {
		this.measurements = measurements;
	}

	public Integer getEntranceNumber() {
		return entranceNumber;
	}

	public void setEntranceNumber(Integer entranceNumber) {
		this.entranceNumber = entranceNumber;
	}

	public Integer getFloorNumber() {
		return floorNumber;
	}

	public void setFloorNumber(Integer floorNumber) {
		this.floorNumber = floorNumber;
	}

	public Integer getInterFloorLineNumber() {
		return interFloorLineNumber;
	}

	public void setInterFloorLineNumber(Integer interFloorLineNumber) {
		this.interFloorLineNumber = interFloorLineNumber;
	}

	public Measurement getCurrentMeasurement() {
		return currentMeasurement;
	}

	public void setCurrentMeasurement(Measurement currentMeasurement) {
		this.currentMeasurement = currentMeasurement;
	}

	@Override
	public String toString() {
		return "ModemWithDislocation{" +
				"measurements=" + measurements +
				", entranceNumber=" + entranceNumber +
				", floorNumber=" + floorNumber +
				", interFloorLineNumber=" + interFloorLineNumber +
				", currentMeasurement=" + currentMeasurement +
				'}';
	}
}
