package ua.sda.cleaners;

import ua.sda.entity.opticalnodeinterface.Measurement;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * The {@code CleanerForParserMeasurementEntity} class represents a set of static methods
 * with engines that performs match operations
 * to extract the necessary information for creating data structure(s)
 * according to the business logic for Measurement entity.
 * <p>
 * This implementation uses a Pattern - Matcher bundle
 *
 * @author Vasiliy Kylik on 15.01.2018.
 */
public class CleanerForParserMeasurementEntity {

    /**
     * Cleans input line to get line with table from HTML
     *
     * @param inputLine the line that matches regex
     *                  ("align="center"><td>" - first and every row, first meeting of such mark uses as a table start,
     *                  start of row mark. This is necessary because the table is in one  html line )
     *                  ("<tr><td colspan="11" align="center">" - end of table mark)
     *                  after regex optimization change end of table mark to <tr><td colspan="11" align="center">
     * @return the time of measurement
     */
    public static String htmlLineCleaning(String inputLine) throws ParseException {
        String output = null;
        Pattern p = Pattern.compile("align=\"center\"><td>(.*)<tr><td colspan=\"11\" align=\"center\">");
        Matcher m = p.matcher(inputLine);
        if (m.find()) {
            output = m.group(1);
            //output = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse(m.group(1));
        }
        return output;
    }


    /**
     * Cleans input line to get the street name for Modem entity
     *
     * @param inputLine the line that matches Date (prefix to table row with date) regex "align="center"><td>"
     *                  (</td><td bgcolor= suffix )
     * @return the time of measurement
     */
    public static Date timeCleaning(String inputLine) throws ParseException {
        Date output = null;
        Pattern p = Pattern.compile("align=\"center\"><td>(.*)</td><td bgcolor=");
        Matcher m = p.matcher(inputLine);
        if (m.find()) {
            output = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse(m.group(1));
        }
        return output;
    }

    /**
     * Cleans input line to get the Measurement entity, optimized regex ()
     *
     * @param inputLine row of measurement table, one element of tableRows
     *                  field name, regex number, parameters name
     *                  <p>
     *                  <p>{@code dateTime} 1 - time
     *                  <p>{@code usTXPower} 2 - US Tx Power, dBmv
     *                  <p>{@code usRXPower} 3 - US Rx Power, dBmV
     *                  <p>{@code dsRxPower} 4 - DS Rx Power, dBmV
     *                  <p>{@code usSNR} 5 - US SNR, dB
     *                  <p>{@code dsSNR} 6 - DS SNR, dB
     *                  <p>{@code microReflex} 7 - Micro Reflx, dBc
     *                  <p>{@code linkToCurrentMeasurement} 8 - Link to Current Measurement Page
     *                  <p>{@code linkToInfoPage} 9 - Link to Info Page
     * @return the Measurement entity
     */
    public static Measurement measurementEntityCleaning(String inputLine) throws ParseException {

        Date dateTime = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse("00-00-0000 00:00:00");
        Float usTXPower = 0f;
        Float usRXPower = 0f;
        Float dsRxPower = 0f;
        Float usSNR = 0f;
        Float dsSNR = 0f;
        Float microReflex = 0f;
        String linkToCurrentMeasurement = null;
        String linkToInfoPage = null;
        // (tableRow - 16-03-2018 14:07:44</td>
        // <td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/modem/act.measures_history.php?mac=001DD3F6A317&period=5" onclick="initAd()">001D.D3F6.A317</a></td>
        // <td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/cmts_info/act.cmts_info.php?cmts=sub-20" onclick="initAd()">sub-20</a></td>
        // <td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-20&ifaces=51020,51030,51010,51000" onclick="initAd()">1001</a></td>
        // <td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-20&ifaces=5100--,5101--,5102--,5103--,5104--,5105--,5106--,5107--" onclick="initAd()">1</a></td>
        // <td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-20&iface=51030" onclick="initAd()">Us 5/1/0/3/0</a></td>
        // <td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-20&iface=5100--" onclick="initAd()">Ds 5100</a></td>
        // <td bgcolor="#8CFF40">47</td>
        // <td>7.5</td>
        // <td bgcolor="#8CFF40">32.3</td>
        // <td bgcolor="#8CFF40">1.6</td>
        // <td bgcolor="#8CFF40">37.3</td>
        // <td>31</td>
        // <td><font ><b>online</font></b></td>
        // <td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/modem/act.measures_online.php?mac=001DD3F6A317" >Сейчас</a></td>
        // <td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/?ACT=work.cubic&query_mac=001dd3f6a317" >Инфо</a></td></tr><tr bgcolor="#F0F0F0" )
        // unusable information between td tags changed to *, requred fields to (.*)
        // (.*)<.td><td.*<.td><td.*<.td><td.*<.td><td.*<.td><td.*<.td><td.*<.td><td.*>(.*)<.td><td>(.*)<.td><td.*>(.*)<.td><td.*>(.*)<.td><td.*>(.*)<.td><td>(.*)<.td><td>.*><a href=\"(.*)\".*<.td><td.*<a href=\"(.*)\".*"
       // System.out.println("inputline from cleaner");
       // System.out.println(inputLine);
        Pattern p = Pattern.compile("" +
                "(\\d\\d-\\d\\d-\\d\\d\\d\\d\\s\\d\\d:\\d\\d:\\d\\d)</td>.*" +
                "<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
                "<td>([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
                "<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
                "<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
                "<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
                "<td>([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
                "<td><font ><b>.*</font></b></td>" +
                "<td bgcolor=\"#......\"><a href=\\\"(https:\\/\\/work.volia.com\\/w2\\/work\\/modem\\/act.measures_online.php\\?mac=............)\" >.*</a></td>" +
                "<td bgcolor=\"#......\"><a href=\\\"(https:\\/\\/work.volia.com\\/w2\\/\\?ACT=work.cubic&query_mac=............).*");// " >Инфо</a></td></tr><tr bgcolor="#......" wildcard instead this statement because last row have no end marker as previous rows
        Matcher m = p.matcher(inputLine);
        if (m.find()) {
            dateTime = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse(m.group(1));
            usTXPower = Float.valueOf(m.group(2));
            usRXPower = Float.valueOf(m.group(3));
            usSNR = Float.valueOf(m.group(4));
            dsRxPower = Float.valueOf(m.group(5));
            dsSNR = Float.valueOf(m.group(6));
            microReflex = Float.valueOf(m.group(7));
            linkToCurrentMeasurement = m.group(8);
            linkToInfoPage = m.group(9);
        }
        Measurement measurement = new Measurement(dateTime, usTXPower, usRXPower, usSNR, dsRxPower, dsSNR, microReflex, linkToCurrentMeasurement, linkToInfoPage);
      //  System.out.println(measurement.toString());
        return measurement;
    }

