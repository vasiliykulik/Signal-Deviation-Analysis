package ua.sda.cleaners;

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
}
