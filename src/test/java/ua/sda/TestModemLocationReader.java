package ua.sda;

import ua.sda.cleaners.CleanerForModemLocation;
import ua.sda.entity.opticalnodeinterface.ModemLocation;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * @author Vasiliy Kylik on(Rocket) on 12.04.2018.
 */
/*Проверяем Reader с боевым Cleaner для Location,  подаем файл с HTML кодом страницы*/
public class TestModemLocationReader {
    public static void main(String[] args) throws IOException {

        FileReader fileReader = new FileReader("src\\test\\resources\\infoPageTest03.09.2018.html");
        BufferedReader br = new BufferedReader(fileReader);

        ModemLocation modemLocation = new ModemLocation();


        Integer entranceNumber = 0;
        Integer floorNumber = 0;
        Integer interFloorLineNumber = 0;
        String apartment = null;

        String inputLine;
        String htmlLineWithInfoTable = null;
        List<String> tableRowsForInfo = new ArrayList<>();

        while ((inputLine = br.readLine()) != null) {
            if (inputLine.matches(".*</form></center><div align=\"right\"><hr></div>.*")) {
                htmlLineWithInfoTable = CleanerForModemLocation.htmlLineWithInfoTableCleaning(inputLine);
            }
        }
        if (htmlLineWithInfoTable != null) {
            tableRowsForInfo.addAll(Arrays.asList(htmlLineWithInfoTable.split("td")));
        }
        int i = 0;
        for (String tdRow : tableRowsForInfo) {
            System.out.println(tdRow);
            System.out.println(i + " block");
            i++;
        }
        //modemLocation.setEntranceNumber(Character.getNumericValue(tableRowsForInfo.get(3).charAt(1)));
        //modemLocation.setFloorNumber (Character.getNumericValue(tableRowsForInfo.get(3).charAt(5)));
        //modemLocation.setInterFloorLineNumber(Character.getNumericValue(tableRowsForInfo.get(3).charAt(9)));
        modemLocation = CleanerForModemLocation.locationCleaning(tableRowsForInfo.get(3));
        modemLocation.setApartment(CleanerForModemLocation.apartmentNumberCleaning(tableRowsForInfo.get(11)));
        System.out.println(modemLocation.getEntranceNumber());
        System.out.println(modemLocation.getFloorNumber());
        System.out.println(modemLocation.getInterFloorLineNumber());
        System.out.println(modemLocation.getApartment());
    }
}
