package ua.sda.entity.multithreadentities;

import ua.sda.entity.opticalnodeinterface.ModemLocation;

import java.util.List;

/**
 * @author Vasiliy Kylik on(Rocket) on 31.07.2018.
 */
public class MultiThreadedLocation {
    private String linkToMAC;
    private String linkToInfoPage;
    private ModemLocation location;

    @Override
    public String toString() {
        return "MultiThreadedLocation{" +
                "linkToMAC='" + linkToMAC + '\'' +
                ", linkToInfoPage='" + linkToInfoPage + '\'' +
                ", location=" + location +
                '}';
    }

    public String getLinkToMAC() {
        return linkToMAC;
    }

    public void setLinkToMAC(String linkToMAC) {
        this.linkToMAC = linkToMAC;
    }

    public String getLinkToInfoPage() {
        return linkToInfoPage;
    }

    public void setLinkToInfoPage(String linkToInfoPage) {
        this.linkToInfoPage = linkToInfoPage;
    }

    public ModemLocation getLocation() {
        return location;
    }

    public void setLocation(ModemLocation location) {
        this.location = location;
    }

    public MultiThreadedLocation() {

    }

    public MultiThreadedLocation(String linkToMAC, String linkToInfoPage, ModemLocation location) {

        this.linkToMAC = linkToMAC;
        this.linkToInfoPage = linkToInfoPage;
        this.location = location;
    }
}
