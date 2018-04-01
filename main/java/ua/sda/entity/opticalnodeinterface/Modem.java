package ua.sda.entity.opticalnodeinterface;

import java.util.List;

/**
 * Created by Vasiliy Kylik on 16.07.2017.
 */
public class Modem {

  private String street;
  private String houseNumber;
  private String linkToMAC;
  private List<Measurement> measurements;

  public Modem() {
  }

  public Modem(String street, String houseNumber, String linkToMAC, List<Measurement> measurements) {
    this.street = street;
    this.houseNumber = houseNumber;
    this.linkToMAC = linkToMAC;
    this.measurements = measurements;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof Modem)) return false;

    Modem modem = (Modem) o;

    if (getStreet() != null ? !getStreet().equals(modem.getStreet()) : modem.getStreet() != null) return false;
    if (getHouseNumber() != null ? !getHouseNumber().equals(modem.getHouseNumber()) : modem.getHouseNumber() != null)
      return false;
    if (getLinkToMAC() != null ? !getLinkToMAC().equals(modem.getLinkToMAC()) : modem.getLinkToMAC() != null)
      return false;
    return getMeasurements() != null ? getMeasurements().equals(modem.getMeasurements()) : modem.getMeasurements() == null;
  }

  @Override
  public int hashCode() {
    int result = getStreet() != null ? getStreet().hashCode() : 0;
    result = 31 * result + (getHouseNumber() != null ? getHouseNumber().hashCode() : 0);
    result = 31 * result + (getLinkToMAC() != null ? getLinkToMAC().hashCode() : 0);
    result = 31 * result + (getMeasurements() != null ? getMeasurements().hashCode() : 0);
    return result;
  }

  @Override
  public String toString() {
    return "Modem{" +
            "street='" + street + '\'' +
            ", houseNumber='" + houseNumber + '\'' +
            ", linkToMAC='" + linkToMAC + '\'' +
            ", measurements=" + measurements +
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
}
