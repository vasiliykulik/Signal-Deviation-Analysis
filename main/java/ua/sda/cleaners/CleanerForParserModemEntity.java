package ua.sda.cleaners;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * The {@code CleanerForParserModemEntity} class represents a set of static methods
 * with engines that performs match operations
 * to extract the necessary information for creating data structure(s)
 * according to the business logic, for Modem entity.
 * <p>
 * This implementation uses a Pattern - Matcher bundle
 *
 * @author Vasiliy Kylik on 13.07.2017.
 */
public class CleanerForParserModemEntity {

	/**
	 * Cleans input line to get the street name for Modem entity
	 *
	 * @param inputLine the line that matches street name regex ".*query_string.*"
	 * @return the street name
	 */
	public static String streetCleaning(String inputLine) {
		String output = null;
		Pattern p = Pattern.compile("query_string=(.*)\" target=\"BLANK");
		Matcher m = p.matcher(inputLine);
		if (m.find()) {
			output = (m.group(1));
		}
		return output;

	}

	/**
	 * Cleans input line to get the house number for Modem entity
	 *
	 * @param inputLine the line that matches house number regex ".*search_by_id\" target=\"BLANK\"><small>.*"
	 * @return the house number
	 */
	public static String housesCleaning(String inputLine) {
		String output = null;
		Pattern p = Pattern.compile(" target=\"BLANK\"><small>(.*)</small></a>");
		Matcher m = p.matcher(inputLine);
		if (m.find()) {
			output = (m.group(1));
		}
		return output;
	}

	/**
	 * Cleans input line to get the link to measurements,
	 * can modify link to get the required measurement period for Modem entity
	 *
	 * @param inputLine the line that matches link to measurements regex ".*act.measures_history.php\\?mac=.*"
	 * @return the link to measurements
	 */
	public static String modemsCleaning(String inputLine) {
		String output = null;
		Pattern p = Pattern.compile("<a href=\"(.*)\" target=\"BLANK\" class=\"lnk\">");
		// Here i dont need to cut MAC address
		// take url
		// and change period=5 to period=30
		Matcher m = p.matcher(inputLine);
		if (m.find()) {
			output = (m.group(1));
		}
		// output = output.replace("period=5","period=30");
		return output;
	}
}