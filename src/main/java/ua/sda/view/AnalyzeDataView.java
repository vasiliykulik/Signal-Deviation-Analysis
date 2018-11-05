package ua.sda.view;

import org.hibernate.service.spi.ServiceException;
import ua.sda.controller.AnalyzeDataController;
import ua.sda.controllerdao.ModemDAOControllerImpl;
import ua.sda.controllerdao.SaveToFileController;
import ua.sda.entity.opticalnodeinterface.Modem;
import ua.sda.entity.opticalnodeinterface.ModemDifferenceMeasurement;
import ua.sda.view.helper.ConsoleHelper;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import static ua.sda.storage.Storage.storageForModems;
import static ua.sda.view.helper.ConsoleHelper.readInt;
import static ua.sda.view.helper.ConsoleHelper.readString;
import static ua.sda.view.helper.ConsoleHelper.writeMessage;

/**
 * Created by Vasiliy Kylik (Lightning) on 23.04.2018.
 */
public class AnalyzeDataView {
    public void execute(String userName, String password) throws IOException, ParseException {
        AnalyzeDataController analyzeDataController = new AnalyzeDataController();
        SaveToFileController saveToFileController = new SaveToFileController();
        Date goodTimeDate = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse("00-00-0000 00:00:00");
        Date badTimeDate = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse("00-00-0000 00:00:00");
        try {
            ModemDAOControllerImpl modemDAOController = new ModemDAOControllerImpl();
        }catch (ServiceException e){
            System.err.println(" For working with DataBase please start it ");
        }
        writeMessage("" +
                "1 - Find Differences between Good and affected state, Enter two DateTime's good and affected states\n" +
                "2 - Analyze measurements of modems, and save to txt file\n" +
                "9 - Exit to the main menu\n");

        int choice = readInt();
        switch (choice) {
            case 1:
                writeMessage("Enter two DateTime's, first for good and second for affected state \n" +
                        "use dd-MM-yyyy HH:mm:ss format and press Enter");
                goodTimeDate = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse(readString());
                badTimeDate = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss").parse(readString());
                long start = System.nanoTime();
                // and without waiting print to console
                // ok Test 20 elems in descending order
                analyzeDataController.findDifferences(goodTimeDate, badTimeDate).forEach(System.out::println);
                long finish = System.nanoTime();
                System.out.println("two DateTime's (nanoTime())" + (finish - start));
                break;
            case 2:
                writeMessage("Analyze measurements of modems\n");
                System.out.println("storageForModems.size() " + storageForModems.size());
                List<ModemDifferenceMeasurement> resultList = new ArrayList<>();
                start = System.nanoTime();
                resultList = analyzeDataController.analyze(storageForModems);
                resultList.forEach(System.out::println);
                saveToFileController.writeToTxt(resultList);
                finish = System.nanoTime();
                System.out.println("Analyze (nanoTime())" + (finish - start));
                break;
            case 9:
                writeMessage("\n Exit to the main menu...\n");
                ConsoleHelper consoleHelper = new ConsoleHelper(userName, password);
                consoleHelper.consoleHelp();
                break;
            default:
                break;
        }
execute(userName,password);
    }
}
