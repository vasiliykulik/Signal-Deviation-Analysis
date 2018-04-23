package ua.sda;


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
 * Created by Vasiliy Kylik on 22.01.2018.
 */
public class Main {
	public static void main(String[] args) {

		// the virtual database is a web resource protected using BASIC HTTP Authentication

		final String userName = args[0];
		final String password = args[1];
		final String urlString = args[2];

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
				System.out.println("measurements for " + i++ + " were taken");
			} catch (Exception e) {
				e.printStackTrace();

			}
		}

		CurrentMeasurementReader currentMeasurementReader = new CurrentMeasurementReader();
		// Read Current State Measurement, and add it to measurements
		int j = 0;
		int k = 0;
		for (Modem modem : modems) {
			try {
				Measurement currentStateMeasurement = new Measurement();
				currentStateMeasurement = currentMeasurementReader.readCurrentState(
						modem.getMeasurements().get(0).getLinkToCurrentState(), userName, password, modem.getMeasurements().get(0).getLinkToInfoPage());
				if (currentStateMeasurement.isNotNullMeasurement()) {
					modem.getMeasurements().add(0, currentStateMeasurement);
					System.out.println("Current State added " + k++);
				}
				System.out.println("Current state Viewed " + j++);
			} catch (Exception e) {
				e.printStackTrace();
				System.out.println("(CurrentState exception) " + modem.getLinkToMAC());
			}
		}

		ModemLocationReader modemLocationReader = new ModemLocationReader();
		for (Modem modem : modems) {
			try {
				ModemLocation modemLocation = new ModemLocation();
				modemLocation = modemLocationReader.readModemLocation(modem.getMeasurements().get(0).getLinkToInfoPage(), userName, password);
				if (modemLocation.isNotNullModemLocation()) {
					modem.setModemLocation(modemLocation);
					System.out.println(modemLocation);
				}
			} catch (Exception e) {
				e.printStackTrace();
				System.out.println("(LocationReader exception) " + modem.getLinkToMAC());
			}
		}
// TODO
	}
}
