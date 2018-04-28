package ua.sda.view;

import ua.sda.controller.RetrieveDataController;
import ua.sda.entity.opticalnodeinterface.Modem;

import java.io.IOException;
import java.util.Collection;

import static ua.sda.view.helper.ConsoleHelper.*;

/**
 * Created by Vasiliy Kylik (Lightning) on 19.04.2018.
 */
/*System.out.println("Paste link to TrafficLight");
        String linkToInterface = readString();*/

public class RetrieveDataView {
    public void execute() throws IOException {
        RetrieveDataController retrieveDataController = new RetrieveDataController();
        String linkToURL;

        writeMessage("" +
                "0 - Read All (Modems, Measurements, Current State, Location) \n" +
                "9 - Exit to the main menu\n");

        int choice = readInt();

        switch (choice) {
            // here i need  to read and leave data in memory for future operations
            case 0:
                writeMessage("Enter URL to TrafficLight \n");
                linkToURL = readString();
                Collection<Modem> modems = retrieveDataController.getAll();
                modems.forEach(System.out::println);
                break;
            case 9:
                writeMessage("\n Exit to the main menu...\n");
                break;
            default:
                break;
        }
        execute();
    }
}
