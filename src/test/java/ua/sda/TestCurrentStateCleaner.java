package ua.sda;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by Vasiliy Kylik (Lightning) on 10.04.2018.
 */
/**
 * Тестовый Cleaner для Current State, String-и со значениями (беруться через readLine после строки с именем параметра )
 **/
public class TestCurrentStateCleaner {
    public static void main(String[] args) {
        String strWithValue1 = "            <td bgcolor=\"#8CFF40\" align=\"center\"> <font  > 44 </font> </td>\n";
        String strWithValue2 = "            <td bgcolor=\"white\" align=\"center\"> <font  > 4.5 , (5) </font> </td>\n";
        String strWithValue3 = "            <td bgcolor=\"#8CFF40\" align=\"center\"> <font  > 32 </font> </td>\n";
        String strWithValue4 = "            <td bgcolor=\"#8CFF40\" align=\"center\"> <font  > 2.8 </font> </td>\n";
        String strWithValue5 = "            <td bgcolor=\"#8CFF40\" align=\"center\"> <font  > 36.5 </font> </td>\n";
        String strWithValue6 = "            <td bgcolor=\"white\" align=\"center\"> <font  > 30 </font> </td>\n";
        System.out.println(testCurrentStateCleaner(strWithValue1));
        System.out.println(testCurrentStateCleaner(strWithValue2));
        System.out.println(testCurrentStateCleaner(strWithValue3));
        System.out.println(testCurrentStateCleaner(strWithValue4));
        System.out.println(testCurrentStateCleaner(strWithValue5));
        System.out.println(testCurrentStateCleaner(strWithValue6));
    }

    private static Float testCurrentStateCleaner(String strWithValue) {
        Float value = 0f;
        Pattern p1 = Pattern.compile("<td bgcolor=\".*\" align=\"center\"> <font  > ([0-9][0-9].[0-9]|[0-9][0-9]|[0-9].[0-9]|[0-9]|-[0-9][0-9].[0-9]|-[0-9][0-9]|-[0-9].[0-9]|-[0-9]|.\\d|-.\\d).*<\\/font> <\\/td>");// " >Инфо</a></td></tr><tr bgcolor="#......" wildcard instead this statement because last row have no end marker as previous rows
        Matcher m = p1.matcher(strWithValue);
        if (m.find()) {
            value = Float.valueOf(m.group(1));
        }
        return value;
    }

}
