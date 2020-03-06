package com.javarush.task.task19.task1924;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;

/* 
������ �����
���� �� ������� ���� ������� ������ ���������.
*/

public class Solution {
    public static Map<Integer, String> map = new HashMap<Integer, String>();
    static {
        map.put(0, "����");
        map.put(1, "����");
        map.put(2, "���");
        map.put(3, "���");
        map.put(4, "������");
        map.put(5, "����");
        map.put(6, "�����");
        map.put(7, "����");
        map.put(8, "������");
        map.put(9, "������");
        map.put(10, "������");
        map.put(11, "�����������");
        map.put(12, "����������");
    }

    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        FileReader fr = new FileReader(reader.readLine());
        BufferedReader buffR = new BufferedReader(fr);
        reader.close();
        String str;
        Integer intdex;
        StringBuilder sb = new StringBuilder();
        while ((str = buffR.readLine()) != null) {
            String [] strM = str.split("\\s");
            for (int i = 0; i < strM.length; i++) {
                if(strM[i].matches("\\d+")) {
                    intdex = Integer.parseInt(strM[i]);
                    if (intdex >=0 && intdex <= 12) strM[i] = map.get(intdex);
                }

            }
            for (int i = 0; i < strM.length ; i++) {
                sb.append(strM[i]).append(" ");
            }
            System.out.println(sb.toString().trim());
            sb.delete(0,sb.length());
        }
        buffR.close();
        fr.close();
    }
}
