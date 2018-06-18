package ua.sda.entity.opticalnodeinterface;

import java.util.List;

/**
 * Created by Vasiliy Kylik (Lightning) on 11.06.2018.
 */
public class ModemDifferenceMeasurement extends Modem {
    private float analyzedDifference;


    // Constructor for ModemDifferenceMeasurement through Modem Entity
    public ModemDifferenceMeasurement(Modem modem, float analyzedDifference) {
        super(modem.getStreet(), modem.getHouseNumber(), modem.getLinkToMAC(), modem.getMeasurements(), modem.getModemLocation());
        this.analyzedDifference = analyzedDifference;
    }


    public ModemDifferenceMeasurement(String street, String houseNumber, String linkToMAC, List<Measurement> measurements, ModemLocation modemLocation, float analyzedDifference) {
        super(street, houseNumber, linkToMAC, measurements, modemLocation);
        this.analyzedDifference = analyzedDifference;
    }

    public float getAnalyzedDifference() {

        return analyzedDifference;
    }

    public void setAnalyzedDifference(float analyzedDifference) {
        this.analyzedDifference = analyzedDifference;
    }

    @Override
    public String toString() {
        return "ModemDifferenceMeasurement{" +
                "analyzedDifference=" + analyzedDifference +
                '}';
    }
}
