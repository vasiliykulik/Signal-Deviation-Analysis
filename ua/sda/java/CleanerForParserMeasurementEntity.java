

import java.util.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *  The {@code CleanerForParserMeasurementEntity} class represents a set of static methods
 *  with engines that performs match operations
 *  to extract the necessary information for creating data structure(s)
 *  according to the business logic for Measurement entity.
 *  <p>
 *  This implementation uses a Pattern - Matcher bundle
 *  @author Vasiliy Kylik on 15.01.2018.
 */
public class CleanerForParserMeasurementEntity {
    /**
     * Cleans input line to get the street name for Modem entity
     * @param  inputLine the line that matches street name regex ".*query_string.*"
     * @return the street name
     */
  public static Date timeCleaning(String inputLine) {
      String output = null;
      Pattern p = Pattern.compile("query_string=(.*)\" target=\"BLANK");
      Matcher m = p.matcher(inputLine);
      if(m.find()){
          output = (m.group(1));
      }
      return output;
  }

  public static float usTXPowerCleaning(String inputLine) {
    return 0;
  }

  public static float usRXPowerCleaning(String inputLine) {
  }


  public static float usSNRCleaning(String inputLine) {
  }

  public static float dsSNRCleaning(String inputLine) {
  }

  public static float microReflexCleaning(String inputLine) {
    return 0;
  }

  public static String linkToInfoPageCleaning(String inputLine) {
    return null;
  }
}