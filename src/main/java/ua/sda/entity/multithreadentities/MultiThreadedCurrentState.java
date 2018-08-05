package ua.sda.entity.multithreadentities;

import ua.sda.entity.opticalnodeinterface.Measurement;

import java.util.List;

/**
 * @author Vasiliy Kylik on(Rocket) on 31.07.2018.
 */
public class MultiThreadedCurrentState {
    private String linkToMAC;
    private String linkToCurrentState;
    private String linkToInfoPage;
    private Measurement currentState;

    @Override
    public String toString() {
        return "MultiThreadedCurrentState{" +
                "linkToMAC='" + linkToMAC + '\'' +
                ", linkToCurrentState='" + linkToCurrentState + '\'' +
                ", linkToInfoPage='" + linkToInfoPage + '\'' +
                ", currentState=" + currentState +
                '}';
    }

    public String getLinkToMAC() {
        return linkToMAC;
    }

    public void setLinkToMAC(String linkToMAC) {
        this.linkToMAC = linkToMAC;
    }

    public String getLinkToCurrentState() {
        return linkToCurrentState;
    }

    public void setLinkToCurrentState(String linkToCurrentState) {
        this.linkToCurrentState = linkToCurrentState;
    }

    public String getLinkToInfoPage() {
        return linkToInfoPage;
    }

    public void setLinkToInfoPage(String linkToInfoPage) {
        this.linkToInfoPage = linkToInfoPage;
    }

    public Measurement getCurrentState() {
        return currentState;
    }

    public void setCurrentState(Measurement currentState) {
        this.currentState = currentState;
    }

    public MultiThreadedCurrentState() {

    }

    public MultiThreadedCurrentState(String linkToMAC, String linkToCurrentState, String linkToInfoPage, Measurement currentState) {

        this.linkToMAC = linkToMAC;
        this.linkToCurrentState = linkToCurrentState;
        this.linkToInfoPage = linkToInfoPage;
        this.currentState = currentState;
    }
}
