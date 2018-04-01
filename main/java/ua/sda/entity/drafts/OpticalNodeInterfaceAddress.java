package ua.sda.entity.drafts;

/**
 * Created by Vasiliy Kylik on 16.07.2017.
 */
public class OpticalNodeInterfaceAddress {
  private String street;
  private String houseNumber;

  public OpticalNodeInterfaceAddress(String street, String houseNumber) {
    this.street = street;
    this.houseNumber = houseNumber;
  }


  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof OpticalNodeInterfaceAddress)) return false;

    OpticalNodeInterfaceAddress that = (OpticalNodeInterfaceAddress) o;

    if (!getStreet().equals(that.getStreet())) return false;
    return getHouseNumber().equals(that.getHouseNumber());
  }

  @Override
  public int hashCode() {
    int result = getStreet().hashCode();
    result = 31 * result + getHouseNumber().hashCode();
    return result;
  }

  @Override
  public String toString() {
    return "OpticalNodeInterfaceAddress{" +
            "street='" + street + '\'' +
            ", houseNumber='" + houseNumber + '\'' +
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


}
