

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
}