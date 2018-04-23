package ua.sda.view.helper;

import ua.sda.view.AnalyzeDataView;
import ua.sda.view.DataView;
import ua.sda.view.RetrieveDataView;

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
    private DataView dataView;
    private String userName;
    private String password;

    public ConsoleHelper(String login, String pword) {
        userName = login;
        password = pword;
        retrieveDataView = new RetrieveDataView();
        analyzeDataView = new AnalyzeDataView();
        dataView = new DataView();
    }

    public static BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(System.in));

    public static void writeMessage(String message) {
        System.out.println(message);
    }

    public void consoleHelp() throws IOException {
        System.out.println("To start work, select appropriate component, and press Enter: \n" +
                " 1. Read the Modems with Measurements, Current States and Locations on the interface () from TrafficLight Link" +
                ", (login and password are passed in the parameters) \n" +
                " 2. Analyze measurements \n" +
                " 3. Save,Read Modems with Measurements, Current States and Locations to, from H2 DB (for further access) \n" +
                " 9. Exit");
        int readChoice = readInt();
        switch (readChoice) {
            case 1:
                retrieveDataView.execute();
                break;
            case 2:
                analyzeDataView.execute();
                break;
            case 4:
                dataView.execute();
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
