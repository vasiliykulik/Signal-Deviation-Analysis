package ua.sda.controller.multithread;

import ua.sda.entity.multithreadentities.MultiThreadedCurrentState;

import java.util.concurrent.Callable;

/**
 * The {@code MTModemCurrentStateReader} class represents a dao
 * to obtain CurrentState for one Specific modem
 *
 * @author Vasiliy Kylik on(Rocket) on 31.07.2018.
 */
public class MTModemCurrentStateReader implements Callable<MultiThreadedCurrentState> {

    private String userName;
    private String password;
    private String linkToMAC;

    public MTModemCurrentStateReader(String userName, String password, String linkToMAC) {
        this.userName = userName;
        this.password = password;
        this.linkToMAC = linkToMAC;
    }

    /**
     * Parses HTML page for a CurrentMeasurement for add it to a List of measurements for specific Modem
     *
     * @return {@code currentState } MultiThreadedMeasurement entity consist of
     * <br>{@code Measurement} - currentState measurement
     * <br>{@code String linkToMAC} -  field for binding currentState measurement to modem
     */
    @Override
    public MultiThreadedCurrentState call() throws Exception {
        return null;
    }
}
