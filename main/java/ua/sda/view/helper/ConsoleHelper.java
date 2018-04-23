package ua.sda.view.helper;

import ua.sda.view.AnalyzeDataView;
import ua.sda.view.ReadDataView;
import ua.sda.view.RetrieveDataView;
import ua.sda.view.SaveDataView;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 * Created by Vasiliy Kylik (Lightning) on 14.04.2018.
 * First layer of menu
 */
public class ConsoleHelper {
    private RetrieveDataView retrieveDataView;
    private AnalyzeDataView analyzeDataView;
    private SaveDataView saveDataView;
    private ReadDataView readDataView;

    public ConsoleHelper(String login, String password) {
        retrieveDataView = new RetrieveDataView();
        analyzeDataView = new AnalyzeDataView();
        saveDataView = new SaveDataView();
        readDataView = new ReadDataView();
    }

    public static BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(System.in));

    public static void writeMessage(String message) {
        System.out.println(message);
    }

    public void consoleHelp() throws IOException {
        System.out.println("To start work, select appropriate component, and press Enter: \n" +
                " 1. Read the Modems with Measurements, Current States and Locations on the interface () from TrafficLight Link" +
                ", (login and password are passed in the parameters) \n" +
                " 2. Save Modems with Measurements, Current States and Locations to H2 DB for further access \n" +
                " 3. Read Modems with Measurements, Current States and Locations from H2 DB \n" +
                " 4. Analyze measurements \n" +
                " 9. Exit");
        int readChoice = readInt();
        switch (readChoice) {
            case 1:
                retrieveDataView.customerView();
                break;
            case 2:
                saveDataView.customerView();
                break;
            case 3:
                readDataView.customerView();
                break;
            case 4:
                analyzeDataView.customerView();
                break;
            case 9:
                System.out.println("Exiting....");
                System.exit(0);
            default:
                break;
        }
    }

    public static int readInt() throws IOException {
        int number = 0;
        try {
            number = Integer.parseInt(bufferedReader.readLine());
        } catch (NumberFormatException e) {
            writeMessage("Incorrect data entered. Repeat input please.");
            readInt();
        }
        return number;
    }

    public static String readString() throws IOException {
        return bufferedReader.readLine();
    }
}
