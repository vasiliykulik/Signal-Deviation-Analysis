package ua.sda.view;

import ua.sda.SDAConsoleRunner;
import ua.sda.controller.RetrieveDataController;
import ua.sda.view.helper.ConsoleHelper;

import java.io.IOException;

import static ua.sda.view.helper.ConsoleHelper.readInt;
import static ua.sda.view.helper.ConsoleHelper.writeMessage;

/**
 * Created by Vasiliy Kylik (Lightning) on 19.04.2018.
 */
/*System.out.println("Paste link to TrafficLight");
        String linkToInterface = readString();*/

public class RetrieveDataView {
    public void execute() throws IOException {
        RetrieveDataController retrieveDataController = new RetrieveDataController();

        writeMessage("" +
                "0 - \n" +
                "1 - \n" +
                "2 - \n" +
                "3 - \n" +
                "4 - \n" +
                "5 - \n" +
                "6 - Exit to the main menu\n");

        int choice = readInt();

        switch (choice) {
            case 0:
                break;
            case 1:
                break;
            case 2:
                break;
            case 3:
                break;
            case 4:
                break;
            case 5:
                break;
            case 6:
                writeMessage("\n Exit to the main menu...\n");
                break;
            default:
                break;
        }
        execute();
    }
}
