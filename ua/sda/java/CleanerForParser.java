

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by Vasiliy Kylik on 13.07.2017.
 */
public class CleanerForParser {
  public static String streetCleaning(String inputLine){
    String output = null;
    Pattern p = Pattern.compile("query_string=(.*)\" target=\"BLANK");
    Matcher m = p.matcher(inputLine);
    if(m.find()){
      output = (m.group(1));
    }
    return output;
  }
  public static String housesCleaning(String inputLine){
    String output = null;
    Pattern p = Pattern.compile(" target=\"BLANK\"><small>(.*)</small></a>");
    Matcher m = p.matcher(inputLine);
    if(m.find()){
      output = (m.group(1));
    }
    return output;
  }
  public static String modemsCleaning(String inputLine){
    String output = null;
    Pattern p = Pattern.compile("<a href=\"(.*)\" target=\"BLANK\" class=\"lnk\">");
    // Here i dont need to cut MAC address
    // take url
    // and change period=5 to period=30
    Matcher m = p.matcher(inputLine);
    if(m.find()){
      output = (m.group(1));
    }
   // output = output.replace("period=5","period=30");
    return output;
  }
}