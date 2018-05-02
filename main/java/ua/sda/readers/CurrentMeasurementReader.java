package ua.sda.readers;

import sun.misc.BASE64Encoder;
import ua.sda.entity.opticalnodeinterface.Measurement;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Date;

import static ua.sda.cleaners.CleanerForCurrentState.cleanerForCurrentState;

/**
 * @author Vasiliy Kylik on(Rocket) on 18.03.2018.
 */

/**
 * Parses HTML page for a CurrentState measurement
 *
 * @return {@code measurement }measurement of current state;
 * <br>{@code} new DateTime
 * 124 line - usTXPower
 * 128 line - usRXPower
 * 132 line - usSNR
 * 136 line - dsRxPower
 * 140 line - dsSNR
 * 144 line - microReflex
 * null linkToCurrentState
 * null linkToInfoPage
 * in.lines().count() (230 - offline, 237,223 - online, 78 - modem not found, 246 - not found)
 */
public class CurrentMeasurementReader {
	/**
	 * Parses HTML page for a CurrentState measurement
	 * <br>{@code} new DateTime
	 * <br> 124 line - usTXPower
	 * <br> 128 line - usRXPower
	 * <br> 132 line - usSNR
	 * <br> 136 line - dsRxPower
	 * <br> 140 line - dsSNR
	 * <br> 144 line - microReflex
	 * <br> null linkToCurrentState
	 * <br> null linkToInfoPage
	 * <br> preliminary in.lines().count() (230 - offline, 237,223 - online, 78 - modem not found, 246 - not found)
	 */

	public Measurement readCurrentState(String linkToCurrentState, String userName, String password, String linkToInfo) throws Exception {
		URL url = new URL(linkToCurrentState);
		HttpURLConnection con = (HttpURLConnection) url.openConnection();

		con.setRequestMethod("GET");
		con.setDoInput(true);

		byte[] encodedPassword = (userName + ":" + password).getBytes();
		BASE64Encoder encoder = new BASE64Encoder();
		con.setRequestProperty("Authorization",
				"Basic " + encoder.encode(encodedPassword));

		Measurement currentState = new Measurement();
		try (BufferedReader in = new BufferedReader(
				new InputStreamReader(con.getInputStream(), "koi8_u"))) {

			Float usTXPower = 0f;
			Float usRXPower = 0f;
			Float dsRxPower = 0f;
			Float usSNR = 0f;
			Float dsSNR = 0f;
			Float microReflex = 0f;

			String inputLine;
			String cleanLine;
			while ((inputLine = in.readLine()) != null) {
				if (inputLine.matches(".*<td bgcolor=\"#......\" colspan=\"2\">  Upstream TX Power </td>")) {
					cleanLine = in.readLine();
					currentState.setUsTXPower(cleanerForCurrentState(cleanLine));
				}
				if (inputLine.matches(".*<td bgcolor=\"#......\" colspan=\"2\">  Upstream RX Power, Iface PL </td>")) {
					cleanLine = in.readLine();
					currentState.setUsRXPower(cleanerForCurrentState(cleanLine));
				}
				// "            <td bgcolor="#EEEEE0" colspan="2">  Upstream SNR </td>" - должно сходится
				if (inputLine.matches(".*<td bgcolor=\"#......\" colspan=\"2\">  Upstream SNR </td>")) {
					cleanLine = in.readLine();
					currentState.setUsSNR(cleanerForCurrentState(cleanLine));
				}
				if (inputLine.matches(".*<td bgcolor=\"#......\" colspan=\"2\">  Downstream RX Power </td>")) {
					cleanLine = in.readLine();
					currentState.setDsRxPower(cleanerForCurrentState(cleanLine));
				}
				if (inputLine.matches(".*<td bgcolor=\"#......\" colspan=\"2\">  Downstream SNR </td>")) {
					cleanLine = in.readLine();
					currentState.setDsSNR(cleanerForCurrentState(cleanLine));
				}
				if (inputLine.matches(".*<td bgcolor=\"#......\" colspan=\"2\">  Micro Reflx </td>")) {
					cleanLine = in.readLine();
					currentState.setMicroReflex(cleanerForCurrentState(cleanLine));
				}
			}
			currentState.setLinkToCurrentState(linkToCurrentState);
			currentState.setLinkToInfoPage(linkToInfo);
			currentState.setDateTime(new Date());
		}
		return currentState;
	}
}

