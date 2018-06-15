package ua.sda.controller;

import ua.sda.entity.opticalnodeinterface.ModemDifferenceMeasurement;
import ua.sda.entity.opticalnodeinterface.Measurement;
import ua.sda.entity.opticalnodeinterface.Modem;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import static ua.sda.storage.Storage.storageForModems;

/**
 * Created by Vasiliy Kylik (Lightning) on 23.04.2018.
 * <p>
 * {@code AnalyzeDataController}
 * <p>
 * provide Data analysis:
 * <p>List<ModemDifferenceMeasurement> findDifferences(Date goodTimeDate, Date badTimeDate){}
 * <p>List<ModemDifferenceMeasurement> analyze(List<Modem> modems){}
 */

public class AnalyzeDataController {
    /**
     * Ввели две даты
     * Задача: для каждой даты , для каждого модема найти наиболее близкую дату. и взять в эти моменты времени,
     * ustxpower, и dssnr, взять разницу между ними.
     * <p>ok Implement DateTime Search
     * <p>use Comparable thru Measurement compareto method for descending order (ComparatorMeasurement used for descending order)
     * <p>Результат сложить в массив ModemDifferenceMeasurement, объектами.
     * в итоге будем иметь структуру данных с 10 объектами. на вывод. да мне нужны модемы, точнее мне нужны локации.
     *
     * @return {@code modemDifferenceMeasurements }List of Modems for particularly taken modem
     */

    public List<ModemDifferenceMeasurement> findDifferences(Date goodTimeDate, Date badTimeDate) {
        List<ModemDifferenceMeasurement> modemDifferenceMeasurements = new ArrayList<>();
// for each Modem find two Measurements accrding to Date
        for (Modem modem : storageForModems) {
            int goodCase = goodMeasurement(modem.getMeasurements(), goodTimeDate);
            int badCase = badMeasurement(modem.getMeasurements(), badTimeDate);
        }
        measurementIndexedBinarySearch(storageForModems.get(1).getMeasurements(), goodTimeDate);


        return modemDifferenceMeasurements;
    }

    /*Принимает List Measurement
    * @return {@code measurementIndexedBinarySearch }the index of search key or nearest previous (good return low)*/
    private int goodMeasurement(List<Measurement> measurements, Date dateTime) {
        return measurementIndexedBinarySearch(measurements, dateTime);
    }

    /*Принимает List Measurement
    * @return the index of search key or nearest next (bad return low -1)*/
    private int badMeasurement(List<Measurement> measurements, Date dateTime) {
        return measurementIndexedBinarySearch(measurements, dateTime) - 1;
    }

    /*If List is not sorted, the results are undefined.  If the list
     * contains multiple elements equal to the specified object, there is no
     * guarantee which one will be found.
     *
     * <p>This method runs in log(n) time for a "random access" list (which
     * provides near-constant-time positional access).  If the specified list
     * does not implement the {@link RandomAccess} interface and is large,
     * this method will do an iterator-based binary search that performs
     * O(n) link traversals and O(log n) element comparisons.
     * @return the index of the search key, if it is contained in the list;
     *         otherwise, return low
     *         Мне надо что бы возвращалось значение - good - that is мы считаем что до этого момента все было хорошо,
     *         Коллекция отсортирована по нисходящему порядку, новые даты вначале (тоесть большие вначале), that is need to return ьеньшее значение, предыдущее измерение,
     *         insertion point, as the point at which the key would be inserted into the list is great
     *         Соответственно переворачиваем условия if и compareTo метод в классе Measurement, что позволит нам работать с descending order что соответствует бизнес логике
     *         для good будет low - более раннее, а для bad - будет low -1 более позднее (на шкале вемени при descending order)
     *         ok Получается два почти одинаковых метода. Сделать один метод поиска. И над два которые возвращают разное смещение по коллекции
     *         good return low
     *         bad return low -1*/
    private int measurementIndexedBinarySearch(List<Measurement> measurementList, Date date) {
        int low = 0;
        int high = measurementList.size() - 1;

        while (low <= high) {
            int mid = (low + high) >>> 1;
            Measurement midVal = measurementList.get(mid);
            int cmp = midVal.getDateTime().compareTo(date);

            if (cmp > 0)
                low = mid + 1;
            else if (cmp < 0)
                high = mid - 1;
            else
                return mid; // key found
        }
        return (low);  // key not found, previous measurement would be returned, descending order
    }


    /* Анализ Сигналов
 Задача: Найти разницу уровней для максимального и минимального SNR
 Реализация:
 для каждого модема
 возьмем min и max для USSNR
 если min и max значений несколько то берем все
 В эти измерения фиксируем сумму analyzeDifference = usTxPower+usRxPower+ dsSNR.
 те для каждого модема получаем амплитуду скачка - analyzeDifference - и соответственно находим 10 модемов с максимальной analyzeDifference (в коллекции сортируем)
 и десять наибоьших - на вывод
 Что я хочу получить?:
 десять Адресов с Локациями, для максимального падения сигналов обратный уровень и прямой snr*/
    public List<ModemDifferenceMeasurement> analyze(List<Modem> modems) {
        return null;
    }
}
