package entity.opticalnodeinterface;

/**
 * Created by Vasiliy Kylik on 16.07.2017.
 */
public class Modem {

  private String street;
  private String houseNumber;
  private String linkToMAC;

  public Modem(String street, String houseNumber, String linkToMAC) {
    this.street = street;
    this.houseNumber = houseNumber;
    this.linkToMAC = linkToMAC;
  }

  @Override
  public String toString() {
    return "Modem{" +
            "street='" + street + '\'' +
            ", houseNumber='" + houseNumber + '\'' +
            ", linkToMAC='" + linkToMAC + '\'' +
            '}';
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof Modem)) return false;

    Modem that = (Modem) o;

    if (!getStreet().equals(that.getStreet())) return false;
    if (!getHouseNumber().equals(that.getHouseNumber())) return false;
    return getLinkToURL().equals(that.getLinkToURL());
  }

  @Override
  public int hashCode() {
    int result = getStreet().hashCode();
    result = 31 * result + getHouseNumber().hashCode();
    result = 31 * result + getLinkToURL().hashCode();
    return result;
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

  public String getLinkToURL() {
    return linkToMAC;
  }

  public void setLinkToURL(String linkToMAC) {
    this.linkToMAC = linkToMAC;
  }
}
