/* 
ДОП Задача на нахождение в последовательности 0123456789
уникальных 3х значных не повторяющихся комбинаций
и сумма их должна быть уникальной.. XXX + XXX = YYYY (цифры не повторяються)
*/
//
//javac -cp . -d . -encoding UTF-8
//java -cp . -DconsoleEncoding=Cp866
//
import java.util.ArrayList;
import java.util.List;
import java.io.PrintStream;
import java.io.UnsupportedEncodingException;

public class Solution {
    public static final int n = 9;
    public static int count = 0;
  
    public static void main(String[] args) {
    List<Integer> array;

    array = CreateList();
    /*for(int w= 0; w < array.size(); w++) {
        count++;
        System.out.println(array.get(w));
    }
    System.out.println("Количество созданных чисел равно = " + count);
    */
    PoiskR(array);
	
    String consoleEncoding = System.getProperty("consoleEncoding");
        if (consoleEncoding != null) {
            try {
                System.setOut(new PrintStream(System.out, true, consoleEncoding));
            } catch (UnsupportedEncodingException ex) {
                System.err.println("Unsupported encoding set for console: "+consoleEncoding);
            }
        }
    System.out.println("Количество чисел сумм равно = " + count);
    }

    public static void PoiskR(List<Integer> arrayR) {
        int OneSL, TwoSL, Result;
        String strOneSL=null, strTwoSL=null, strResult=null;
        ArrayList<Integer> arrayTWO = new ArrayList<>(arrayR);
        for (int i = 0; i < arrayR.size() ; i++) {
            OneSL = arrayR.get(i);
            strOneSL = OneSL + "";
            for (int j = 0; j < arrayTWO.size() ; j++) {
                TwoSL = arrayTWO.get(j);
                strTwoSL = TwoSL + "";
                if(!equaLS(strOneSL, strTwoSL)) {
                    Result = OneSL + TwoSL;
                    if (Result > 1000) {
                        strResult = Result + "";
                        if (!equaLS(strResult, strTwoSL) & !equaLS(strResult, strOneSL) & !equaLSRES(strResult)) {
                            count++;
                            System.out.println(strOneSL + " + " + strTwoSL + " = " + strResult);
                        }
                    }
                }
            }
        }
    }

    public static boolean equaLSRES(String RESULT) {
        char[] chars = RESULT.toCharArray();
        boolean boo = false;
        for (int i = 0; i < chars.length ; i++) {
            char a = chars[i];
            for (int j = i+1; j < chars.length ; j++) {
                char b = chars[j];
                if (a == b) boo = true;
            }
        }
    return boo;
    }

    public static boolean equaLS(String ONE1, String TWO2) {
        char[] chars1 = ONE1.toCharArray();
        char[] chars2 = TWO2.toCharArray();
        boolean boo = false;
        for (int i = 0; i < chars1.length ; i++) {
            char c1 = chars1[i];
            for (int j = 0; j <chars2.length ; j++) {
                char c2 = chars2[j];
                if(c1 == c2 ) boo = true;
            }
        }
    return boo;
    }

    //заполнение Аррей листа уникальными значениями
    public static List<Integer> CreateList() {
        String ONE = null, TWO = null, THREE = null;
        String RES = null;
        List<Integer> arrayList = new ArrayList<>();
        for (int i = 1; i <= n ; i++) {
                ONE = i + "";
            for (int j = 0; j <= n; j++) {
                if(j != i) TWO = j + "";
                for (int k = 0; k <= n; k++) {
                   if(k != i & k != j && i != j ) {
                   THREE = k + "";
                   RES = ONE + TWO + THREE;
                   arrayList.add(Integer.parseInt(RES));
                   }
                }
            }
        }
    return arrayList;
    }

}