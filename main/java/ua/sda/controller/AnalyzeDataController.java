package ua.sda.controller;

import ua.sda.entity.analyze.ModemDifferenceMeasurement;
import ua.sda.entity.opticalnodeinterface.Modem;

import java.util.Date;
import java.util.List;

/**
 * Created by Vasiliy Kylik (Lightning) on 23.04.2018.
 */

public class AnalyzeDataController {
    /*Ввод двух дат
 Ввели две даты
 Задача: для каждой даты , для каждого модема найти наиболее близкую дату. и взять в эти моменты времени, ustxpower, и dssnr, взять разницу между ними.
 TODO Implement DateTime Search
 Результат сложить в массив ModemDifferenceMeasurement, объектами.
 в итоге будем иметь структуру данных с 10 объектами. на вывод. да мне нужны модемы, точнее мне нужны локации.*/
    public List<ModemDifferenceMeasurement> findDifferences(Date goodTimeDate, Date badTimeDate) {

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

    }
}
