package ua.sda.entity.opticalnodeinterface;

import antlr.debug.MessageAdapter;
import ua.sda.entity.BaseEntity;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Table;
import java.util.Date;

/**
 * Created by Vasiliy Kylik on 12.07.2017.
 *
 *
 */
@Entity
@Table(name = "measurements")
public class Measurement extends BaseEntity implements Comparable<Measurement> {

	@Column(name = "dateTime")
	private Date dateTime;
	@Column(name = "usTXPower")
	private Float usTXPower;
	@Column(name = "usRXPower")
	private Float usRXPower;
	@Column(name = "usSNR")
	private Float usSNR;
	@Column(name = "dsRxPower")
	private Float dsRxPower;
	@Column(name = "dsSNR")
	private Float dsSNR;
	@Column(name = "microReflex")
	private Float microReflex;
	@Column(name = "linkToCurrentState")
	private String linkToCurrentState;
	@Column(name = "linkToInfoPage")
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
	// 06.07.2018 microreflex might have 0 value
	// exclude & microReflex != 0f, since the value can be zero (one time for a three month (90 * 180 cases))
	public boolean isNotNullMeasurement() {
		return usTXPower != 0f &
				usSNR != 0f &
				dsSNR != 0f ;
	}

	@Override
	public int compareTo(Measurement measurement) {
		return measurement.getDateTime().compareTo(this.getDateTime());
	}
}
