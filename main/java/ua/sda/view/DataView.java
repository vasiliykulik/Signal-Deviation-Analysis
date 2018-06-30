package ua.sda.view;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import ua.sda.controller.AnalyzeDataController;
import ua.sda.controllerdao.ModemDAOControllerImpl;
import ua.sda.view.helper.ConsoleHelper;

import java.io.IOException;
import java.text.ParseException;

import static ua.sda.storage.Storage.storageForModems;
import static ua.sda.view.helper.ConsoleHelper.readInt;
import static ua.sda.view.helper.ConsoleHelper.writeMessage;

/**
 * Created by Vasiliy Kylik (Lightning) on 23.04.2018.
 */
public class DataView {
    private static final Logger LOGGER = LoggerFactory.getLogger(DataView.class);

    public void execute(String userName, String password) throws IOException, ParseException {
        ModemDAOControllerImpl modemDAOController = new ModemDAOControllerImpl();
        writeMessage("" +
                "1 - Save Modems to DataBase\n" +
                "2 - Read Modems from DataBase\n" +
                "3 - Remove Modems from DataBase\n" +
                "9 - Exit to the main menu\n");

        int choice = readInt();
        switch (choice) {
            case 1:
                writeMessage("Saving Modems to DataBase \n");
                System.out.println("storageForModems.size() " + storageForModems.size());
                long start = System.nanoTime();
                // for this ConsoleHelper become static
                try {
                    modemDAOController.save(storageForModems);
                } catch (NullPointerException e) {
                    System.err.println("Caught NullPointerException, trying to save empty storageForModems in DB");
                    e.printStackTrace();
                }
                long finish = System.nanoTime();
                System.out.println("storing modems in DB saveDB() (nanoTime())" + (finish - start));
                System.out.println("storageForModems.size() after saveDB() " + storageForModems.size());
                break;
            case 2:
                writeMessage("Reading Modems from DataBase\n");
                start = System.nanoTime();
                try {
                    storageForModems.isEmpty();
                } catch (NullPointerException e) {
                    LOGGER.warn("storageForModems not Empty, but still continue reading from DataBase");
                } finally {
                  storageForModems = modemDAOController.readDB();
                }
                finish = System.nanoTime();
                System.out.println("reading modems from readDB() (nanoTime())" + (finish - start));
                System.out.println("storageForModems.size() after readDB() " + storageForModems.size());
                break;
            case 3:
                writeMessage("Removing Modems from DataBase\n");
                start = System.nanoTime();
                modemDAOController.removeFromDB();
                finish = System.nanoTime();
                System.out.println("removeFromDB() (nanoTime())" + (finish - start));
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
