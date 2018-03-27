package ua.sda.entity.opticalnodeinterface;

/**
 * Created by Vasiliy Kylik on 17.07.2017.
 */
public class Address {
  private String street;
  private String houseNumber;

  public Address(String street, String houseNumber) {
    this.street = street;
    this.houseNumber = houseNumber;
  }

  @Override
  public String toString() {
    return "Address{" +
            "street='" + street + '\'' +
            ", houseNumber='" + houseNumber + '\'' +
            '}';
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof Address)) return false;

    Address address = (Address) o;

    if (!getStreet().equals(address.getStreet())) return false;
    return getHouseNumber().equals(address.getHouseNumber());
  }

  @Override
  public int hashCode() {
    int result = getStreet().hashCode();
    result = 31 * result + getHouseNumber().hashCode();
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
}
