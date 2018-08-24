package ua.sda.controller.multithread;

import ua.sda.entity.multithreadentities.MultiThreadedCurrentState;
import ua.sda.entity.multithreadentities.MultiThreadedLocation;
import ua.sda.entity.multithreadentities.MultiThreadedMeasurements;
import ua.sda.entity.opticalnodeinterface.Modem;
import ua.sda.exceptions.MultiThreadingReadMeasurementsException;
import ua.sda.readers.OpticalNodeSingleInterfaceReader;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

/**
 * @author Vasiliy Kylik on(Rocket) on 12.07.2018.
 */

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
        ExecutorService exec = Executors.newFixedThreadPool(4);
        ArrayList<Future<MultiThreadedLocation>> futureResults = new ArrayList<>();
        for(Modem modem : modemsLocations){
            futureResults.add(exec.submit(new MTModemLocationReader(modem.getLinkToMAC(),
                    modem.getMeasurements().get(0).getLinkToInfoPage(),userName,password)));
        }
        exec.shutdown();
        for(Future<MultiThreadedLocation> location:futureResults){
            try{
                modemsLocations.get(findIndexOfModem(modemsLocations,location.get().getLinkToMAC()))
                        .setModemLocation(location.get().getLocation());

            }catch (Exception e){
                e.printStackTrace();
            }
        }
        return null;
    }

    private List<Modem> getCurrentStates(List<Modem> modemsCurrentStates) {
        ExecutorService exec = Executors.newFixedThreadPool(4);
        ArrayList<Future<MultiThreadedCurrentState>> futureResults = new ArrayList<>();
        for (Modem modem : modemsCurrentStates) {
            futureResults.add(exec.submit(new MTModemCurrentStateReader(modem.getLinkToMAC(),
                    modem.getMeasurements().get(0).getLinkToCurrentState(), userName, password,
                    modem.getMeasurements().get(0).getLinkToInfoPage())));
        }
        exec.shutdown();
        for (Future<MultiThreadedCurrentState> currentState : futureResults) {
            try{
                modemsCurrentStates.get(findIndexOfModem(modemsCurrentStates, currentState.get().getLinkToMAC()))
                        .getMeasurements().add(currentState.get().getCurrentState());
            }catch (Exception e){
                e.printStackTrace();
            }
        }
        return modemsCurrentStates;
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
        ExecutorService exec = Executors.newFixedThreadPool(4);
        ArrayList<Future<MultiThreadedMeasurements>> futureResults = new ArrayList<>();
        for (Modem modem : modemsMeasurements) {
            futureResults.add(exec.submit(new MultiThreadModemMeasurementsReader(modem.getLinkToMAC(), userName, password)));
        }
        exec.shutdown();
        for (Future<MultiThreadedMeasurements> measurementList : futureResults) {

            try {
                modemsMeasurements.
                        get(findIndexOfModem(modemsMeasurements, measurementList
                                .get()
                                .getLinkToMAC()))
                        .setMeasurements(
                                measurementList
                                        .get()
                                        .getListOfMeasurements());
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        isMeasurementsNull(modemsMeasurements);

        return modemsMeasurements;
    }

    // we will not apply the sorting, we will check every time
    private int findIndexOfModem(List<Modem> modems, String linkToMAC) {
        for (Modem modem : modems) {
            if (modem.getLinkToMAC().equals(linkToMAC)) {
                return modems.indexOf(modem);
            }
        }

        // NullPointerException will be thrown
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
