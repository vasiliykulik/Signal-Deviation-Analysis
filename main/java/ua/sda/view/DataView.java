package ua.sda.view;

import ua.sda.controllerdao.ModemDAOControllerImpl;
import ua.sda.entity.opticalnodeinterface.Modem;
import ua.sda.view.helper.ConsoleHelper;

import java.io.IOException;
import java.util.List;

import static ua.sda.storage.Storage.storageForModems;
import static ua.sda.view.helper.ConsoleHelper.readInt;
import static ua.sda.view.helper.ConsoleHelper.readString;
import static ua.sda.view.helper.ConsoleHelper.writeMessage;

/**
 * Created by Vasiliy Kylik (Lightning) on 23.04.2018.
 */
public class DataView {
    public void execute(String userName, String password) throws IOException {
        ModemDAOControllerImpl modemDAOController = new ModemDAOControllerImpl();
        writeMessage("" +
                "0 - Save Modems to DataBase\n" +
                "1 - Read Modems from DataBase\n" +
                "2 - Remove Modems from DataBase\n" +
                "9 - Exit to the main menu\n");

        int choice = readInt();
        switch (choice) {
            case 0:
                writeMessage("Saving Modems to DataBase \n");
                System.out.println("storageForModems.size() " + storageForModems.size());
                long start = System.nanoTime();
                // for this ConsoleHelper become static
                modemDAOController.save(storageForModems);
                long finish = System.nanoTime();
                System.out.println("storing modems in DB saveDB() (nanoTime())" + (finish - start));
                System.out.println("storageForModems.size() after saveDB() " + storageForModems.size());
                break;
            case 1:
                writeMessage("Reading Modems from DataBase\n");
                System.out.println("storageForModems.size() " + storageForModems.size());
                start = System.nanoTime();
                modemDAOController.readDB();
                finish = System.nanoTime();
                System.out.println("reading modems from readDB() (nanoTime())" + (finish - start));
                System.out.println("storageForModems.size() after readDB() " + storageForModems.size());
                break;
            case 2:
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

    }
}
