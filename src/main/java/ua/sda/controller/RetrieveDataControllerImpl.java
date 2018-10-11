package ua.sda.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import ua.sda.entity.opticalnodeinterface.Measurement;
import ua.sda.entity.opticalnodeinterface.Modem;
import ua.sda.entity.opticalnodeinterface.ModemLocation;
import ua.sda.readers.CurrentMeasurementReader;
import ua.sda.readers.ModemLocationReader;
import ua.sda.readers.ModemMeasurementsReader;
import ua.sda.readers.OpticalNodeSingleInterfaceReader;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Vasiliy Kylik (Lightning) on 23.04.2018.
 */
public class RetrieveDataControllerImpl implements RetrieveDataController {
    private static final Logger LOGGER = LoggerFactory.getLogger(RetrieveDataControllerImpl.class);
    public List<Modem> getAll(String userName, String password, String urlString) {

        // the virtual database is a web resource protected using BASIC HTTP Authentication

        // Reading modems (street, houseNumber, linkToMAC) from "TrafficLight"
        List<Modem> modems = new ArrayList<>();
        OpticalNodeSingleInterfaceReader opticalNodeSingleInterfaceReader = new OpticalNodeSingleInterfaceReader();
        try {
            modems = opticalNodeSingleInterfaceReader.getModemsUrls(urlString, userName, password);
        } catch (Exception e) {
            e.printStackTrace();
        }
        //System.out.println(modems.toString());

        // Reading Measurements for each modem, adding List to List of List - old version
        // List<List<Measurement>> measurements = new ArrayList<>();
        // Reading Measurements for each modem, setting List<Measurements> as a field to the modem

        ModemMeasurementsReader modemMeasurementsReader = new ModemMeasurementsReader();
        int i = 0;
        for (Modem modem : modems) {
            try {
                modem.setMeasurements(modemMeasurementsReader.getMeasurements(modem.getLinkToMAC(), userName, password));
                System.out.println(modem.toString());
                // measurements for 1 modem of the 135 modems were taken
                System.out.println("measurements for " + i++ + " modem of the " + modems.size() + " modems were taken");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        CurrentMeasurementReader currentMeasurementReader = new CurrentMeasurementReader();
        // Read Current State Measurement, and add it to measurements
        int j = 0;
        int k = 0;
        for (Modem modem : modems) {
            Measurement currentStateMeasurement = new Measurement();
            try {
                currentStateMeasurement = currentMeasurementReader.readCurrentState(
                        modem.getMeasurements()
                                .get(0)
                                .getLinkToCurrentState(), userName, password, modem.getMeasurements()
                                .get(0)
                                .getLinkToInfoPage());
                if (currentStateMeasurement.isNotNullMeasurement()) {
                    modem.getMeasurements().add(0, currentStateMeasurement);
                    System.out.println("Current State  added " + k++);
                }
                System.out.println("Current state viewed " + j++);
            } catch (Exception e) {
                e.printStackTrace();
                System.out.println("(CurrentState exception) " + modem.getLinkToMAC());
                LOGGER.error("(CurrentState exception) " + modem.getLinkToMAC() + e);
                System.out.println(currentStateMeasurement);
                LOGGER.error("(CurrentState exception) " + currentStateMeasurement);
            }
        }

        ModemLocationReader modemLocationReader = new ModemLocationReader();
        for (Modem modem : modems) {
            try {
                ModemLocation modemLocation;
                modemLocation = modemLocationReader
                        .readModemLocation
                                (modem
                                        .getMeasurements()
                                        .get(0)
                                        .getLinkToInfoPage(),userName, password);
                if (modemLocation.isNotNullModemLocation()) {
                    modem.setModemLocation(modemLocation);
                    System.out.println(modemLocation);
                }
            } catch (Exception e) {
                e.printStackTrace();
                System.out.println("(LocationReader exception) " + modem.getLinkToMAC());
            }
        }
        return modems;
    }
}
