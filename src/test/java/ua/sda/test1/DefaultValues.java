package ua.sda.test1;

/**
 * Created by Vasiliy Kylik (Lightning) on 04.04.2018.
 */
public class DefaultValues {
    boolean b;
    int i[]=new int[2];
    short s;
    char с;
    float f;
    double d;
    String str;
    Object o;
    public String toString(){
        return s+ " " +с+ " " +f+ " " +str+ " " +b+ " " +i[0]+ " " +d+ " " +o;
    }

    public static void main(String[] args) {
        System.out.println(new DefaultValues());
    }
}
