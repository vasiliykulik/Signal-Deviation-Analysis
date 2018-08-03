package ua.sda.entity.multithreadentities;

import ua.sda.entity.opticalnodeinterface.ModemLocation;

import java.util.List;

/**
 * @author Vasiliy Kylik on(Rocket) on 31.07.2018.
 */
public class MultiThreadedLocation {
    private String linkToMAC;
    private ModemLocation location;



    public MultiThreadedLocation() {
    }

    @Override
    public String toString() {
        return "MultiThreadedLocation{" +
                "linkToMAC='" + linkToMAC + '\'' +
                ", location=" + location +
                '}';
    }

    public String getLinkToMAC() {
        return linkToMAC;
    }

    public void setLinkToMAC(String linkToMAC) {
        this.linkToMAC = linkToMAC;
    }

    public ModemLocation getLocation() {
        return location;
    }

    public void setLocation(ModemLocation location) {
        this.location = location;
    }
}