    public static Measurement measurementEntityCleaningWithLinks(String inputLine, String linkToCurrentMeasurement, String linkToInfoPage) throws ParseException {

        Date dateTime = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse("00-00-0000 00:00:00");
        Float usTXPower = 0f;
        Float usRXPower = 0f;
        Float dsRxPower = 0f;
        Float usSNR = 0f;
        Float dsSNR = 0f;
        Float microReflex = 0f;
        // (tableRow - 16-03-2018 14:07:44</td>
        // <td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/modem/act.measures_history.php?mac=001DD3F6A317&period=5" onclick="initAd()">001D.D3F6.A317</a></td>
        // <td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/cmts_info/act.cmts_info.php?cmts=sub-20" onclick="initAd()">sub-20</a></td>
        // <td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-20&ifaces=51020,51030,51010,51000" onclick="initAd()">1001</a></td>
        // <td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/cable_info/act.mrtg_graphs_new.php?cmts=sub-20&ifaces=5100--,5101--,5102--,5103--,5104--,5105--,5106--,5107--" onclick="initAd()">1</a></td>
        // <td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-20&iface=51030" onclick="initAd()">Us 5/1/0/3/0</a></td>
        // <td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/cable_info/act.iface_info.php?cmts=sub-20&iface=5100--" onclick="initAd()">Ds 5100</a></td>
        // <td bgcolor="#8CFF40">47</td>
        // <td>7.5</td>
        // <td bgcolor="#8CFF40">32.3</td>
        // <td bgcolor="#8CFF40">1.6</td>
        // <td bgcolor="#8CFF40">37.3</td>
        // <td>31</td>
        // <td><font ><b>online</font></b></td>
        // <td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/work/modem/act.measures_online.php?mac=001DD3F6A317" >Сейчас</a></td>
        // <td bgcolor="#D8D8D8"><a href="http://work.volia.net/w2/?ACT=work.cubic&query_mac=001dd3f6a317" >Инфо</a></td></tr><tr bgcolor="#F0F0F0" )
        // unusable information between td tags changed to *, requred fields to (.*)
        // (.*)<.td><td.*<.td><td.*<.td><td.*<.td><td.*<.td><td.*<.td><td.*<.td><td.*>(.*)<.td><td>(.*)<.td><td.*>(.*)<.td><td.*>(.*)<.td><td.*>(.*)<.td><td>(.*)<.td><td>.*><a href=\"(.*)\".*<.td><td.*<a href=\"(.*)\".*"
        Pattern p = Pattern.compile("" +
                "(\\d\\d-\\d\\d-\\d\\d\\d\\d\\s\\d\\d:\\d\\d:\\d\\d)</td>.*" +
                "<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
                "<td>([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
                "<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
                "<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
                "<td bgcolor=\"#......\">([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d)</td>" +
                "<td>([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d).*");
        Matcher m = p.matcher(inputLine);
        if (m.find()) {
            dateTime = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse(m.group(1));
            usTXPower = Float.valueOf(m.group(2));
            usRXPower = Float.valueOf(m.group(3));
            usSNR = Float.valueOf(m.group(4));
            dsRxPower = Float.valueOf(m.group(5));
            dsSNR = Float.valueOf(m.group(6));
            microReflex = Float.valueOf(m.group(7));
        }
        return new Measurement(dateTime, usTXPower, usRXPower, usSNR, dsRxPower, dsSNR, microReflex, linkToCurrentMeasurement, linkToInfoPage);
    }
}