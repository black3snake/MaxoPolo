package com.javarush.task.task19.task1908;

/* 
Выделяем числа
*/

import java.io.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Solution {
    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        FileReader fr = new FileReader(reader.readLine());
        FileWriter fw = new FileWriter(reader.readLine());
        reader.close();
        BufferedReader BR = new BufferedReader(fr);
        BufferedWriter BW = new BufferedWriter(fw);

        String str,str2 = "";
        StringBuilder sb = new StringBuilder();
        //Pattern pattern = Pattern.compile("[^a-zA-Z]\\d+[\\W]?");
        while ((str = BR.readLine()) != null) {
            String[] words = str.split("\\s*(\\s|,|!|\\.)\\s*");
            for(String word : words){
                if(isNumeric(word)) {
                    BW.write(word+" ");
                }
            }
        }
        //str2 = sb.toString().replaceAll("\\s.", " ");
        //BW.write(str2);
        BR.close();
        BW.close();
        fr.close();
        fw.close();
    }
    public static boolean isNumeric(String str)
    {
        return str.matches("[+-]?\\d*(\\.\\d+)?");
    }
}
