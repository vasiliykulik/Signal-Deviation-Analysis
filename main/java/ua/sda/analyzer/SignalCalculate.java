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

    int measurementIndexedBinarySearch(List<Measurement> measurementList, Date date);

    /**
     * Take modem
     *
     * @return {@code index of measurement with min USSNR}
     */

    int findMinUSSNR(Modem modem);

    /**
     * Take modem
     *
     * @return {@code index of measurement with max USSNR}
     */
    int findMaxUSSNR(Modem modem);

}
