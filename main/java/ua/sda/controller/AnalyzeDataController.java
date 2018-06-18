package ua.sda.controller;

import ua.sda.analyzer.SignalCalculate;
import ua.sda.analyzer.SignalCalculateImpl;
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
    SignalCalculate signalCalculate = new SignalCalculateImpl();

    /**
     * Ввели две даты
     * Задача: для каждой даты , для каждого модема найти наиболее близкую дату. и взять в эти моменты времени,
     * ustxpower, и dssnr, взять разницу между ними.
     * <p>ok Implement DateTime Search
     * <p>use Comparable thru Measurement compareto method for descending order (ComparatorMeasurement used for descending order)
     * <p>Результат сложить в массив ModemDifferenceMeasurement, объектами.
     * в итоге будем иметь структуру данных с 10 объектами. на вывод. да мне нужны модемы, точнее мне нужны локации.
     * Возвращаемая коллекция будет отсортирована по амплитуде разницы сигналов
     *
     * @return {@code modemDifferenceMeasurements }List of Modems for particularly taken modem
     */

    public List<ModemDifferenceMeasurement> findDifferences(Date goodTimeDate, Date badTimeDate) {
        List<ModemDifferenceMeasurement> modemDifferenceMeasurements = new ArrayList<>();
        // for each Modem find two Measurements according to Date
        for (Modem modem : storageForModems) {
            int goodCase = signalCalculate.findGoodMeasurement(modem.getMeasurements(), goodTimeDate);
            int badCase = signalCalculate.findBadMeasurement(modem.getMeasurements(), badTimeDate);
            ModemDifferenceMeasurement modemDifferenceMeasurement = new ModemDifferenceMeasurement
                    (modem,goodCase-badCase);
            modemDifferenceMeasurements.add(modem)
        }
        signalCalculate.measurementIndexedBinarySearch(storageForModems.get(1).getMeasurements(), goodTimeDate);
        return modemDifferenceMeasurements;
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
