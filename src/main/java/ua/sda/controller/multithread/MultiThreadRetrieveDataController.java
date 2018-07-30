package ua.sda.controller.multithread;

import ua.sda.entity.multithreadentities.MultiThreadedMeasurements;
import ua.sda.entity.opticalnodeinterface.Modem;
import ua.sda.exceptions.MultiThreadingReadMeasurementsException;
import ua.sda.readers.ModemMeasurementsReader;
import ua.sda.readers.OpticalNodeSingleInterfaceReader;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

/**
 * @author Vasiliy Kylik on(Rocket) on 12.07.2018.
 */

/**
 * The {@code MultiThreadModemMeasurementsReader} class represents a dao
 * to obtain measurements for one Specific modem
 *
 * @author Vasiliy Kylik on 13.07.2017.
 */
class MultiThreadModemMeasurementsReader implements Callable<MultiThreadedMeasurements> {

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

public class MultiThreadRetrieveDataController {
    private List<Modem> modems = new ArrayList<>();
    private String userName;
    private String password;
    private String urlString;

    public MultiThreadRetrieveDataController(String userName, String password, String urlString) {
        this.userName = userName;
        this.password = password;
        this.urlString = urlString;
    }

    public List<Modem> getAll() {
        // the virtual database is a web resource protected using BASIC HTTP Authentication

        // Reading modems (street, houseNumber, linkToMAC) from "TrafficLight"

        OpticalNodeSingleInterfaceReader opticalNodeSingleInterfaceReader = new OpticalNodeSingleInterfaceReader();
        try {
            modems = opticalNodeSingleInterfaceReader.getModemsUrls(urlString, userName, password);
            getMeasurements(modems);
            getCurrentStates(modems);
            getLocations(modems);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return modems;
    }

    private List<Modem> getLocations(List<Modem> modemsLocations) {
        return null;
    }

    private List<Modem> getCurrentStates(List<Modem> CurrentStates) {
        return null;
    }

    /**
     * Using ExecutorService, read measurements for modems
     * while iterating over the collection futureResults , take from each object listOfMeasurements and
     * set to the coresponding object from collection modems, which binds thru field  linkToMAC
     *
     * @return {@code measurements } MultiThreadedMeasurements entity consist of
     * <br>{@code List<Measurements>} - measurements
     * <br>{@code String linkToMAC} -  field for binding measurements to modem
     */
    public List<Modem> getMeasurements(List<Modem> modemsMeasurements) throws Exception {
        ExecutorService exec = Executors.newCachedThreadPool();
        ArrayList<Future<MultiThreadedMeasurements>> futureResults = new ArrayList<>();
        for (Modem modem : modemsMeasurements) {
            futureResults.add(exec.submit(new MultiThreadModemMeasurementsReader(modem.getLinkToMAC(), userName, password)));
        }
        exec.shutdown();
        for (Future<MultiThreadedMeasurements> measurementList : futureResults) {

            try {
                modemsMeasurements.get(findIndexOfModem(modemsMeasurements, measurementList.get().getLinkToMAC()))
                        .setMeasurements(measurementList.get().getListOfMeasurements());
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        isMeasurementsNull(modemsMeasurements);

        return modemsMeasurements;
    }

    // we will not apply the sorting, we will check every time
    private int findIndexOfModem(List<Modem> modemsMeasurements, String linkToMAC) {
        for (Modem modem : modemsMeasurements) {
            if (modem.getLinkToMAC().equals(linkToMAC)) {
                return modemsMeasurements.indexOf(modem);
            }

        }
        return -1;
    }

    private boolean isMeasurementsNull(List<Modem> testModemsForMeasurements) {
        for (Modem modem : testModemsForMeasurements) {
            try {
                if (modem.getMeasurements() == null) {
                    throw new MultiThreadingReadMeasurementsException
                            ("Failed to read Measurements in MultiThreaded Section");
                }
            } catch (MultiThreadingReadMeasurementsException e) {
                System.err.println(e.getMessage());

            }
        }
        return false;
    }


}
