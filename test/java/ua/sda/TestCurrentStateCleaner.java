package ua.sda;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by Vasiliy Kylik (Lightning) on 10.04.2018.
 */
public class TestCurrentStateCleaner {
    public static void main(String[] args) {
        String strWithValue1 = "<td bgcolor=\"#8CFF40\" align=\"center\"> <font  > 44 </font> </td>\n";
        System.out.println(testCurrentStateCleaner(strWithValue1));
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
