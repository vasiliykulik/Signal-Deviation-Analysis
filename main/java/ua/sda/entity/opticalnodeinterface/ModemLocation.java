package ua.sda.entity.opticalnodeinterface;

/**
 * @author Vasiliy Kylik on(Rocket) on 18.03.2018.
 */
public class ModemLocation {
	private Integer entranceNumber;
	private Integer floorNumber;
	private Integer interFloorLineNumber;
	private String apartment;

	public ModemLocation() {
	}

	public ModemLocation(Integer entranceNumber, Integer floorNumber, Integer interFloorLineNumber, String apartment) {
		this.entranceNumber = entranceNumber;
		this.floorNumber = floorNumber;
		this.interFloorLineNumber = interFloorLineNumber;
		this.apartment = apartment;
	}

	@Override
	public String toString() {
		return "ModemLocation{" +
				"entranceNumber=" + entranceNumber +
				", floorNumber=" + floorNumber +
				", interFloorLineNumber=" + interFloorLineNumber +
				", apartment='" + apartment + '\'' +
				'}';
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

	public String getApartment() {
		return apartment;
	}

	public void setApartment(String apartment) {
		this.apartment = apartment;
	}

	public boolean isNotNullModemLocation() {
		return apartment != null;
	}
}
