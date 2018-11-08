package ua.sda.view;

import ua.sda.controller.multithread.MultiThreadRetrieveDataController;
import ua.sda.entity.opticalnodeinterface.Modem;
import ua.sda.view.helper.ConsoleHelper;

import java.io.IOException;
import java.text.ParseException;
import java.util.List;

import static ua.sda.storage.Storage.storageForModems;
import static ua.sda.view.helper.ConsoleHelper.*;

/**
 * Created by Vasiliy Kylik (Lightning) on 17.08.2018.
 */
public class ConcurrencyRetrieveDataView {
    public void execute(String userName, String password) throws IOException, ParseException {
        String linkToURL;

        writeMessage("" +
                "0 - Read All (Modems, Measurements, Current State, Location) \n" +
                "9 - Exit to the main menu\n");

        int choice = readInt();

        switch (choice) {
            // here i need  to read and leave data in memory for future operations
            case 0:
                writeMessage("Enter URL to TrafficLight (Ctrl + V, Space and Enter) \n");
                linkToURL = readString();
                MultiThreadRetrieveDataController multiThreadRetrieveDataController = new MultiThreadRetrieveDataController(userName, password, linkToURL);
                // здесь хочу получить List модемов
                List<Modem> modems = multiThreadRetrieveDataController.getAll();
                long start = System.nanoTime();
                storageForModems = modems;
                long finish = System.nanoTime();
                System.out.println("storing modems in storageForModems (nanoTime())" + (finish - start));
                //   modems.forEach(System.out::println);
                break;
            case 9:
                writeMessage("\n Exit to the main menu...\n");
                ConsoleHelper consoleHelper = new ConsoleHelper(userName, password);
                consoleHelper.consoleHelp();
                break;
            default:
                break;
        }

        execute(userName, password);

    }

}
