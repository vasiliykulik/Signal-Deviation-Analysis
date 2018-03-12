import entity.opticalnodeinterface.Measurement;
import entity.opticalnodeinterface.Modem;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Vasiliy Kylik on 22.01.2018.
 */
public class Main {
	public static void main(String[] args) {

		// the virtual database is a web resource protected using BASIC HTTP Authentication
		final String urlString = args[0];
		final String userName = args[1];
		final String password = args[2];

		// Reading modems (street, houseNumber, linkToMAC) from "TrafficLight"
		List<Modem> modems = new ArrayList<Modem>();
		OpticalNodeSingleInterfaceReader opticalNodeSingleInterfaceReader = new OpticalNodeSingleInterfaceReader();
		try {
			modems = opticalNodeSingleInterfaceReader.getModemsUrls(urlString, userName, password);
		} catch (Exception e) {
			e.printStackTrace();
		}
		System.out.println(modems.toString());

		// Reading Measurements for each modem, adding List to List of List
		List<List<Measurement>> measurements = new ArrayList<>();
		ModemMeasurementsReader modemMeasurementsReader = new ModemMeasurementsReader();
		for (Modem modem : modems) {
			try {
				measurements.add(modemMeasurementsReader.getMeasurements(modem.getLinkToURL(), userName, password));
			} catch (Exception e) {
				e.printStackTrace();
			}

			for (List<Measurement> measurement : measurements) {
				System.out.println(measurement.toString());
			}
		}


	}
}
