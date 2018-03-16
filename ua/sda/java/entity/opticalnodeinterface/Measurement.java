package entity.opticalnodeinterface;

import java.util.Date;

/**
 * Created by Vasiliy Kylik on 12.07.2017.
 */
public class Measurement {

  private Date dateTime;
  private Float usTXPower;
  private Float usRXPower;
  private Float dsRxPower;
  private Float usSNR;
  private Float dsSNR;
  private Float microReflex;
  private String linkToCurrentMeasurement;
  private String linkToInfoPage;

  public Measurement(Date dateTime, Float usTXPower, Float usRXPower, Float dsRxPower, Float usSNR, Float dsSNR, Float microReflex, String linkToCurrentMeasurement, String linkToInfoPage) {
    this.dateTime = dateTime;
    this.usTXPower = usTXPower;
    this.usRXPower = usRXPower;
    this.dsRxPower = dsRxPower;
    this.usSNR = usSNR;
    this.dsSNR = dsSNR;
    this.microReflex = microReflex;
    this.linkToCurrentMeasurement = linkToCurrentMeasurement;
    this.linkToInfoPage = linkToInfoPage;
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

  public String getLinkToCurrentMeasurement() {
    return linkToCurrentMeasurement;
  }

  public void setLinkToCurrentMeasurement(String linkToCurrentMeasurement) {
    this.linkToCurrentMeasurement = linkToCurrentMeasurement;
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
            ", dsRxPower=" + dsRxPower +
            ", usSNR=" + usSNR +
            ", dsSNR=" + dsSNR +
            ", microReflex=" + microReflex +
            ", linkToCurrentMeasurement='" + linkToCurrentMeasurement + '\'' +
            ", linkToInfoPage='" + linkToInfoPage + '\'' +
            '}';
  }
}
