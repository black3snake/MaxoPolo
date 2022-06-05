package com.javarush.task.task19.task1918;

/* 
Знакомство с тегами
первая версия, но не работает со вложенными тегами.
*/

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Solution {
    public static void main(String[] args) throws IOException {
        if(args.length == 1) {
            BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
            BufferedReader buffR = new BufferedReader(new FileReader(reader.readLine()));
            reader.close();
            String regexStr = "<" + args[0] + "\\b([^>]*)>(.*?)<\\/" + args[0] + ">";

            StringBuilder sb = new StringBuilder();
            Pattern p = Pattern.compile(regexStr, Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
            String s;
            while ((s = buffR.readLine()) != null) {
                sb.append(s);

            }
            Matcher m = p.matcher(sb.toString().trim());
            while (m.find())
                System.out.println(m.group());

            //System.out.println(sb.toString());
        buffR.close();
        } else
            System.out.println("Веедите имя Тега который хотите найти\n в html файле");


    }
}
