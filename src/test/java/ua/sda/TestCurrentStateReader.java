package ua.sda;

import ua.sda.entity.opticalnodeinterface.Measurement;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.Date;

import static ua.sda.cleaners.CleanerForCurrentState.cleanerForCurrentState;

/**
 * Created by Vasiliy Kylik (Lightning) on 10.04.2018.
 */

/*Проверяем Reader и Cleaner (боевой) для Current State, файл с HTML кодом страницы*/
public class TestCurrentStateReader {
	public static void main(String[] args) throws Exception {
		FileReader fileReader = new FileReader("src\\test\\resources\\case_US_0_currentState.html");
		BufferedReader br = new BufferedReader(fileReader);

		Float usTXPower = 0f;
		Float usRXPower = 0f;
		Float dsRxPower = 0f;
		Float usSNR = 0f;
		Float dsSNR = 0f;
		Float microReflex = 0f;

		String linkToCurrentStateStub = "linkToCurrentStateStub";
		String linkToInfoStub = "linkToInfoStub";
		Measurement currentState = new Measurement();

		String inputLine;
		String cleanLine;
		while ((inputLine = br.readLine()) != null) {
			if (inputLine.matches(".*<td bgcolor=\"#......\" colspan=\"2\">  Upstream TX Power </td>")) {
				cleanLine = br.readLine();
				currentState.setUsTXPower(cleanerForCurrentState(cleanLine));
			}
			if (inputLine.matches(".*<td bgcolor=\"#......\" colspan=\"2\">  Upstream RX Power, Iface PL </td>")) {
				cleanLine = br.readLine();
				currentState.setUsRXPower(cleanerForCurrentState(cleanLine));
			}
			// "            <td bgcolor="#EEEEE0" colspan="2">  Upstream SNR </td>" - должно сходится
			if (inputLine.matches(".*<td bgcolor=\"#......\" colspan=\"2\">  Upstream SNR </td>")) {
				cleanLine = br.readLine();
				currentState.setUsSNR(cleanerForCurrentState(cleanLine));
			}
			if (inputLine.matches(".*<td bgcolor=\"#......\" colspan=\"2\">  Downstream RX Power </td>")) {
				cleanLine = br.readLine();
				currentState.setDsRxPower(cleanerForCurrentState(cleanLine));
			}
			if (inputLine.matches(".*<td bgcolor=\"#......\" colspan=\"2\">  Downstream SNR </td>")) {
				cleanLine = br.readLine();
				currentState.setDsSNR(cleanerForCurrentState(cleanLine));
			}
			if (inputLine.matches(".*<td bgcolor=\"#......\" colspan=\"2\">  Micro Reflx </td>")) {
				cleanLine = br.readLine();
				currentState.setMicroReflex(cleanerForCurrentState(cleanLine));
			}
		}
		currentState.setLinkToCurrentState(linkToCurrentStateStub);
		currentState.setLinkToInfoPage(linkToInfoStub);
		currentState.setDateTime(new Date());
		currentState.isNotNullMeasurement();
		System.out.println(currentState.isNotNullMeasurement() + " currentState.isNotNullMeasurement()");
		System.out.println(currentState);
	}
}
