package ua.sda.entity.opticalnodeinterface;

import java.util.Date;

/**
 * Created by Vasiliy Kylik on 12.07.2017.
 */
public class Measurement {

    private Date dateTime;
    private Float usTXPower;
    private Float usRXPower;
    private Float usSNR;
    private Float dsRxPower;
    private Float dsSNR;
    private Float microReflex;
    private String linkToCurrentState;
    private String linkToInfoPage;

    public Measurement(Date dateTime, Float usTXPower, Float usRXPower, Float usSNR, Float dsRxPower, Float dsSNR, Float microReflex, String linkToCurrentState, String linkToInfoPage) {
        this.dateTime = dateTime;
        this.usTXPower = usTXPower;
        this.usRXPower = usRXPower;
        this.usSNR = usSNR;
        this.dsRxPower = dsRxPower;
        this.dsSNR = dsSNR;
        this.microReflex = microReflex;
        this.linkToCurrentState = linkToCurrentState;
        this.linkToInfoPage = linkToInfoPage;
    }

    public Measurement() {

    }

    public Date getDateTime() {
        return dateTime;
    }

    public void setDateTime(Date dateTime) {
        this.dateTime = dateTime;
    }

    public Float getUsTXPower() {
        return usTXPower;
    }

    public void setUsTXPower(Float usTXPower) {
        this.usTXPower = usTXPower;
    }

    public Float getUsRXPower() {
        return usRXPower;
    }

    public void setUsRXPower(Float usRXPower) {
        this.usRXPower = usRXPower;
    }

    public Float getDsRxPower() {
        return dsRxPower;
    }

    public void setDsRxPower(Float dsRxPower) {
        this.dsRxPower = dsRxPower;
    }

    public Float getUsSNR() {
        return usSNR;
    }

    public void setUsSNR(Float usSNR) {
        this.usSNR = usSNR;
    }

    public Float getDsSNR() {
        return dsSNR;
    }

    public void setDsSNR(Float dsSNR) {
        this.dsSNR = dsSNR;
    }

    public Float getMicroReflex() {
        return microReflex;
    }

    public void setMicroReflex(Float microReflex) {
        this.microReflex = microReflex;
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

    @Override
    public String toString() {
        return "Measurement{" +
                "dateTime=" + dateTime +
                ", usTXPower=" + usTXPower +
                ", usRXPower=" + usRXPower +
                ", usSNR=" + usSNR +
                ", dsRxPower=" + dsRxPower +
                ", dsSNR=" + dsSNR +
                ", microReflex=" + microReflex +
                ", linkToCurrentState='" + linkToCurrentState + '\'' +
                ", linkToInfoPage='" + linkToInfoPage + '\'' +
                '}';
    }

    // exclude usRXPower, dsRxPower because their values can be equal to zero
    public boolean isNotNullMeasurement() {
        return usTXPower != 0f &
                usSNR != 0f &
                dsSNR != 0f &
                microReflex != 0f;
    }
}
