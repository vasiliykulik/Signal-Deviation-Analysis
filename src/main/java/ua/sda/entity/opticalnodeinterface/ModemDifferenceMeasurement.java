package ua.sda.entity.opticalnodeinterface;

import java.util.List;

/**
 * Created by Vasiliy Kylik (Lightning) on 11.06.2018.
 */
public class ModemDifferenceMeasurement extends Modem {
    private Float analyzedDifference;


    // Constructor for ModemDifferenceMeasurement through Modem Entity
    public ModemDifferenceMeasurement(Modem modem, Float analyzedDifference) {
        super(modem.getStreet(), modem.getHouseNumber(), modem.getLinkToMAC(), modem.getMeasurements(), modem.getModemLocation());
        this.analyzedDifference = analyzedDifference;
    }


    public ModemDifferenceMeasurement(String street, String houseNumber, String linkToMAC, List<Measurement> measurements, ModemLocation modemLocation, Float analyzedDifference) {
        super(street, houseNumber, linkToMAC, measurements, modemLocation);
        this.analyzedDifference = analyzedDifference;
    }

    public Float getAnalyzedDifference() {

        return analyzedDifference;
    }

    public void setAnalyzedDifference(Float analyzedDifference) {
        this.analyzedDifference = analyzedDifference;
    }

    @Override
    public String toString() {
        return this.getStreet() + '\'' +
                ", " + this.getHouseNumber() + '\'' +
                ", " + this.getModemLocation().getEntranceNumber() +
                "-"+ this.getModemLocation().getFloorNumber() +
                "-"+ this.getModemLocation().getInterFloorLineNumber() +
                " ap "+ this.getModemLocation().getApartment() +
                ", US, DS Difference= " + analyzedDifference +
                ", linkToMAC='" + this.getLinkToMAC() + '\'' +
                '}';
    }

    public String toStringToTxtFile() {
        return this.getStreet() + '\'' +
                ", " + this.getHouseNumber() + '\'' +
                ", " + this.getModemLocation().getEntranceNumber() +
                "-"+ this.getModemLocation().getFloorNumber() +
                "-"+ this.getModemLocation().getInterFloorLineNumber() +
                " ap "+ this.getModemLocation().getApartment() +
                ", US, DS Difference= " + analyzedDifference +
                '}';
    }
 /*   @Override
    public String toString() {
        return "ModemDifferenceMeasurement{" +
                "street='" + this.getStreet() + '\'' +
                ", houseNumber='" + this.getHouseNumber() + '\'' +
                ", measurements=" + this.getModemLocation() +
                ", analyzedDifference=" + analyzedDifference +
                ", linkToMAC='" + this.getLinkToMAC() + '\'' +
            '}';
} */
}
