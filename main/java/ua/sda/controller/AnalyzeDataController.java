package ua.sda.controller;

import ua.sda.analyzer.SignalCalculate;
import ua.sda.analyzer.SignalCalculateImpl;
import ua.sda.entity.opticalnodeinterface.ModemDifferenceMeasurement;
import ua.sda.entity.opticalnodeinterface.Measurement;
import ua.sda.entity.opticalnodeinterface.Modem;

import java.util.*;

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
    private SignalCalculate signalCalculate = new SignalCalculateImpl();

    /**
     * Ввели две даты
     * Задача: для каждой даты , для каждого модема найти наиболее близкую дату. и взять в эти моменты времени,
     * ustxpower, и dssnr, взять разницу между ними.
     * <p>ok Implement DateTime Search
     * <p>use Comparable thru Measurement compareto method for descending order (ComparatorMeasurement used for descending order)
     * <p>Результат сложить в массив ModemDifferenceMeasurement, объектами.
     * в итоге будем иметь структуру данных с 10 объектами. на вывод. да мне нужны модемы, точнее мне нужны локации.
     * Возвращаемая коллекция будет отсортирована по амплитуде разницы сигналов.
     * Задача: у каждого модема взять измерения, это будет descending order Collection, найти наиболее близкую дату.
     * и взять в эти моменты времени, ustxpower, и dssnr, взять разницу между ними.
     * Результат сложить в массив ModemDifferenceMeasurement, объектами.
     * в итоге будем иметь структуру данных с 10 объектами. на вывод. да мне нужны модемы, точнее мне нужны локации.
     *
     * @return {@code modemDifferenceMeasurements }List of Modems with difference of measurements, sorted by difference
     * (m2 to m1, descending order) and cleared to 20 elements
     */

    public List<ModemDifferenceMeasurement> findDifferences(Date goodTimeDate, Date badTimeDate) {
        List<ModemDifferenceMeasurement> modemDifferenceMeasurements = new ArrayList<>();

        // for each Modem find two Measurements according to Date
        for (Modem modem : storageForModems) {
            int goodCase = signalCalculate.findGoodMeasurement(modem.getMeasurements(), goodTimeDate);
            int badCase = signalCalculate.findBadMeasurement(modem.getMeasurements(), badTimeDate);
            // getUsTXPower() - lower is Better, getDsSNR() - higher is Better
            Float usTXPowerDifference = modem.getMeasurements().get(badCase).getUsTXPower() - modem.getMeasurements().get(goodCase).getUsTXPower();
            Float dsSNRDifference = modem.getMeasurements().get(goodCase).getDsSNR() - modem.getMeasurements().get(badCase).getDsSNR();
            Float difference = usTXPowerDifference + dsSNRDifference;
            ModemDifferenceMeasurement modemDifferenceMeasurement = new ModemDifferenceMeasurement
                    (modem, difference);
            modemDifferenceMeasurements.add(modemDifferenceMeasurement);
        }
        modemDifferenceMeasurements
                .sort((ModemDifferenceMeasurement m1, ModemDifferenceMeasurement m2)
                        -> m2.getAnalyzedDifference().compareTo(m1.getAnalyzedDifference()));
        // ok trim to 20 elements - trim by amplitude (while we will not implement)
        if (modemDifferenceMeasurements.size() > 19) {
            modemDifferenceMeasurements.subList(20, modemDifferenceMeasurements.size()).clear();
        }
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
        List<ModemDifferenceMeasurement> modemAfterAnalyzeDifferenceMeasurements = new ArrayList<>();
        for (Modem modem : storageForModems) {
            int badCase = signalCalculate.findMinUSSNR(modem);
            int goodCase = signalCalculate.findMaxUSSNR(modem);
            // getUsTXPower() - lower is Better, getDsSNR() - higher is Better
            // getUsRXPower() - lower is Better,
            Float usTXPowerDifference = modem.getMeasurements().get(badCase).getUsTXPower() - modem.getMeasurements().get(goodCase).getUsTXPower();
            Float usRXPowerDifference = modem.getMeasurements().get(badCase).getUsRXPower() - modem.getMeasurements().get(goodCase).getUsRXPower();
            Float dsSNRDifference = modem.getMeasurements().get(goodCase).getDsSNR() - modem.getMeasurements().get(badCase).getDsSNR();
            Float difference = usTXPowerDifference + usRXPowerDifference + dsSNRDifference;
            ModemDifferenceMeasurement modemDifferenceMeasurement = new ModemDifferenceMeasurement
                    (modem, difference);
            modemAfterAnalyzeDifferenceMeasurements.add(modemDifferenceMeasurement);
        }
        modemAfterAnalyzeDifferenceMeasurements
                .sort((ModemDifferenceMeasurement m1, ModemDifferenceMeasurement m2)
                        -> m2.getAnalyzedDifference().compareTo(m1.getAnalyzedDifference()));
        // ok trim to 20 elements - trim by amplitude (while we will not implement)
        if (modemAfterAnalyzeDifferenceMeasurements.size() > 19) {
            modemAfterAnalyzeDifferenceMeasurements.subList(20, modemAfterAnalyzeDifferenceMeasurements.size()).clear();
        }
        return modemAfterAnalyzeDifferenceMeasurements;
    }
}
