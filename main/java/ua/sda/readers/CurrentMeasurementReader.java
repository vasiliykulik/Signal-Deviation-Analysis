package ua.sda.readers;

import sun.misc.BASE64Encoder;
import ua.sda.cleaners.CleanerForCurrentState;
import ua.sda.entity.opticalnodeinterface.Measurement;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

import static ua.sda.cleaners.CleanerForCurrentState.cleanerForCurrentState;

/**
 * @author Vasiliy Kylik on(Rocket) on 18.03.2018.
 */
public class CurrentMeasurementReader {


	public Measurement readCurrentState(String linkToURL, String userName, String password) throws Exception {
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

		Measurement currentState = new Measurement();
		try (BufferedReader in = new BufferedReader(
				new InputStreamReader(con.getInputStream(), "koi8_r"))) {

			String inputLine;
			CleanerForCurrentState cleanerForCurrentState = new CleanerForCurrentState();
			while ((inputLine = in.readLine()) != null && (in.lines().count() == 238 - 1 || in.lines().count() == 224 - 1)) {
				if (inputLine.matches("<td bgcolor=\"#......\" colspan=\"2\">  Upstream TX Power </td>")) {
					Float usTXPower = cleanerForCurrentState(in.readLine());
				}
			}
		}
		return currentState;
	}
}

