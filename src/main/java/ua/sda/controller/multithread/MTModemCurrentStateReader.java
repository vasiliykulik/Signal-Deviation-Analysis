package ua.sda.controller.multithread;

import ua.sda.entity.multithreadentities.MultiThreadedCurrentState;
import ua.sda.readers.CurrentMeasurementReader;

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
    private String linkToCurrentState;
    private String linkToInfoPage;

    public MTModemCurrentStateReader(String userName, String password, String linkToMAC, String linkToCurrentState, String linkToInfoPage) {
        this.userName = userName;
        this.password = password;
        this.linkToMAC = linkToMAC;
        this.linkToCurrentState = linkToCurrentState;
        this.linkToInfoPage = linkToInfoPage;
    }

    /**
     * Parses HTML page for a CurrentMeasurement for adding it to a List of measurements for specific Modem
     *
     * @return {@code currentState } MultiThreadedMeasurement entity consist of
     * <br>{@code Measurement} - currentState measurement
     * <br>{@code String linkToMAC} -  field for binding currentState measurement to modem
     * <br>{@code String linkToCurrentState} -  retrieved data due business logic
     * <br>{@code String linkToInfoPage} -  for creating currentMeasurement entity
     */
    @Override
    public MultiThreadedCurrentState call() throws Exception {
        MultiThreadedCurrentState currentState = new MultiThreadedCurrentState();
        currentState.setLinkToMAC(linkToMAC);
        CurrentMeasurementReader currentMeasurementReader = new CurrentMeasurementReader();
        currentState.setCurrentState(currentMeasurementReader
                .readCurrentState(linkToCurrentState, userName, password, linkToInfoPage));
        return currentState;
    }
}
