import entity.opticalnodeinterface.Modem;
import readers.ModemMeasurementsReader;
import readers.OpticalNodeSingleInterfaceReader;

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
				System.out.println(i++);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		for (Modem eachModem : modems) {
			System.out.println(eachModem.toString());
		}

/*		for (List<Measurement> measurement : measurements) {
			CurrentMeasurementReader currentMeasurementReader = CurrentMeasurementReader();
			LocationReader locationReader = LocationReader();

			measurement.get(0).getLinkToCurrentState();
			measurement.get(0).getLinkToInfoPage();
		}*/
// TODO
	}
}
