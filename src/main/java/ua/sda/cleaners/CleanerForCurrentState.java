package ua.sda.cleaners;

import java.text.ParseException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author Vasiliy Kylik on(Rocket) on 06.04.2018.
 */
public class CleanerForCurrentState {
	/**
	 * Parses HTML page for a Measurements info to build a List of measurements
	 *
	 * @return {@code value} Float, cleaned value
	 * {@code p1} - pattern takes into account and has filters second value in one cell such as Iface PL
	 */
	public static Float cleanerForCurrentState(String strWithValue) throws ParseException {
		Float value = 0f;
		Pattern p1 = Pattern.compile("<td bgcolor=\".*\" align=\"center\"> <font  > ([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d).*<\\/font> <\\/td>");// " >Инфо</a></td></tr><tr bgcolor="#......" wildcard instead this statement because last row have no end marker as previous rows
		Matcher m = p1.matcher(strWithValue);
		if (m.find()) {
			value = Float.valueOf(m.group(1));
		}
		return value;}
}
