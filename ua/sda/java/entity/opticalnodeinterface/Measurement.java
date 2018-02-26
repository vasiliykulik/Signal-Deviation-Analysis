package entity.opticalnodeinterface;

import java.util.Date;

/**
 * Created by Vasiliy Kylik on 12.07.2017.
 */
public class Measurement {
  private Date time;
  private float usTXPower;
  private float usRXPower;
  private float usSNR;
  private float dsSNR;
  private float microReflex;

  public Measurement(Date time, float usTXPower, float usRXPower, float usSNR, float dsSNR, float microReflex) {
    this.time = time;
    this.usTXPower = usTXPower;
    this.usRXPower = usRXPower;
    this.usSNR = usSNR;
    this.dsSNR = dsSNR;
    this.microReflex = microReflex;
  }

  public Date getTime() {
    return time;
  }

  public void setTime(Date time) {
    this.time = time;
  }

  public float getUsTXPower() {
    return usTXPower;
  }

  public void setUsTXPower(float usTXPower) {
    this.usTXPower = usTXPower;
  }

  public float getUsRXPower() {
    return usRXPower;
  }

  public void setUsRXPower(float usRXPower) {
    this.usRXPower = usRXPower;
  }

  public float getUsSNR() {
    return usSNR;
  }

  public void setUsSNR(float usSNR) {
    this.usSNR = usSNR;
  }

  public float getDsSNR() {
    return dsSNR;
  }

  public void setDsSNR(float dsSNR) {
    this.dsSNR = dsSNR;
  }

  public float getMicroReflex() {
    return microReflex;
  }

  public void setMicroReflex(float microReflex) {
    this.microReflex = microReflex;
  }

  @Override
  public String toString() {
    return "Measurement{" +
            "time=" + time +
            ", usTXPower=" + usTXPower +
            ", usRXPower=" + usRXPower +
            ", usSNR=" + usSNR +
            ", dsSNR=" + dsSNR +
            ", microReflex=" + microReflex +
            '}';
  }
}
