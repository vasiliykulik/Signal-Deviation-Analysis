package ua.sda.view.helper;

import ua.sda.view.ModemWithMeasurementsView;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 * Created by Vasiliy Kylik (Lightning) on 14.04.2018.
 */
public class ConsoleHelper {
    private ModemWithMeasurementsView modemWithMeasurementsView;

    public ConsoleHelper() {
        modemWithMeasurementsView = new ModemWithMeasurementsView();
    }

    public static BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(System.in));

    public static void writeMessage(String message) {
        System.out.println(message);
    }

    public void consoleHelp() throws IOException {
        System.out.println("To start work, select appropriate component, and press Enter: \n 1. Read the Modems with Measurements, Current States and Locations on the interface,  (login and password are passed in the parameters) \n 9. Exit");
        int readChoice = readInt();
        switch (readChoice) {
            case 1:
                modemWithMeasurementsView.customerView();
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
