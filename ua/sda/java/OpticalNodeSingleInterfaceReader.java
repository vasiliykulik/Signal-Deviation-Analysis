

import entity.opticalnodeinterface.Address;
import entity.opticalnodeinterface.Link;
import entity.opticalnodeinterface.Modem;
import sun.misc.BASE64Encoder;

import java.net.*;
import java.io.*;
import java.util.*;

/**
 *  The {@code OpticalNodeSingleInterfaceReader} class represents a dao
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
public class OpticalNodeSingleInterfaceReader {
    /**
     * Parses HTML page for a "TrafficLight" info to build a List of Modems
     * @param urlString link to single interface of Optical Node(s)
     * @param userName username to web interface
     * @param password password to web interface
     */
    public List<Modem> getModemsUrls(String urlString, String userName, String password) throws Exception {

        // open url connection
        URL url = new URL(urlString);
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
        String street = "";
        String houseNumber = "";
        String linkToMAC = "";
        List<Modem> modems = new ArrayList<>();

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

        for (
                Address key : interfaceModems.keySet())

        {
            Set<Link> links = new HashSet<>();
            for (Modem modem : modems) {
                if (modem.getStreet().equals(key.getStreet()) & modem.getHouseNumber().equals(key.getHouseNumber())) {
                    links.add(new Link(modem.getLinkToURL()));
                }
            }
            interfaceModems.put(key, links);
        }
        in.close();
        return modems;
    }
}