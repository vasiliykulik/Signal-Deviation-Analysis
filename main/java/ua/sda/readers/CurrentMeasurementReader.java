package ua.sda.readers;

import sun.misc.BASE64Encoder;
import ua.sda.cleaners.CleanerForCurrentState;
import ua.sda.entity.opticalnodeinterface.Measurement;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Date;

import static ua.sda.cleaners.CleanerForCurrentState.cleanerForCurrentState;

/**
 * @author Vasiliy Kylik on(Rocket) on 18.03.2018.
 */
public class CurrentMeasurementReader {
	/**
	 * Parses HTML page for a CurrentState measurement
	 * @return {@code measurement }measurement of current state;
	 * new DateTime
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


	public Measurement readCurrentState(String linkToURL, String userName, String password) throws Exception {
		URL url = new URL(linkToURL);
		HttpURLConnection con = (HttpURLConnection) url.openConnection();

		con.setRequestMethod("GET");
		con.setDoInput(true);

		byte[] encodedPassword = (userName + ":" + password).getBytes();
		BASE64Encoder encoder = new BASE64Encoder();
		con.setRequestProperty("Authorization",
				"Basic " + encoder.encode(encodedPassword));

		Measurement currentState = new Measurement();
		try (BufferedReader in = new BufferedReader(
				new InputStreamReader(con.getInputStream(), "koi8_r"))) {

			Float usTXPower = 0f;
			Float usRXPower = 0f;
			Float dsRxPower = 0f;
			Float usSNR = 0f;
			Float dsSNR = 0f;
			Float microReflex = 0f;
			String inputLine;
			CleanerForCurrentState cleanerForCurrentState = new CleanerForCurrentState();
			// Получаем страницу, если модем онлайн (in.lines().count() == 238 - 1 || in.lines().count() == 224 - 1))
			// снимаем измерения
			// проверяем можем ли мы снять измерения (если нет бросаем exception)
			if (in.lines().count() != 238 - 1 || in.lines().count() != 224 - 1){
				throw new Exception("modem is not online");
			}
			while ((inputLine = in.readLine()) != null
					// && (in.lines().count() == 238 - 1 || in.lines().count() == 224 - 1)
					) {
				if (inputLine.matches("<td bgcolor=\"#......\" colspan=\"2\">  Upstream TX Power </td>")) {
					currentState.setUsTXPower (cleanerForCurrentState(in.readLine()));
				}
				if (inputLine.matches("<td bgcolor=\"#......\" colspan=\"2\">  Upstream RX Power, Iface PL </td>")) {
					currentState.setUsRXPower(cleanerForCurrentState(in.readLine()));
				}
				if (inputLine.matches("<td bgcolor=\"#......\" colspan=\"2\">  Upstream SNR </td>")) {
					currentState.setUsSNR(cleanerForCurrentState(in.readLine()));;
				}
				if (inputLine.matches("<td bgcolor=\"#......\" colspan=\"2\">  Downstream RX Power </td>")) {
					currentState.setUsRXPower (cleanerForCurrentState(in.readLine()));
				}
				if (inputLine.matches("<td bgcolor=\"#......\" colspan=\"2\">  Downstream SNR </td>")) {
					currentState.setDsSNR(cleanerForCurrentState(in.readLine()));
				}
				if (inputLine.matches("<td bgcolor=\"#......\" colspan=\"2\">  Micro Reflx </td>")) {
					currentState.setMicroReflex(cleanerForCurrentState(in.readLine()));
				}
			}
			currentState.setDateTime(new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse(String.valueOf(new Date())));

		}

		return currentState;
	}
}

