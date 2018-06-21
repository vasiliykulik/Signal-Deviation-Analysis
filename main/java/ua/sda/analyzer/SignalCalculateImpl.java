package ua.sda.analyzer;

import ua.sda.entity.opticalnodeinterface.Measurement;
import ua.sda.entity.opticalnodeinterface.Modem;

import java.util.Date;
import java.util.List;

/**
 * Created by Vasiliy Kylik (Lightning) on 15.05.2018.
 */
public class SignalCalculateImpl implements SignalCalculate {

    /**
     * Принимает List Measurement
     *
     * @return {@code measurementIndexedBinarySearch }the index of search key or nearest previous (good return low);
     */
    public int findGoodMeasurement(List<Measurement> measurements, Date dateTime) {
        return measurementIndexedBinarySearch(measurements, dateTime);
    }

    /**
     * Принимает List Measurement
     *
     * @return {@code measurementIndexedBinarySearch } the index of search key or nearest next (bad return low -1)
     */
    public int findBadMeasurement(List<Measurement> measurements, Date dateTime) {
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
    public int measurementIndexedBinarySearch(List<Measurement> measurementList, Date date) {
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

    @Override
    public int findMinUSSNR(Modem modem) {
        return 0;
    }

    @Override
    public int findMaxUSSNR(Modem modem) {
        return 0;
    }
}
