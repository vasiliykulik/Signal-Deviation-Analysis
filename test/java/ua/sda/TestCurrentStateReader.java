package ua.sda;

import ua.sda.entity.opticalnodeinterface.Measurement;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.nio.Buffer;
import java.text.SimpleDateFormat;
import java.util.Date;

import static ua.sda.cleaners.CleanerForCurrentState.cleanerForCurrentState;

/**
 * Created by Vasiliy Kylik (Lightning) on 10.04.2018.
 */
public class TestCurrentStateReader {
    public static void main(String[] args) throws Exception {
        FileReader fileReader = new FileReader("C:\\Users\\Молния\\IdeaProjects\\Signal-Deviation-Analysis\\test\\resources\\CurrentState.html");
        BufferedReader br = new BufferedReader(fileReader);

        Float usTXPower = 0f;
        Float usRXPower = 0f;
        Float dsRxPower = 0f;
        Float usSNR = 0f;
        Float dsSNR = 0f;
        Float microReflex = 0f;
        String inputLine;
        String linkToCurrentStateStub = "linkToCurrentStateStub";
        String linkToInfoStub = "linkToInfoStub";
        Measurement currentState = new Measurement();

        if (br.lines().count() != 238 - 1 || br.lines().count() != 224 - 1){
            throw new Exception("modem is not online");
        }
        while ((inputLine = br.readLine()) != null
            // && (br.lines().count() == 238 - 1 || br.lines().count() == 224 - 1)
                ) {
            if (inputLine.matches("<td bgcolor=\"#......\" colspan=\"2\">  Upstream TX Power </td>")) {
                currentState.setUsTXPower (cleanerForCurrentState(br.readLine()));
            }
            if (inputLine.matches("<td bgcolor=\"#......\" colspan=\"2\">  Upstream RX Power, Iface PL </td>")) {
                currentState.setUsRXPower(cleanerForCurrentState(br.readLine()));
            }
            if (inputLine.matches("<td bgcolor=\"#......\" colspan=\"2\">  Upstream SNR </td>")) {
                currentState.setUsSNR(cleanerForCurrentState(br.readLine()));;
            }
            if (inputLine.matches("<td bgcolor=\"#......\" colspan=\"2\">  Downstream RX Power </td>")) {
                currentState.setUsRXPower (cleanerForCurrentState(br.readLine()));
            }
            if (inputLine.matches("<td bgcolor=\"#......\" colspan=\"2\">  Downstream SNR </td>")) {
                currentState.setDsSNR(cleanerForCurrentState(br.readLine()));
            }
            if (inputLine.matches("<td bgcolor=\"#......\" colspan=\"2\">  Micro Reflx </td>")) {
                currentState.setMicroReflex(cleanerForCurrentState(br.readLine()));
            }
        }
        currentState.setLinkToCurrentState(linkToCurrentStateStub);
        currentState.setLinkToInfoPage(linkToInfoStub);
        currentState.setDateTime(new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse(String.valueOf(new Date())));

    }
}
