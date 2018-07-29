package ua.sda.controller.multithread;

import ua.sda.entity.opticalnodeinterface.Modem;
import ua.sda.entity.multithreadentities.MultiThreadedMeasurements;
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
        * The {@code ModemMeasurementsReader} class represents a dao
 * to obtain Addresses with Links to modems.
         * <p>
 * This implementation uses a
         * <p>
 * URL and BASE64Encoder to create
         * <p>
 * HttpURLConnection to create
         * <p>
 * InputStreamReader to create
         * <p>
 * BufferedReader to read HTML lines
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

     * @return {@code measurements }List of measurements for particularly taken modem;
     * <br>{@code isNewLinkToInfoPage} - parsed only ones, after that value only is assigned
     * <br>{@code htmlLineWithTable} -  htmlLineWithTable through regex from html page. Take Html line with table of measurements to read one string table.
     * <br>{@code tableRows} -  cut HTML one line table into table row blocks and add to collection (List), implemented using array

     */
    @Override
    public MultiThreadedMeasurements call() throws Exception {
        MultiThreadedMeasurements measurements = new MultiThreadedMeasurements();
        measurements.setLinkToMAC(linkToMAC);
        ModemMeasurementsReader modemMeasurementsReader = new ModemMeasurementsReader();
        measurements.setListOfMeasurements(modemMeasurementsReader.getMeasurements(linkToMAC, userName, password););
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
            getMeasurements();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }


    public List<Modem> getMeasurements() throws Exception {
        ExecutorService exec = Executors.newCachedThreadPool();
        ArrayList<Future<MultiThreadedMeasurements>> futureResults = new ArrayList<>();
        for (Modem modem : modems) {
            futureResults.add(exec.submit(new MultiThreadModemMeasurementsReader(modem.getLinkToMAC(), userName, password)));
        }
        exec.shutdown();
        for (Future<MultiThreadedMeasurements> measurementList : futureResults) {
            try {
                modems.get(findIndexOfModem(measurementList.get().getLinkToMac()))
                        .setMeasurements(measurementList.get().getListOfMeasurements());
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        isMeasurementsNull(modems);

        return null;
    }

    private boolean isMeasurementsNull(List<Modem> testModemsForMeasurements) {
        for (Modem modem : testModemsForMeasurements) {
            modem.getMeasurements() == null


        }
    }


}
