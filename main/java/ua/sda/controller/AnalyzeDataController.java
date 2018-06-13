package ua.sda.controller;

import ua.sda.comparators.ComparatorDifferenceMeasurement;
import ua.sda.entity.analyze.ModemDifferenceMeasurement;
import ua.sda.entity.opticalnodeinterface.Measurement;
import ua.sda.entity.opticalnodeinterface.Modem;

import java.util.Date;
import java.util.List;

import static ua.sda.storage.Storage.storageForModems;

/**
 * Created by Vasiliy Kylik (Lightning) on 23.04.2018.
 */

public class AnalyzeDataController {
    /*Ввод двух дат
 Ввели две даты
 Задача: для каждой даты , для каждого модема найти наиболее близкую дату. и взять в эти моменты времени, ustxpower, и dssnr, взять разницу между ними.
 TODO Implement DateTime Search
 use Comparable thru Measurement compareto method for descending order (ComparatorMeasurement used for descending order)
 Результат сложить в массив ModemDifferenceMeasurement, объектами.
 в итоге будем иметь структуру данных с 10 объектами. на вывод. да мне нужны модемы, точнее мне нужны локации.*/
    public List<ModemDifferenceMeasurement> findDifferences(Date goodTimeDate, Date badTimeDate) {
        ComparatorDifferenceMeasurement comparatorDifferenceMeasurement = new ComparatorDifferenceMeasurement();

        goodIndexedBinarySearch(storageForModems.get(1).getMeasurements(), goodTimeDate);
        return null;
    }

    /*The list must be sorted into ascending order
     * according to the {@linkplain Comparable natural ordering} of its
     * elements (as by the {@link #sort(List)} method) prior to making this
     * call.  If it is not sorted, the results are undefined.  If the list
     * contains multiple elements equal to the specified object, there is no
     * guarantee which one will be found.
     *
     * <p>This method runs in log(n) time for a "random access" list (which
     * provides near-constant-time positional access).  If the specified list
     * does not implement the {@link RandomAccess} interface and is large,
     * this method will do an iterator-based binary search that performs
     * O(n) link traversals and O(log n) element comparisons.
     * @return the index of the search key, if it is contained in the list;
     *         otherwise, <tt>(-(<i>insertion point</i>) - 1)</tt>.  The
     *         <i>insertion point</i> is defined as the point at which the
     *         key would be inserted into the list: the index of the first
     *         element greater than the key, or <tt>list.size()</tt> if all
     *         elements in the list are less than the specified key.  Note
     *         that this guarantees that the return value will be &gt;= 0 if
     *         and only if the key is found.
     *         Мне надо что бы возвращалось значение - good - that is мы считаем что до этого момента все было хорошо,
     *         Коллекция отсортирована по нисходящему порядку, новые даты вначале (тоесть большие вначале), that is need to return ьеньшее значение, предыдущее измерение,
     *         insertion point, as the point at which the key would be inserted into the list is great
     *         Соответственно переворачиваем условия if и compareTo метод в классе Measurement, что позволит нам работать с descending order что соответствует бизнес логике
     *         для good будет low - более раннее, а для bad - будет low -1 более позднее (на шкале вемени при descending order)*/
    private int goodIndexedBinarySearch(List<Measurement> measurementList, Date date) {
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
        return (low);  // key not found, previous measurement would be returned, ascending order
    }

    private int badIndexedBinarySearch(List<Measurement> measurementList, Date date) {
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
        return (low-1);  // key not found, next value would be returned , ascending order
    }

    private int binarySearch()
    {}


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
