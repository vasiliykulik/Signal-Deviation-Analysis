package ua.sda.entity.opticalnodeinterface;

/**
 * Created by Vasiliy Kylik on 17.07.2017.
 */
public class Link {
  private String linkToMAC;

  public String getLinkToMAC() {
    return linkToMAC;
  }

  @Override
  public String toString() {
    return "Link{" +
            "linkToMAC='" + linkToMAC + '\'' +
            '}';
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof Link)) return false;

    Link link = (Link) o;

    return getLinkToMAC().equals(link.getLinkToMAC());
  }

  @Override
  public int hashCode() {
    return getLinkToMAC().hashCode();
  }

  public void setLinkToMAC(String linkToMAC) {
    this.linkToMAC = linkToMAC;
  }

  public Link(String linkToMAC) {

    this.linkToMAC = linkToMAC;
  }
}
