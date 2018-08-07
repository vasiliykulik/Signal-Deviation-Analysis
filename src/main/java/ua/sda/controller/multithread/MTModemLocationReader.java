package ua.sda.controller.multithread;

import ua.sda.entity.multithreadentities.MultiThreadedLocation;

import java.util.concurrent.Callable;

/**
 * The {@code MTModemLocationReader} class represents a dao
 * to obtain Location for one Specific modem
 *
 * @author Vasiliy Kylik on(Rocket) on 31.07.2018.
 */
public class MTModemLocationReader implements Callable<MultiThreadedLocation> {

    @Override
    public MultiThreadedLocation call() throws Exception {
        return null;
    }
}
