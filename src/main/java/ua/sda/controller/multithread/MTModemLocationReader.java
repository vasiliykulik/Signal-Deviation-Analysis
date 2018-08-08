package ua.sda.controller.multithread;

import ua.sda.entity.multithreadentities.MultiThreadedLocation;
import ua.sda.entity.opticalnodeinterface.ModemLocation;
import ua.sda.readers.ModemLocationReader;

import java.util.concurrent.Callable;

/**
 * The {@code MTModemLocationReader} class represents a dao
 * to obtain Location for one Specific modem
 *
 * @author Vasiliy Kylik on(Rocket) on 31.07.2018.
 */
public class MTModemLocationReader implements Callable<MultiThreadedLocation> {
    private String userName;
    private String password;
    private String linkToMAC;
    private String linkToInfoPage;

    public MTModemLocationReader(String userName, String password, String linkToMAC, String linkToInfoPage) {
        this.userName = userName;
        this.password = password;
        this.linkToMAC = linkToMAC;
        this.linkToInfoPage = linkToInfoPage;
    }

    /**
     * Parses HTML page for a LocationInfo for adding it to a List of measurements for specific Modem
     *
     * @return {@code locationInfo } MultiThreadedLocation entity consist of
     * <br>{@code ModemLocation} - locationInfo information of location
     * <br>{@code String linkToMAC} -  field for binding currentState measurement to modem
     * <br>{@code String linkToInfoPage} -  retrieved data due business logic
     */
    @Override
    public MultiThreadedLocation call() throws Exception {
        MultiThreadedLocation locationInfo = new MultiThreadedLocation();
        locationInfo.setLinkToMAC(linkToMAC);
         ModemLocationReader modemLocationReader = new ModemLocationReader();
         locationInfo.setLocation(modemLocationReader.readModemLocation(linkToInfoPage,
                 userName,password));
        return locationInfo;
    }
}
