package ua.sda.entity.multithreadentities;

import ua.sda.entity.opticalnodeinterface.Measurement;

import java.util.List;

/**
 * Created by Vasiliy Kylik (Lightning) on 25.07.2018.
 */
public class MultiThreadedMeasurements {
    private String linkToMAC;
    private List<Measurement> listOfMeasurements;

    @Override
    public String toString() {
        return "MultiThreadedMeasurements{" +
                "linkToMAC='" + linkToMAC + '\'' +
                ", listOfMeasurements=" + listOfMeasurements +
                '}';
    }

    public String getLinkToMAC() {
        return linkToMAC;
    }

    public void setLinkToMAC(String linkToMAC) {
        this.linkToMAC = linkToMAC;
    }

    public List<Measurement> getListOfMeasurements() {
        return listOfMeasurements;
    }

    public void setListOfMeasurements(List<Measurement> listOfMeasurements) {
        this.listOfMeasurements = listOfMeasurements;
    }

    public MultiThreadedMeasurements() {
    }

    public MultiThreadedMeasurements(String linkToMAC, List<Measurement> listOfMeasurements) {

        this.linkToMAC = linkToMAC;
        this.listOfMeasurements = listOfMeasurements;
    }
}
