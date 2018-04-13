package ua.sda.cleaners;

import ua.sda.entity.opticalnodeinterface.ModemLocation;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author Vasiliy Kylik on(Rocket) on 12.04.2018.
 */
public class CleanerForModemLocation {

    public static String htmlLineWithInfoTableCleaning(String inputLine) {
        String output = null;
        Pattern p = Pattern.compile("</form></center><div align=\"right\"><hr></div>(.*)</a></td><td><div id");
        Matcher m = p.matcher(inputLine);
        if (m.find()) {
            output = m.group(1);
            //output = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse(m.group(1));
        }
        return output;
    }


    public static String apartmentNumberCleaning(String s) {

        String value = null;
        Pattern p = Pattern.compile("><a href=\"\\?ACT=work.cubic_info&address_id=.*=search_by_id\">(.*)");
        Matcher m = p.matcher(s);
        if (m.find()) {
            value = m.group(1);
            //output = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse(m.group(1));
        }
        return value;
    }

    public static ModemLocation locationCleaning(String s) {

        Integer entranceNumber = 0;
        Integer floorNumber = 0;
        Integer interFloorLineNumber = 0;
        // ">5 - 2 - 2</"
        // one or two, positive or negative value. don't forget about spaces
        Pattern p = Pattern.compile(">([0-9][0-9]|[0-9]|-[0-9][0-9]|-[0-9]) - " +
                "([0-9][0-9]|[0-9]|-[0-9][0-9]|-[0-9]) - " +
                "([0-9][0-9]|[0-9]|-[0-9][0-9]|-[0-9])</");
        Matcher m = p.matcher(s);
        if (m.find()) {
            entranceNumber = Integer.valueOf(m.group(1));
            floorNumber = Integer.valueOf(m.group(2));
            interFloorLineNumber = Integer.valueOf(m.group(3));
        }
        return new ModemLocation(entranceNumber, floorNumber, interFloorLineNumber, null);
    }
}
