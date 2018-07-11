package ua.sda.analyzer;

import ua.sda.entity.opticalnodeinterface.Measurement;
import ua.sda.entity.opticalnodeinterface.Modem;

import java.util.Date;
import java.util.List;

/**
 * Created by Vasiliy Kylik (Lightning) on 15.05.2018.
 * Ввод двух дат
 * Ввели две даты
 * Задача: для каждой даты , для каждого модема найти наиболее близкую дату. и взять в эти моменты времени, ustxpower, и dssnr, взять разницу между ними.
 * Результат сложить в массив ModemDifferenceMeasurement, объектами.
 * в итоге будем иметь структуру данных с 10 объектами. на вывод. да мне нужны модемы, точнее мне нужны локации.
 * <p>
 * Анализ Сигналов
 * Задача: Найти разницу уровней для максимального и минимального SNR
 * Реализация:
 * для каждого модема
 * возьмем min и max для USSNR
 * если min и max значений несколько то берем все
 * В эти измерения фиксируем сумму analyzeDifference = usTxPower+usRxPower+ dsSNR.
 * те для каждого модема получаем амплитуду скачка - analyzeDifference - и соответственно находим 10 модемов с максимальной analyzeDifference (в коллекции сортируем)
 * и десять наибоьших - на вывод
 * Что я хочу получить?:
 * десять Адресов с Локациями, для максимального падения сигналов обратный уровень и прямой snr
 */
public interface SignalCalculate {
    /**
     * Take List Measurement
     *
     * @return {@code measurementIndexedBinarySearch }the index of search key or nearest previous (good return low);
     */
    int findGoodMeasurement(List<Measurement> measurements, Date dateTime);

    /**
     * Take List Measurement
     *
     * @return {@code measurementIndexedBinarySearch } the index of search key or nearest next (bad return low -1)
     */
    int findBadMeasurement(List<Measurement> measurements, Date dateTime);


    /**
     * Take modem<p>
     * Sort measurements in ascending order by USSNR and so on
     * find the worst value US SNR (a smaller value )
     * if several equal values, next find the worst value DS SNR (a smaller value)
     * if several equal values next find the worst value MicroReflx
     * next find the worst value US TX POWER (a larger value)
     * next find the worst value (a larger value) of US RX Power ()
     *
     * @return {@code index of measurement with min USSNR}
     */

    int findMinUSSNR(Modem modem);

    /**
     * Take modem<p>
     * Sort measurements in descending order by USSNR and so on
     * find the best value US SNR (a larger value)
     * if several equal values, next find the best value DS SNR (a larger value)
     * next find the best value MicroReflx
     * next find the best value US TX POWER (a smaller value)
     * next find the best value(a smaller value) of US RX Power
     *
     * @return {@code index of measurement with max USSNR}
     */
    int findMaxUSSNR(Modem modem);

}
