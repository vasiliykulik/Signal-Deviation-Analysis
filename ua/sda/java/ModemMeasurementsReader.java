import entity.opticalnodeinterface.Address;
import entity.opticalnodeinterface.Measurement;
import entity.opticalnodeinterface.Modem;
import sun.misc.BASE64Encoder;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 *  The {@code ModemMeasurementsReader} class represents a dao
 *  to obtain Addresses with Links to modems.
 *  <p>
 *  This implementation uses a
 *  <p>
 *  URL and BASE64Encoder to create
 *  <p>
 *  HttpURLConnection to create
 *  <p>
 *  InputStreamReader to create
 *  <p>
 *  BufferedReader to read HTML lines
 *  @author Vasiliy Kylik on 13.07.2017.
 */
public class ModemMeasurementsReader {
    /**
     * Parses HTML page for a Measurements info to build a List of measurements
     * @param linkToURL link to single interface of Optical Node(s)
     * @param userName username to web interface
     * @param password password to web interface
     */
    public List<Measurement> getMeasurements(String linkToURL, String userName, String password) throws Exception {
        URL url = new URL(linkToURL);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();

        // set up url connection to get retrieve information back
        con.setRequestMethod("GET");
        con.setDoInput(true);

        // stuff the Authorization request header
        // пароль передаю енкодеру, коннекшену передаю енкодер, у коннекшена берем входной стрим и передаем
        // через StreamReader to BufferedReader
        byte[] encodedPassword = (userName + ":" + password).getBytes();
        BASE64Encoder encoder = new BASE64Encoder();
        con.setRequestProperty("Authorization",
                "Basic " + encoder.encode(encodedPassword));

        BufferedReader in = new BufferedReader(
                new InputStreamReader(con.getInputStream(), "koi8_r"));

        List<Measurement> measurements = new ArrayList<>();

        String inputLine;
        Date dateTime = new SimpleDateFormat( "dd-MM-yyyy HH:mm:ss" ).parse( "00-00-0000 00:00:00" );
        float usTXPower = 0;
        float usRXPower = 0;
        float usSNR = 0;
        float dsSNR = 0;
        float microReflex = 0;
        String linkToInfoPage = "";
        boolean isNewTime = false;
        boolean isNewUsTXPower = false;
        boolean isNewUsRXPower = false;
        boolean isNewUsSNR = false;
        boolean isNewDsSNR = false;
        boolean isNewMicroReflex = false;

        while ((inputLine = in.readLine()) != null)
        {
            if (inputLine.matches(".*query_string.*")) {
                dateTime = CleanerForParserMeasurementEntity.timeCleaning(inputLine);
                isNewTime = true;
            } else if (inputLine.matches(".*search_by_id\" target=\"BLANK\"><small>.*")) {
                usTXPower = CleanerForParserMeasurementEntity.usTXPowerCleaning(inputLine);
                isNewUsTXPower = true;
            } else if (inputLine.matches(".*act.measures_history.php\\?mac=.*")) {
                usRXPower = CleanerForParserMeasurementEntity.usRXPowerCleaning(inputLine);
                isNewUsRXPower = true;
            }else if(inputLine.matches("")){
                usSNR = CleanerForParserMeasurementEntity.usSNRCleaning(inputLine);
                isNewUsSNR = true;
            }else if(inputLine.matches("")){
                dsSNR = CleanerForParserMeasurementEntity.dsSNRCleaning(inputLine);
                isNewDsSNR = true;
            }else if (inputLine.matches("")){
                microReflex = CleanerForParserMeasurementEntity.microReflexCleaning(inputLine);
                isNewMicroReflex = true;
            }else if (inputLine.matches("")){
                linkToInfoPage = CleanerForParserMeasurementEntity.linkToInfoPageCleaning (inputLine);
            }

            if (isNewTime & isNewUsTXPower & isNewUsRXPower & isNewUsSNR &isNewDsSNR & isNewMicroReflex) {
                measurements.add(new Measurement(dateTime,usTXPower,usRXPower,usSNR,dsSNR,microReflex,linkToInfoPage));
                isNewMicroReflex = false;
            }
        }

        return measurements;
    }
}
