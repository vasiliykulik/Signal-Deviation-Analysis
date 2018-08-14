package ua.sda.controller.multithread;

import ua.sda.entity.multithreadentities.MultiThreadedMeasurements;
import ua.sda.readers.ModemMeasurementsReader;

import java.util.concurrent.Callable;

/**
 * The {@code MultiThreadModemMeasurementsReader} class represents a dao
 * to obtain measurements for one Specific modem
 *
 * @author Vasiliy Kylik on 13.07.2017.
 */
public class MultiThreadModemMeasurementsReader implements Callable<MultiThreadedMeasurements> {

    private String userName;
    private String password;
    private String linkToMAC;

    public MultiThreadModemMeasurementsReader(String userName, String password, String linkToMAC) {
        this.userName = userName;
        this.password = password;
        this.linkToMAC = linkToMAC;
    }

    /**
     * Parses HTML page for a Measurements info to build a List of measurements
     *
     * @return {@code measurements } MultiThreadedMeasurements entity consist of
     * <br>{@code List<Measurements>} - measurements
     * <br>{@code String linkToMAC} -  field for binding measurements to modem
     */
    @Override
    public MultiThreadedMeasurements call() throws Exception {
        MultiThreadedMeasurements measurements = new MultiThreadedMeasurements();
        measurements.setLinkToMAC(linkToMAC);
        ModemMeasurementsReader modemMeasurementsReader = new ModemMeasurementsReader();
        measurements.setListOfMeasurements(modemMeasurementsReader
                .getMeasurements(linkToMAC, userName, password));
        return measurements;
    }
}
