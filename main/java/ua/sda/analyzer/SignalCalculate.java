package ua.sda.analyzer;

import ua.sda.entity.opticalnodeinterface.Modem;

/**
 * Created by Vasiliy Kylik (Lightning) on 15.05.2018.
 Ввод двух дат
 Ввели две даты
 Задача: для каждой даты , для каждого модема найти наиболее близкую дату. и взять в эти моменты времени, ustxpower, и dssnr, взять разницу между ними.
 Результат сложить в массив ModemDifferenceMeasurement, объектами.
 в итоге будем иметь структуру данных с 10 объектами. на вывод. да мне нужны модемы, точнее мне нужны локации.

 Анализ Сигналов
 Задача: Найти разницу уровней для максимального и минимального SNR
 Реализация:
 для каждого модема
 возьмем min и max для USSNR
 если min и max значений несколько то берем все
 В эти измерения фиксируем сумму analyzeDifference = usTxPower+usRxPower+ dsSNR.
 те для каждого модема получаем амплитуду скачка - analyzeDifference - и соответственно находим 10 модемов с максимальной analyzeDifference (в коллекции сортируем)
 и десять наибоьших - на вывод
 Что я хочу получить?:
 десять Адресов с Локациями, для максимального падения сигналов обратный уровень и прямой snr

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
