package ua.sda.readers;

import sun.misc.BASE64Encoder;
import ua.sda.cleaners.CleanerForModemLocation;
import ua.sda.entity.opticalnodeinterface.ModemLocation;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * **
 * Parses HTML Info page for a ModemLocation
 *
 * @author Vasiliy Kylik on(Rocket) on 18.03.2018.
 * @return {@code modemLocation} ModemLocation;
 */
public class ModemLocationReader {

	/**
	 * **
	 * Parses HTML Info page for a ModemLocation
	 *
	 * @return {@code modemLocation} ModemLocation;
	 */
	public ModemLocation readModemLocation(String linkToInfoPage, String userName, String password) throws IOException {


		URL url = new URL(linkToInfoPage);
		HttpURLConnection con = (HttpURLConnection) url.openConnection();

		con.setRequestMethod("GET");
		con.setDoInput(true);

		byte[] encodedPassword = (userName + ":" + password).getBytes();
		BASE64Encoder encoder = new BASE64Encoder();
		con.setRequestProperty("Authorization",
				"Basic " + encoder.encode(encodedPassword));

		ModemLocation modemLocation = new ModemLocation();
		try (BufferedReader in = new BufferedReader(
				new InputStreamReader(con.getInputStream(), "koi8_u"))) {

			Integer entranceNumber = 0;
			Integer floorNumber = 0;
			Integer interFloorLineNumber = 0;
			String apartment = null;

			String inputLine;
			String htmlLineWithInfoTable = null;
			List<String> tableRowsForInfo = new ArrayList<>();

			while ((inputLine = in.readLine()) != null) {
				if (inputLine.matches("</form></center><div align=\"right\"><hr></div>.*")) {
					htmlLineWithInfoTable = CleanerForModemLocation.htmlLineWithInfoTableCleaning(inputLine);
				}
			}
			if (htmlLineWithInfoTable != null) {
				tableRowsForInfo.addAll(Arrays.asList(htmlLineWithInfoTable.split("td")));
			}
			// tableRowsForInfo.get(3) - location ">5 - 2 - 2</";
			// tableRowsForInfo.get(11) - apartment  "><a href=\"?ACT=work.cubic_info&address_id=27098960&F=search_by_id\">168";

			modemLocation = CleanerForModemLocation.locationCleaning(tableRowsForInfo.get(3));
			modemLocation.setApartment(CleanerForModemLocation.apartmentNumberCleaning(tableRowsForInfo.get(11)));
		}
		return modemLocation;
	}
}
