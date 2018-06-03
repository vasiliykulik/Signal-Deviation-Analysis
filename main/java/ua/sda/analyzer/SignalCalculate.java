package ua.sda.analyzer;

import ua.sda.entity.opticalnodeinterface.Modem;

/**
 * Created by Vasiliy Kylik (Lightning) on 15.05.2018.
    variant 0 - две даты, найти наиболее близкую дату, (binary search) максимальна разница между US Level,  и между ds snr
    variant1  - Create object for return values
    variant2  -
        г) возьмем max, min для USSNR, иду по значениям
        г1) рассмотрим случай когда USSNR упал, взял max SNR, взяли max dssnr, max us txpower (их сумму) max sum иду по SNR, и если текущ, SNR < max
        Определить диапазон с точностью до дБ
        г2) что я хочу получить? три Адреса с Локациями
    variant3  -
        1a. Состояние нормальное (Что такое нормальное состояние ?) - сравнивать с состоянием неисправности (Что такое состояние неисправности ?) Проявляющаяся неисправность - apparent malfunction
        1b. По US SNR найти падение, взять от него промежуток времени, и по Oбратрому и SNR прямому посмотреть какой вход и какой выход и отсортировать по амплитуде (Идём по измерениям, если текущее измерение)
        1c. Найти общий для всех модемов промежуток времени с заниженным US SNR
        1d. Найти в промежутке времени скачки по обратному и скачки DSSNR
    variant4 - Проанализировать изменения
    variant5 - Состояние нормальное - сравнивать с состоянием неисправности Проявляющаяся неисправность - apparent malfunction
    variant6 - По US SNR найти падение, взять от него промежуток времени, и по Oбратрому и SNR прямому посмотреть какой вход и какой выход и отсортировать по амплитуде
    variant7 - Найти общий для всех модемов промежуток времени с заниженным US SNR
    variant8 - Найти в промежутке времени скачки по обратному и скачки DSSNR

 */
public interface SignalCalculate {

    Integer minUpStreamSNR(Modem modem);
    Integer avgUpStreamSNR(Modem modem);
    Integer maxUpStreamSNR(Modem modem);
    Integer minDownStreamSNR(Modem modem);
    Integer avgDownStreamSNR(Modem modem);
    Integer maxDownStreamSNR(Modem modem);
    Integer minUpStreamTXPower(Modem modem);
    Integer avgUpStreamTXPower(Modem modem);
    Integer maxUpStreamTXPower(Modem modem);


}
