package ua.sda;


import ua.sda.view.helper.ConsoleHelper;

import java.io.IOException;

/**
 * Created by Vasiliy Kylik (Lightning) on 14.04.2018.
 * Main entry point, pass arguments L and P to consoleHelper constructor
 */
public class SDAConsoleRunner {

    public static void main(String[] args) throws IOException {
        ConsoleHelper consoleHelper = new ConsoleHelper(args[0],args[1]);
        consoleHelper.consoleHelp();

    }
}
