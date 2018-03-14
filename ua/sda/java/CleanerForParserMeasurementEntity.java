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
     * @return the time of measurement
     */
    public static String htmlLineCleaning(String inputLine) throws ParseException {
        String output = null;
        Pattern p = Pattern.compile("align=\"center\"><td>(.*)</td><td bgcolor=");
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
}