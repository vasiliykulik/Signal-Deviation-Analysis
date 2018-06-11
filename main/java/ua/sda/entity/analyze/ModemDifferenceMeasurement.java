package ua.sda.entity.analyze;

import ua.sda.entity.opticalnodeinterface.Measurement;
import ua.sda.entity.opticalnodeinterface.Modem;
import ua.sda.entity.opticalnodeinterface.ModemLocation;

import java.util.List;

/**
 * Created by Vasiliy Kylik (Lightning) on 11.06.2018.
 */
public class ModemDifferenceMeasurement extends Modem {
    float analyzeDifference;

    public ModemDifferenceMeasurement(float analyzeDifference) {
        this.analyzeDifference = analyzeDifference;
    }

    public ModemDifferenceMeasurement(String street, String houseNumber, String linkToMAC, List<Measurement> measurements, ModemLocation modemLocation, float analyzeDifference) {
        super(street, houseNumber, linkToMAC, measurements, modemLocation);
        this.analyzeDifference = analyzeDifference;
    }

    public float getAnalyzeDifference() {

        return analyzeDifference;
    }

    public void setAnalyzeDifference(float analyzeDifference) {
        this.analyzeDifference = analyzeDifference;
    }

    @Override
    public String toString() {
        return "ModemDifferenceMeasurement{" +
                "analyzeDifference=" + analyzeDifference +
                '}';
    }
}
