import entity.opticalnodeinterface.Address;
import entity.opticalnodeinterface.Link;
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
 * Created by Vasiliy Kylik on 22.01.2018.
 */
public class ModemMeasurementsReader {
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

        String inputLine;
        Date time;
        float usTXPower;
        float usRXPower;
        float usSNR;
        float dsSNR;
        float microReflex;
        List<Measurement> measurements = new ArrayList<>();
        Date date1 = new SimpleDateFormat( "dd-MM-yyyy HH:mm:ss" ).parse( "28-12-2016 12:04:03" );

        // and here i need matchers for Measurement fields
        boolean isNewStreet = false;
        boolean isNewHouse = false;
        boolean isNewLinkToModem = false;

        Map<Address, Set<Link>> interfaceModems = new HashMap<>();
        while ((inputLine = in.readLine()) != null)

        {
            if (inputLine.matches(".*query_string.*")) {
                street = CleanerForParser.streetCleaning(inputLine);
                isNewStreet = true;
            } else if (inputLine.matches(".*search_by_id\" target=\"BLANK\"><small>.*")) {
                houseNumber = CleanerForParser.housesCleaning(inputLine);
                isNewHouse = true;
            } else if (inputLine.matches(".*act.measures_history.php\\?mac=.*")) {
                linkToMAC = CleanerForParser.modemsCleaning(inputLine);
                isNewLinkToModem = true;
            }
            if (isNewStreet & isNewHouse & isNewLinkToModem) {
                modems.add(new Modem(street, houseNumber, linkToMAC));
                isNewLinkToModem = false;
                interfaceModems.put(new Address(street, houseNumber), null);
            }
        }


        return measurements;
    }
}
