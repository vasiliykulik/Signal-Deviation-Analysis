package ua.sda.view;

import ua.sda.controllerdao.ModemDAOControllerImpl;
import ua.sda.entity.opticalnodeinterface.Modem;
import ua.sda.view.helper.ConsoleHelper;

import java.io.IOException;
import java.util.List;

import static ua.sda.view.helper.ConsoleHelper.readInt;
import static ua.sda.view.helper.ConsoleHelper.readString;
import static ua.sda.view.helper.ConsoleHelper.writeMessage;

/**
 * Created by Vasiliy Kylik (Lightning) on 23.04.2018.
 */
public class DataView {
    public void execute(List<Modem> modems) throws IOException {
        ModemDAOControllerImpl modemDAOController    = new ModemDAOControllerImpl();
        writeMessage("" +
                "0 - Save Modems to DataBase" +
                "1 - Read Modems from DataBase" +
                "2 - Remove Modems from DataBase");

        int choice = readInt();
        switch (choice) {
            case 0:
                writeMessage("Save Modems to DataBase \n");
                // for this ConsoleHelper become static
                modemDAOController.save(ConsoleHelper.getRetrieveDataView().getModems());
                break;
            case 1:
                writeMessage("\n Exit to the main menu...\n");
                ConsoleHelper consoleHelper = new ConsoleHelper(userName, password);
                consoleHelper.consoleHelp();
                break;
            case 2:
                writeMessage("\n Exit to the main menu...\n");
                ConsoleHelper consoleHelper = new ConsoleHelper(userName, password);
                consoleHelper.consoleHelp();
                break;
            default:
                break;
        }

    }
}
