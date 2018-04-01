package ua.sda.entity.drafts;

import java.util.List;

/**
 * Created by Vasiliy Kylik on 16.07.2017.
 */
public class OpticalNodeInterfaceLinkToMAC {
  @Override
  public String toString() {
    return "OpticalNodeInterfaceLinkToMAC{" +
            "linkToMAC=" + linkToMAC +
            '}';
  }

  public List<String> getLinkToMAC() {
    return linkToMAC;
  }

  public void setLinkToMAC(List<String> linkToMAC) {
    this.linkToMAC = linkToMAC;
  }

  private List<String> linkToMAC;

  public OpticalNodeInterfaceLinkToMAC(List<String> linkToMAC) {
    this.linkToMAC = linkToMAC;
  }


  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof OpticalNodeInterfaceLinkToMAC)) return false;

    OpticalNodeInterfaceLinkToMAC that = (OpticalNodeInterfaceLinkToMAC) o;

    return getLinkToMAC().equals(that.getLinkToMAC());
  }

  @Override
  public int hashCode() {
    return getLinkToMAC().hashCode();
  }
}
