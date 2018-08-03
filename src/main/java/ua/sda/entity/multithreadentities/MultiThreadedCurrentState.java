package ua.sda.entity.multithreadentities;

import ua.sda.entity.opticalnodeinterface.Measurement;

import java.util.List;

/**
 * @author Vasiliy Kylik on(Rocket) on 31.07.2018.
 */
public class MultiThreadedCurrentState {
    private String linkToMAC;
    private Measurement currentState;

    @Override
    public String toString() {
        return "MultiThreadedCurrentState{" +
                "linkToMAC='" + linkToMAC + '\'' +
                ", currentState=" + currentState +
                '}';
    }

    public MultiThreadedCurrentState() {
    }

    public MultiThreadedCurrentState(String linkToMAC, Measurement currentState) {
        this.linkToMAC = linkToMAC;
        this.currentState = currentState;
    }

    public String getLinkToMAC() {
        return linkToMAC;
    }

    public void setLinkToMAC(String linkToMAC) {
        this.linkToMAC = linkToMAC;
    }

    public Measurement getCurrentState() {
        return currentState;
    }

    public void setCurrentState(Measurement currentState) {
        this.currentState = currentState;
    }
}
