import entity.opticalnodeinterface.Measurement;
import sun.misc.BASE64Encoder;

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
public class ModemMeasurementsReader {
	/**
	 * Parses HTML page for a Measurements info to build a List of measurements
	 *
	 * @param linkToURL link to single interface of Optical Node(s)
	 * @param userName  username to web interface
	 * @param password  password to web interface
	 * @return {@code measurements }List of measurements for particularly taken modem;
	 * {@code isNewLinkToInfoPage} - parsed only ones, after that value only is assigned
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

		BufferedReader in = new BufferedReader(
				new InputStreamReader(con.getInputStream(), "koi8_r"));

		List<Measurement> measurements = new ArrayList<>();

		String inputLine;

		String htmlLineWithTable = null; // line with table
		List<String> tableRows = new ArrayList<>(); //
		boolean isNewTime = false;
		boolean isNewUsTXPower = false;
		boolean isNewUsRXPower = false;
		boolean isNewUsSNR = false;
		boolean isNewDsSNR = false;
		boolean isNewMicroReflex = false;
		boolean isNewLinkToInfoPage = false;

		// Take Html line with table of measurements to read one string table
		// ("align="center"><td>" - first row mark, start of row mark)
		// ("/a></td></tr>" - end of row mark)
		// ("<tr><td colspan="11" align="center">" - end of table mark)
		while ((inputLine = in.readLine()) != null) {
			if (inputLine.matches(".*align=\"center\"><td>.*")) {
				htmlLineWithTable = CleanerForParserMeasurementEntity.htmlLineCleaning(inputLine);
				// System.out.println(table);// test for Html line with table
			}
		}
		// cut HTML one line table into table row blocks and add to collection (List), implemented using array

		if (htmlLineWithTable != null) {
			tableRows.addAll(Arrays.asList(htmlLineWithTable.split("align=\"center\"><td>")));
			System.out.println(Arrays.asList(htmlLineWithTable.split("align=\"center\"><td>")));
			for(String ret:tableRows){
				System.out.println(ret);
			}
		}
		// TODO while taking each table row, pull required fields ( using Matcher.group 9 positions (two last (2,1) needs to be taken only once, it is links)), creating objects and placing into List
		for (String retval : tableRows) {
			measurements.add(CleanerForParserMeasurementEntity.measurementEntityCleaning(retval));
			//System.out.println(CleanerForParserMeasurementEntity.measurementEntityCleaning(retval));
		}
		// TODO check sorting by Date, sort if needed

		return measurements;
	}
}
