package ua.sda.view;

import ua.sda.controllerdao.ModemDAOControllerImpl;
import ua.sda.view.helper.ConsoleHelper;

import java.io.IOException;

import static ua.sda.storage.Storage.storageForModems;
import static ua.sda.view.helper.ConsoleHelper.readInt;
import static ua.sda.view.helper.ConsoleHelper.writeMessage;

/**
 * Created by Vasiliy Kylik (Lightning) on 23.04.2018.
 */
public class AnalyzeDataView {
    public void execute(String userName, String password) throws IOException {
        ModemDAOControllerImpl modemDAOController = new ModemDAOControllerImpl();
        writeMessage("" +
                "1 - Enter two DateTime's\n good and affected states" +
                "2 - Analyze measurements of modems\n" +
                "9 - Exit to the main menu\n");

        int choice = readInt();
        switch (choice) {
            case 1:
                writeMessage("Enter two DateTime's\n good and affected states \n");
                System.out.println("storageForModems.size() " + storageForModems.size());
                long start = System.nanoTime();
                // for this ConsoleHelper become static
                modemDAOController.save(storageForModems);
                long finish = System.nanoTime();
                System.out.println("storing modems in DB saveDB() (nanoTime())" + (finish - start));
                System.out.println("storageForModems.size() after saveDB() " + storageForModems.size());
                break;
            case 2:
                writeMessage("Analyze measurements of modems\n");
                System.out.println("storageForModems.size() " + storageForModems.size());
                start = System.nanoTime();
                modemDAOController.readDB();
                finish = System.nanoTime();
                System.out.println("reading modems from readDB() (nanoTime())" + (finish - start));
                System.out.println("storageForModems.size() after readDB() " + storageForModems.size());
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
