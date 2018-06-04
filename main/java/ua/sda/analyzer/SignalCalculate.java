package ua.sda.analyzer;

import ua.sda.entity.opticalnodeinterface.Modem;

/**
 * Created by Vasiliy Kylik (Lightning) on 15.05.2018.
 *
 variant 0 - ввод двух дат, для каждого модема найти наиболее близкую дату, (binary search). и взять в эти моменты времени, ustxpower, и dssnr, взять разницу между ними .
 метод. Разницу сравнить с минимально имеющейся в массиве, если новая больше - добавить в массив.
 (Возможно коллекция, но как быть с уже созданным компаратором?)
 в итоге будем иметь структуру данных с 10 объектами. на вывод. да мне нужны модемы, точнее мне нужны локации.
 Правильно ли будет хранить и выводить локации, ещё необходимо амплитуда скачка.
 Мы находим разницу и складываем объекты в массив на 10 элементов
 ResultModem -

 variant1 - Create object for return values

 variant2  -
 г) возьмем max, min для USSNR, иду по значениям
 г1) рассмотрим случай когда USSNR упал, взял max SNR, взяли max dssnr, max us txpower (их сумму) max sum иду по SNR, и если текущ, SNR < max
 Определить диапазон с точностью до дБ
 г2) что я хочу получить? десять Адресов с Локациями, для максимального падения сигналов обратный уровень и прямой snr
 либо две даты либо анализ

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
