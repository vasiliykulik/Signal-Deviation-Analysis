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

        // Take Html line with table of measurements to read one string table
        // ("align="center"><td>" - first row mark, start of row mark)
        // ("/a></td></tr>" - end of row mark)
        // ("<tr><td colspan="11" align="center">" - end of table mark)
        while ((inputLine = in.readLine()) != null) {
            if (inputLine.matches(".*align=\"center\"><td>.*")) {
                htmlLineWithTable = CleanerForParserMeasurementEntity.htmlLineCleaning(inputLine);
                // System.out.println(htmlLineWithTable);// test for Html line with table
            }
        }
        // cut HTML one line table into table row blocks and add to collection (List), implemented using array

        if (htmlLineWithTable != null) {
            tableRows.addAll(Arrays.asList(htmlLineWithTable.split("align=\"center\"><td>")));
        }

        // while taking each table row, 9 zone regex (two last (1,2) needs to be taken only once, it is links)), creating objects and placing into List
        // also checking for a 0 measurements
        boolean isNewLinkToCurrentMeasurement = false;
        boolean isNewLinkToInfoPage = false;
        for (String retval : tableRows) {
            if (!isNewLinkToCurrentMeasurement & !isNewLinkToInfoPage) {
                //  check for empty cells in measurements columns

                Measurement measurement = CleanerForParserMeasurementEntity.measurementEntityCleaning(retval);
                // after adding List<Measurements> to Modem entity, it may be a case of not reading measurements- and this field will remain null
                // but the expected behavior is skipping one measurement from the list
                measurements.add(measurement);
                isNewLinkToCurrentMeasurement = true;
                isNewLinkToInfoPage = true;

            }
            // case if first measurement not valid - so "measurements.get(0)" cause exception IndexOutOfBoundsException
            // (check isNewLinkToCurrentMeasurement & isNewLinkToInfoPage flags) make sure that we have 0 index (first element in Collection)
            if (isNewLinkToCurrentMeasurement & isNewLinkToInfoPage & measurements.size() > 0) {
                //  check for empty cells in measurements columns (color marker when cells are not empty)
                if (measurements.get(0).getLinkToCurrentState() != null & measurements.get(0).getLinkToInfoPage() != null) {
                    Measurement measurement = CleanerForParserMeasurementEntity.
                            measurementEntityCleaningWithLinks(retval, measurements.get(0).getLinkToCurrentState(), measurements.get(0).getLinkToInfoPage());
                    measurements.add(measurement);
                }
            }
        }

        // check sorting by Date, sort if needed
        measurements.sort(new ComparatorMeasurement());
        return measurements;
    }
}
