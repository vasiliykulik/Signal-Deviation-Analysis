package ua.sda.controllerdao;

import ua.sda.entity.opticalnodeinterface.ModemDifferenceMeasurement;

import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

/**
 * @author Vasiliy Kylik on(Rocket) on 03.07.2018.
 */
public class SaveToFileController {
  public void writeToTxt(List<ModemDifferenceMeasurement> modems) {
    List<String> lines = new ArrayList<>();
    // TODO House number might be with slash, replace \ or / onto "slash"
    Path file = Paths.get("result " + modems.get(0).getStreet() //+ " " + modems.get(0).getHouseNumber()
             +".txt");
    for (ModemDifferenceMeasurement modem:modems){
      lines.add(modem.toStringToTxtFile());
    }
    try {
      Files.write(file,lines, Charset.forName("UTF-8"));
      System.out.println("File Saved Successfully " + file);
    } catch (IOException e) {
      System.out.println("Failed to save File" + e);
    }
  }
}
