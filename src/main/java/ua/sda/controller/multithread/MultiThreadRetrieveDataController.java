package ua.sda.controller.multithread;

import ua.sda.entity.opticalnodeinterface.Modem;
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
class

public class MultiThreadRetrieveDataController implements Callable<List<Modem>> {
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
            call();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Modem> call() throws Exception {
        ExecutorService exec = Executors.newCachedThreadPool();
        ArrayList<Future<List<MultiThreadedMeasurements>>> futureResults = new ArrayList<>();
        for (Modem modem : modems) {
            futureResults.add(exec.submit(new MultiThreadModemMeasurementsReader(modem.getLinkToMAC(), userName, password)));
        }
        exec.shutdown();
        for (Future<List<MultiThreadedMeasurements>> measurementList : futureResults) {
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
        for (Modem modem:testModemsForMeasurements){
            modem.getMeasurements() == null


        }
    }


}
