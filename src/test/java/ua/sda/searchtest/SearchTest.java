package ua.sda.searchtest;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Vasiliy Kylik (Lightning) on 13.06.2018.
 */
public class SearchTest {

    public static void main(String[] args) {

        List<Integer> list = new ArrayList<>();
        list.add(50);
        list.add(40);
        list.add(30);
        list.add(20);
        list.add(10);
        Integer search = 11;

        int low = 0;
        int high = list.size() - 1;

        while (low <= high) {
            int mid = (low + high) >>> 1;
            Integer midVal = list.get(mid);
            int cmp = midVal.compareTo(search);

            if (cmp > 0)
                low = mid + 1;
            else if (cmp < 0)
                high = mid - 1;
            else
                System.out.println("mid = "+mid); // key found
        }
        System.out.println("-(low + 1) = "+ -(low ));  // key not found

    }
}
