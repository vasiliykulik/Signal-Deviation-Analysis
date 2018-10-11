package ua.sda.readers;

import sun.misc.BASE64Encoder;
import ua.sda.cleaners.CleanerForParserMeasurementEntity;
import ua.sda.comparators.ComparatorMeasurement;
import ua.sda.entity.opticalnodeinterface.Measurement;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

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
public class ModemMeasurementsReader implements MeasurementsReader {
	/**
	 * Parses HTML page for a Measurements info to build a List of measurements
	 *
	 * @param linkToURL link to single interface of Optical Node(s)
	 * @param userName  username to web interface
	 * @param password  password to web interface
	 * @return {@code measurements }List of measurements for particularly taken modem;
	 * <br>{@code isNewLinkToInfoPage} - parsed only ones, after that value only is assigned
	 * <br>{@code htmlLineWithTable} -  htmlLineWithTable through regex from html page. Take Html line with table of measurements to read one string table.
	 * <br>{@code tableRows} -  cut HTML one line table into table row blocks and add to collection (List), implemented using array

	 */
	public List<Measurement> getMeasurements(String linkToURL, String userName, String password) throws Exception {
		URL url = new URL(linkToURL);
		HttpURLConnection con = (HttpURLConnection) url.openConnection();

		// set up url connection to get retrieve information back
		con.setRequestMethod("GET");
		con.setDoInput(true);

		// stuff the Authorization request header
		// the password to the encoder, encoder to the connection, StreamReader take InputStream from connection and to the BufferedReader
		byte[] encodedPassword = (userName + ":" + password).getBytes();
		BASE64Encoder encoder = new BASE64Encoder();
		con.setRequestProperty("Authorization",
				"Basic " + encoder.encode(encodedPassword));

		try (BufferedReader in = new BufferedReader(
				new InputStreamReader(con.getInputStream(), "koi8_u"))) {

			List<Measurement> measurements = new ArrayList<>();

			String inputLine;

			String htmlLineWithTable = null; // line with table
			List<String> tableRows = new ArrayList<>(); //

			// ("align="center"><td>" - first row mark, start of row mark)
			// ("/a></td></tr>" - end of row mark)
			// ("<tr><td colspan="11" align="center">" - end of table mark)
			while ((inputLine = in.readLine()) != null) {
				if (inputLine.matches(".*align=\"center\"><td>.*")) {
					htmlLineWithTable = CleanerForParserMeasurementEntity.htmlLineCleaning(inputLine);
				}
			}

			if (htmlLineWithTable != null) {
				tableRows.addAll(Arrays.asList(htmlLineWithTable.split("align=\"center\"><td>")));
			}

			// while taking each table row, 9 zone regex (two last (1,2) needs to be taken only once, it is links)), creating objects and placing into List
			// also checking for a 0 measurements
			// retval -
			boolean isNewLinkToCurrentMeasurement = false;
			boolean isNewLinkToInfoPage = false;
			for (String retval : tableRows) {
				if (!isNewLinkToCurrentMeasurement & !isNewLinkToInfoPage) {
					Measurement measurement = CleanerForParserMeasurementEntity.measurementEntityCleaning(retval);
					if (measurement.isNotNullMeasurement()) {
						measurements.add(measurement);
					}
					if (measurement.getLinkToCurrentState() != null & measurement.getLinkToInfoPage() != null & measurement.isNotNullMeasurement()) {
						isNewLinkToCurrentMeasurement = true;
						isNewLinkToInfoPage = true;
						continue;
					}

				}
				// case if first measurement not valid - so "measurements.get(0)" cause exception IndexOutOfBoundsException
				// (check isNewLinkToCurrentMeasurement & isNewLinkToInfoPage flags) make sure that we have 0 index (first element in Collection)
				if (isNewLinkToCurrentMeasurement & isNewLinkToInfoPage & measurements.size() > 0) {
					if (measurements.get(0).getLinkToCurrentState() != null & measurements.get(0).getLinkToInfoPage() != null) {
						Measurement measurement = CleanerForParserMeasurementEntity.
								measurementEntityCleaningWithLinks(retval, measurements.get(0).getLinkToCurrentState(), measurements.get(0).getLinkToInfoPage());
						if (measurement.isNotNullMeasurement()) {
							measurements.add(measurement);
						}
					}
				}
			}

			// check sorting by Date, sort if needed
			measurements.sort(new ComparatorMeasurement());
			return measurements;
		}
	}
}
